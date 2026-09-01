@tool
class_name BrainCloudLoginFlow
extends RefCounted

# Orchestrates the plugin dock's "Log in with brainCloud" flow: OAuth2
# Authorization Code + PKCE login, then Builder API calls to list the
# developer's teams/apps and configure the local project.
# Mirrors braincloud-unity-plugin's Editor/PluginEditor.cs login + team/app
# picker logic.

signal state_changed
signal app_selected(app_id: String, app_secret: String)

enum State { LOGGED_OUT, LOGGING_IN, LOGGED_IN }

const _CLIENT_ID := "godot_plugin"
const _REDIRECT_PORT := 45678
const _SCOPE := "openid email builder_api team_info app_info team_read app_read app_create utility_read"
const _BUILDER_VERSION := "v1"
const CREATE_NEW_APP_ID := ""

var state: int = State.LOGGED_OUT
var email: String = ""
var admin_id: String = ""
var access_token: String = ""
var builder_api_key: String = ""
var team_id: String = ""
var teams: Array = []  # [{id, name, api_enabled}]
var apps: Array = []   # [{id, name}] — includes a synthetic "-- Create New App --" (id == "")
var templates: Array = []  # [{id, name}] — template apps, for "Create using Template"
var error_message: String = ""

var _creds_path: String = ""
var _http_parent: Node = null
var _base_host: String = ""
var _oauth_server: BrainCloudOAuthServer = null
var _code_verifier: String = ""
var _oauth_state: String = ""
var _redirect_uri: String = ""


func configure(creds_path: String, http_parent: Node) -> void:
	_creds_path = creds_path
	_http_parent = http_parent
	_load_session()


func set_base_host(host: String) -> void:
	_base_host = host


func is_logging_in() -> bool:
	return state == State.LOGGING_IN


func is_logged_in() -> bool:
	return state == State.LOGGED_IN


func poll() -> void:
	if _oauth_server != null:
		_oauth_server.poll()


# ── Login ────────────────────────────────────────────────────────────────────

func login() -> void:
	if state == State.LOGGING_IN:
		return
	if _base_host.is_empty():
		error_message = "Server URL is required before logging in."
		state_changed.emit()
		return

	error_message = ""
	state = State.LOGGING_IN
	state_changed.emit()

	_code_verifier = _make_code_verifier()
	var code_challenge := _make_code_challenge(_code_verifier)
	_oauth_state = _make_random_token()
	_redirect_uri = "http://localhost:%d/oauth/callback" % _REDIRECT_PORT

	_oauth_server = BrainCloudOAuthServer.new()
	_oauth_server.code_received.connect(_on_code_received)
	_oauth_server.login_error.connect(_on_login_error)
	if not _oauth_server.start(_REDIRECT_PORT):
		_on_login_error("Could not start local OAuth listener on port %d (already in use?)." % _REDIRECT_PORT)
		return

	var auth_url := "%s/oauth/authorize?response_type=code&client_id=%s&redirect_uri=%s&scope=%s&state=%s&code_challenge=%s&code_challenge_method=S256" % [
		_base_host,
		_CLIENT_ID.uri_encode(),
		_redirect_uri.uri_encode(),
		_SCOPE.uri_encode(),
		_oauth_state.uri_encode(),
		code_challenge.uri_encode(),
	]
	OS.shell_open(auth_url)


func cancel_login() -> void:
	if _oauth_server != null:
		_oauth_server.stop()
		_oauth_server = null
	error_message = ""
	state = State.LOGGED_OUT
	state_changed.emit()


func logout() -> void:
	access_token = ""
	builder_api_key = ""
	team_id = ""
	teams = []
	apps = []
	templates = []
	error_message = ""
	state = State.LOGGED_OUT
	_save_session()
	state_changed.emit()


func _on_code_received(code: String, received_state: String) -> void:
	_oauth_server = null
	if received_state != _oauth_state:
		_on_login_error("OAuth state mismatch; aborting login for safety.")
		return
	_exchange_code_for_token(code)


func _on_login_error(message: String) -> void:
	if _oauth_server != null:
		_oauth_server.stop()
		_oauth_server = null
	# Treat any login-flow failure as a full logout — a half-valid session
	# (e.g. an access token whose team lookup just failed) shouldn't linger
	# and silently resurrect as "logged in" on the next editor restart.
	access_token = ""
	builder_api_key = ""
	team_id = ""
	teams = []
	apps = []
	templates = []
	error_message = message
	state = State.LOGGED_OUT
	_save_session()
	state_changed.emit()


func _exchange_code_for_token(code: String) -> void:
	var body := "client_id=%s&grant_type=authorization_code&redirect_uri=%s&code=%s&code_verifier=%s" % [
		_CLIENT_ID.uri_encode(), _redirect_uri.uri_encode(), code.uri_encode(), _code_verifier.uri_encode(),
	]
	var headers := PackedStringArray(["Content-Type: application/x-www-form-urlencoded", "Accept: application/json"])
	var on_complete := func(success: bool, _code: int, _text: String, json):
		if not success or not (json is Dictionary) or not json.has("access_token"):
			_on_login_error("Failed to exchange code for token.")
			return
		access_token = str(json["access_token"])
		_fetch_user_info()
	BrainCloudBuilderApi.request(_http_parent, HTTPClient.METHOD_POST, _base_host + "/oauth/token", headers, body, on_complete)


func _fetch_user_info() -> void:
	var headers := PackedStringArray([
		"Authorization: " + BrainCloudBuilderApi.bearer_auth_header(access_token),
		"Accept: application/json",
	])
	var on_complete := func(success: bool, _code: int, _text: String, json):
		if not success or not (json is Dictionary):
			_on_login_error("Failed to fetch user info.")
			return
		_apply_user_info(json)
	BrainCloudBuilderApi.request(_http_parent, HTTPClient.METHOD_GET, _base_host + "/user/me", headers, "", on_complete)


func _apply_user_info(user: Dictionary) -> void:
	email = str(user.get("email", ""))
	admin_id = str(user.get("id", user.get("sub", "")))

	var current_team_id := ""
	var available: Array = []
	var team_info = user.get("team_info")
	if team_info is Dictionary:
		var current_team = team_info.get("current_team")
		if current_team is Dictionary and current_team.has("teamId"):
			current_team_id = str(current_team["teamId"])
		var available_teams = team_info.get("available_teams")
		if available_teams is Array:
			available = available_teams

	var new_teams: Array = []
	for t in available:
		if t is Dictionary:
			new_teams.append({
				"id": str(t.get("teamId", "")),
				"name": str(t.get("teamName", "")),
				"api_enabled": bool(t.get("apiEnabled", false)),
			})
	new_teams.sort_custom(func(a, b): return a["name"].nocasecmp_to(b["name"]) < 0)
	teams = new_teams

	if current_team_id.is_empty() and not teams.is_empty():
		current_team_id = teams[0]["id"]

	if current_team_id.is_empty():
		_on_login_error("No brainCloud team available for this account.")
		return

	team_id = current_team_id
	_fetch_inner_api_key()


func _fetch_inner_api_key() -> void:
	var url := "%s/user/add-temp-api-key?teamId=%s" % [_base_host, team_id.uri_encode()]
	var headers := PackedStringArray([
		"Authorization: " + BrainCloudBuilderApi.bearer_auth_header(access_token),
		"Accept: application/json",
	])
	var team_name := _current_team_name()
	var on_complete := func(success: bool, code: int, text: String, json):
		if not success or not (json is Dictionary):
			_on_login_error("%s\nFailed to obtain a Builder API key for %s.\nPlease ensure Builder API is enabled for this team on the Team Setup -> Team Info screen." % [
				BrainCloudBuilderApi.describe_error(code, text, json), team_name])
			return

		var inner_key := ""
		var api_key_obj = json.get("apiKey")
		if api_key_obj is Dictionary:
			for key in api_key_obj.keys():
				var entry = api_key_obj[key]
				if entry is Dictionary and entry.has("apiKey"):
					inner_key = str(entry["apiKey"])
					break

		if inner_key.is_empty():
			_on_login_error("Builder API key not found in response.")
			return

		builder_api_key = inner_key
		error_message = ""
		state = State.LOGGED_IN
		_save_session()
		state_changed.emit()
		download_app_list(true)
	BrainCloudBuilderApi.request(_http_parent, HTTPClient.METHOD_POST, url, headers, "", on_complete)


# ── Team / app selection ─────────────────────────────────────────────────────

# Re-fetches the team list via the Builder API (GET /builder/{v}/team). Used to
# repopulate `teams` after a persisted session is restored (only team_id itself
# is persisted, not the display names). NOTE: braincloud-unity-plugin defines
# this same call but never actually exercises it — Unity gets its team list
# solely from /user/me's team_info.available_teams during login. The response
# parsing below follows the same "{response: {<plural>: [...]}}" envelope and
# field-naming convention every other Builder endpoint here uses/confirms
# (teamId/teamName, matching team_info.available_teams) but is otherwise
# unverified against a live server response — double check on first real use.
func refresh_teams() -> void:
	if not is_logged_in():
		return
	var config := _builder_config()
	var on_complete := func(success: bool, code: int, text: String, json):
		if not success or not (json is Dictionary):
			# A stale/expired session (or a revoked Builder API key) means the
			# whole logged-in state is no longer trustworthy — drop back to
			# the login screen rather than staying "logged in" with no teams.
			_on_login_error("%s\nFailed to fetch team list." % BrainCloudBuilderApi.describe_error(code, text, json))
			return

		var response = json.get("response")
		var list: Array = []
		if response is Dictionary and response.get("teams") is Array:
			for t in response["teams"]:
				if t is Dictionary:
					list.append({
						"id": str(t.get("teamId", "")),
						"name": str(t.get("teamName", "")),
						"api_enabled": bool(t.get("apiEnabled", false)),
					})
		list.sort_custom(func(a, b): return a["name"].nocasecmp_to(b["name"]) < 0)

		teams = list
		var still_valid := false
		for t in teams:
			if t["id"] == team_id:
				still_valid = true
				break
		error_message = ""
		if not still_valid and not teams.is_empty():
			# Landed on a different team than the persisted one — its temp
			# Builder API key is team-scoped, so it must be re-minted too.
			team_id = teams[0]["id"]
			builder_api_key = ""
			state_changed.emit()
			_fetch_inner_api_key()
		else:
			state_changed.emit()
			download_app_list(true)
	BrainCloudBuilderApi.get_team_list(_http_parent, config, on_complete)


func select_team(new_team_id: String) -> void:
	if new_team_id == team_id:
		return
	team_id = new_team_id
	apps = []
	# The temp Builder API key is minted per-team — must be refreshed before any
	# Builder call against the newly selected team, not reused from the old one.
	builder_api_key = ""
	_save_session()
	_fetch_inner_api_key()


func download_app_list(force: bool = false) -> void:
	if team_id.is_empty():
		return
	if not apps.is_empty() and not force:
		return

	var config := _builder_config()
	var team_name := _current_team_name()
	var on_complete := func(success: bool, code: int, text: String, json):
		if not success or not (json is Dictionary):
			# Mirrors Unity's DownloadAppListNew failure: a team-scoped Builder
			# call failing means the session/team context is no longer good —
			# drop back to login rather than leaving a broken app list visible.
			_on_login_error("%s\nFailed to fetch app list for %s.\nPlease ensure Builder API is enabled for this team on the Team Setup -> Team Info screen." % [
				BrainCloudBuilderApi.describe_error(code, text, json), team_name])
			return

		var response = json.get("response")
		var list: Array = []
		if response is Dictionary and response.get("apps") is Array:
			for a in response["apps"]:
				if a is Dictionary:
					list.append({"id": str(a.get("appId", "")), "name": str(a.get("appName", ""))})
		list.sort_custom(func(a, b): return a["name"].nocasecmp_to(b["name"]) < 0)
		list.insert(0, {"id": CREATE_NEW_APP_ID, "name": "-- Create New App --"})

		apps = list
		error_message = ""
		state_changed.emit()
	BrainCloudBuilderApi.get_app_list(_http_parent, config, team_id, on_complete)


func download_template_list(force: bool = false) -> void:
	if not templates.is_empty() and not force:
		return
	var config := _builder_config()
	var on_complete := func(success: bool, _code: int, _text: String, json):
		if not success or not (json is Dictionary):
			error_message = "Failed to fetch app templates."
			state_changed.emit()
			return

		var response = json.get("response")
		var list: Array = []
		if response is Dictionary and response.get("apps") is Array:
			for a in response["apps"]:
				if a is Dictionary:
					list.append({"id": str(a.get("appId", "")), "name": str(a.get("appName", ""))})
		list.sort_custom(func(a, b): return a["name"].nocasecmp_to(b["name"]) < 0)

		templates = list
		error_message = ""
		state_changed.emit()
	BrainCloudBuilderApi.get_template_app_list(_http_parent, config, on_complete)


func select_app(app_id: String) -> void:
	if app_id.is_empty():
		return  # "-- Create New App --" sentinel — the dock shows the create-app UI instead
	var config := _builder_config()
	var on_complete := func(success: bool, _code: int, _text: String, json):
		if not success or not (json is Dictionary):
			error_message = "Failed to fetch app secret."
			state_changed.emit()
			return
		var response = json.get("response")
		var app = response.get("app") if response is Dictionary else null
		var secret := str(app.get("appSecret", "")) if app is Dictionary else ""
		if secret.is_empty():
			error_message = "App secret not found in response."
			state_changed.emit()
			return
		app_selected.emit(app_id, secret)
	BrainCloudBuilderApi.get_app_secret(_http_parent, config, team_id, app_id, on_complete)


func create_app(app_name: String, platforms: Array, template_app_id: String = "") -> void:
	var trimmed := app_name.strip_edges()
	if trimmed.is_empty():
		error_message = "App name is required."
		state_changed.emit()
		return

	var config := _builder_config()
	var on_complete := func(success: bool, _code: int, _text: String, json):
		if not success or not (json is Dictionary):
			error_message = "Failed to create app."
			state_changed.emit()
			return
		var response = json.get("response")
		var app = response.get("app") if response is Dictionary else null
		var new_app_id := str(app.get("appId", "")) if app is Dictionary else ""

		error_message = ""
		download_app_list(true)
		if not new_app_id.is_empty():
			select_app(new_app_id)
	BrainCloudBuilderApi.create_app(_http_parent, config, team_id, trimmed, platforms, template_app_id, on_complete)


func _builder_config() -> Dictionary:
	return {
		"base_host": _base_host,
		"email": email,
		"api_key": builder_api_key,
		"version": _BUILDER_VERSION,
	}


func _current_team_name() -> String:
	for t in teams:
		if t["id"] == team_id:
			return str(t["name"])
	return team_id


# ── PKCE helpers ─────────────────────────────────────────────────────────────

func _make_code_verifier() -> String:
	return _base64_url(Crypto.new().generate_random_bytes(32))


func _make_code_challenge(verifier: String) -> String:
	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	ctx.update(verifier.to_utf8_buffer())
	return _base64_url(ctx.finish())


func _make_random_token() -> String:
	return _base64_url(Crypto.new().generate_random_bytes(16))


func _base64_url(bytes: PackedByteArray) -> String:
	return Marshalls.raw_to_base64(bytes).replace("+", "-").replace("/", "_").replace("=", "")


# ── Session persistence ──────────────────────────────────────────────────────
# Stored in the same gitignored ConfigFile the dock uses for App ID/Secret, so a
# developer stays logged in across editor restarts without re-authorizing.

func _save_session() -> void:
	if _creds_path.is_empty():
		return
	var cfg := ConfigFile.new()
	cfg.load(_creds_path)  # preserve the [credentials] section already on disk
	cfg.set_value("oauth", "access_token", access_token)
	cfg.set_value("oauth", "email", email)
	cfg.set_value("oauth", "admin_id", admin_id)
	cfg.set_value("oauth", "team_id", team_id)
	cfg.set_value("oauth", "builder_api_key", builder_api_key)
	cfg.save(_creds_path)


func _load_session() -> void:
	if _creds_path.is_empty():
		return
	var cfg := ConfigFile.new()
	if cfg.load(_creds_path) != OK:
		return
	access_token = str(cfg.get_value("oauth", "access_token", ""))
	email = str(cfg.get_value("oauth", "email", ""))
	admin_id = str(cfg.get_value("oauth", "admin_id", ""))
	team_id = str(cfg.get_value("oauth", "team_id", ""))
	builder_api_key = str(cfg.get_value("oauth", "builder_api_key", ""))
	if not access_token.is_empty() and not builder_api_key.is_empty():
		state = State.LOGGED_IN
