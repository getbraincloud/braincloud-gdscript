# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudWrapper
extends Node

const PREFS_PROFILE_ID := "brainCloud.profileId"
const PREFS_ANONYMOUS_ID := "brainCloud.anonymousId"
const PREFS_AUTHENTICATION_TYPE := "brainCloud.authenticationType"
const PREFS_LAST_PACKET_ID := "brainCloud.lastPacketId"
const _CREDS_PATH := "res://addons/braincloud/braincloud.cfg"

var _client: BrainCloudClient = null
var braincloud_client: BrainCloudClient:
	get: return _client

var _always_allow_profile_switch: bool = true
var always_allow_profile_switch: bool:
	get: return _always_allow_profile_switch
	set(v): _always_allow_profile_switch = v

var _last_url: String = ""
var _last_secret_key: String = ""
var _last_sign_profile: Callable = Callable()
var _last_app_id: String = ""
var _last_app_version: String = ""
var _child_app_ids: Array = []
# Untyped -- BrainCloudNative isn't available on every export target.
var _native_secure: Object = null # kept alive so its sign() stays callable
var wrapper_name: String = ""

# Expose services through wrapper
var authentication_service: BrainCloudAuthentication:
	get: return _client.authentication_service
var entity_service: BrainCloudEntity:
	get: return _client.entity_service
var global_entity_service: BrainCloudGlobalEntity:
	get: return _client.global_entity_service
var global_app_service: BrainCloudGlobalApp:
	get: return _client.global_app_service
var virtual_currency_service: BrainCloudVirtualCurrency:
	get: return _client.virtual_currency_service
var app_store_service: BrainCloudAppStore:
	get: return _client.app_store_service
var player_statistics_service: BrainCloudPlayerStatistics:
	get: return _client.player_statistics_service
var global_statistics_service: BrainCloudGlobalStatistics:
	get: return _client.global_statistics_service
var identity_service: BrainCloudIdentity:
	get: return _client.identity_service
var item_catalog_service: BrainCloudItemCatalog:
	get: return _client.item_catalog_service
var user_items_service: BrainCloudUserItems:
	get: return _client.user_items_service
var script_service: BrainCloudScript:
	get: return _client.script_service
var campaign_service: BrainCloudCampaign:
	get: return _client.campaign_service
var match_making_service: BrainCloudMatchMaking:
	get: return _client.match_making_service
var one_way_match_service: BrainCloudOneWayMatch:
	get: return _client.one_way_match_service
var playback_stream_service: BrainCloudPlaybackStream:
	get: return _client.playback_stream_service
var presence_service: BrainCloudPresence:
	get: return _client.presence_service
var gamification_service: BrainCloudGamification:
	get: return _client.gamification_service
var player_state_service: BrainCloudPlayerState:
	get: return _client.player_state_service
var friend_service: BrainCloudFriend:
	get: return _client.friend_service
var event_service: BrainCloudEvent:
	get: return _client.event_service
var social_leaderboard_service: BrainCloudSocialLeaderboard:
	get: return _client.leaderboard_service
var leaderboard_service: BrainCloudSocialLeaderboard:
	get: return _client.leaderboard_service
var async_match_service: BrainCloudAsyncMatch:
	get: return _client.async_match_service
var time_service: BrainCloudTime:
	get: return _client.time_service
var tournament_service: BrainCloudTournament:
	get: return _client.tournament_service
var global_file_service: BrainCloudGlobalFile:
	get: return _client.global_file_service
var custom_entity_service: BrainCloudCustomEntity:
	get: return _client.custom_entity_service
var push_notification_service: BrainCloudPushNotification:
	get: return _client.push_notification_service
var player_statistics_event_service: BrainCloudPlayerStatisticsEvent:
	get: return _client.player_statistics_event_service
var redemption_code_service: BrainCloudRedemptionCode:
	get: return _client.redemption_code_service
var data_stream_service: BrainCloudDataStream:
	get: return _client.data_stream_service
var profanity_service: BrainCloudProfanity:
	get: return _client.profanity_service
var file_service: BrainCloudFile:
	get: return _client.file_service
var group_service: BrainCloudGroup:
	get: return _client.group_service
var mail_service: BrainCloudMail:
	get: return _client.mail_service
var messaging_service: BrainCloudMessaging:
	get: return _client.messaging_service
var blockchain_service: BrainCloudBlockchain:
	get: return _client.blockchain_service
var group_file_service: BrainCloudGroupFile:
	get: return _client.group_file_service
var lobby_service: BrainCloudLobby:
	get: return _client.lobby_service
var chat_service: BrainCloudChat:
	get: return _client.chat_service
var rtt_service: BrainCloudRTT:
	get: return _client.rtt_service
var relay_service: BrainCloudRelay:
	get: return _client.relay_service

func _ready() -> void:
	_client = BrainCloudClient.new()
	add_child(_client)

func is_initialized() -> bool:
	return _client.is_initialized()

# Initializes brainCloud using the credentials saved by the editor plugin's login flow
# (the gitignored braincloud.cfg) on platforms with the native BrainCloudNative extension.
# Mirrors the C#/Unity SDK's parameterless Init(), which reads its Unity Settings window
# plugin data. Must be called explicitly by the developer — use initialize(...) instead
# to pass explicit parameters.
func init() -> void:
	if not ClassDB.class_exists("BrainCloudNative"):
		_init_from_project_settings()
		return
	_native_secure = ClassDB.instantiate("BrainCloudNative")
	var app_version: String = ProjectSettings.get_setting("braincloud/config/app_version", "1.0.0")
	var server_url: String  = ProjectSettings.get_setting("braincloud/config/server_url", BrainCloudClient.DEFAULT_SERVER_URL)
	# Older native builds have no child app support.
	if not _native_secure.has_method("resolve_configs"):
		_native_secure.resolve_config(_CREDS_PATH, func(app_id: String, sign_profile: Callable):
			initialize(sign_profile, app_id, app_version, server_url))
		return
	var child_ids: PackedStringArray = _native_secure.resolve_child_ids(_CREDS_PATH)
	_native_secure.resolve_configs(_CREDS_PATH, func(app_id: String, app_profiles: Dictionary):
		# Main app first, then children in config order, for get_child_app_id_list().
		var ordered := {app_id: app_profiles[app_id]}
		for child_id in child_ids:
			if app_profiles.has(child_id):
				ordered[child_id] = app_profiles[child_id]
		# Child apps configured: load them too so switch_to_child_profile can sign.
		if ordered.size() > 1:
			init_with_apps(ordered, app_id, app_version, server_url)
		else:
			initialize(app_profiles[app_id], app_id, app_version, server_url))

# Fallback for export targets with no BrainCloudNative extension (currently: Web).
func _init_from_project_settings() -> void:
	var app_id: String = ProjectSettings.get_setting("braincloud/config/app_id.web", "")
	var profile := BrainCloudWebConfig.profile(_web_setting("app_a.web", "app_share.web"), _web_setting("app_b.web", "app_pad.web"))
	if app_id.is_empty() or not profile.is_valid():
		push_error("BrainCloudWrapper.init(): save the app in the brainCloud dock (writes braincloud/config/app_id.web, app_a.web, app_b.web), or call initialize() with your own app profile.")
		return
	var app_version: String = ProjectSettings.get_setting("braincloud/config/app_version", "1.0.0")
	var server_url: String  = ProjectSettings.get_setting("braincloud/config/server_url", BrainCloudClient.DEFAULT_SERVER_URL)
	initialize(profile, app_id, app_version, server_url)

func _web_setting(key: String, old_key: String) -> String:
	var value: String = ProjectSettings.get_setting("braincloud/config/" + key, "")
	return value if not value.is_empty() else str(ProjectSettings.get_setting("braincloud/config/" + old_key, ""))

# Initialize the brainCloud client with the passed in parameters. This version overrides
# the credentials read from braincloud.cfg/ProjectSettings by init(). Either way, logging
# and compression are always applied from ProjectSettings (braincloud/debug/enable_logging,
# braincloud/config/enable_compression) right after the client initializes.
# secret_key_or_profile: app secret (String) or app profile (Callable).
func initialize(secret_key_or_profile: Variant, app_id: String, version: String, url: String = BrainCloudClient.DEFAULT_SERVER_URL) -> void:
	_last_url = url
	if secret_key_or_profile is Callable:
		_last_secret_key = ""
		_last_sign_profile = secret_key_or_profile
	else:
		_last_secret_key = str(secret_key_or_profile)
		_last_sign_profile = Callable()
	_last_app_id = app_id
	_last_app_version = version
	_child_app_ids = []
	_client.initialize(secret_key_or_profile, app_id, version, url)
	_client.enable_logging(bool(ProjectSettings.get_setting("braincloud/debug/enable_logging", false)))
	_client.enable_compression(bool(ProjectSettings.get_setting("braincloud/config/enable_compression", true)))

## True if a response from an awaited call succeeded (status 200).
static func is_success(response: Dictionary) -> bool:
	return BrainCloudClient.is_success(response)

func get_app_id() -> String:
	return _last_app_id

func get_app_version() -> String:
	return _last_app_version

# app_id_profile_map: app_id -> app secret (String) or app profile (Callable).
func init_with_apps(app_id_profile_map: Dictionary, default_app_id: String, version: String, url: String = BrainCloudClient.DEFAULT_SERVER_URL) -> void:
	_last_url = url
	# Kept so reset_to_default_app can re-initialize the default app.
	var default_profile: Variant = app_id_profile_map.get(default_app_id, "")
	_last_sign_profile = default_profile if default_profile is Callable else Callable()
	_last_secret_key = "" if default_profile is Callable else str(default_profile)
	_last_app_id = default_app_id
	_last_app_version = version
	_child_app_ids = []
	for app_id in app_id_profile_map:
		if str(app_id) != default_app_id:
			_child_app_ids.append(str(app_id))
	_client.initialize_with_apps(default_app_id, app_id_profile_map, version, url)
	_client.enable_logging(bool(ProjectSettings.get_setting("braincloud/debug/enable_logging", false)))
	_client.enable_compression(bool(ProjectSettings.get_setting("braincloud/config/enable_compression", true)))

## Child app ids from the last init, in config order (index 0 = first child); empty for a single app.
func get_child_app_id_list() -> Array:
	return _child_app_ids.duplicate()

func get_stored_profile_id() -> String:
	return _load_pref(PREFS_PROFILE_ID)

func get_stored_anonymous_id() -> String:
	return _load_pref(PREFS_ANONYMOUS_ID)

func get_stored_authentication_type() -> String:
	return _load_pref(PREFS_AUTHENTICATION_TYPE)

func set_stored_profile_id(profile_id: String) -> void:
	_save_pref(PREFS_PROFILE_ID, profile_id)

func set_stored_anonymous_id(anonymous_id: String) -> void:
	_save_pref(PREFS_ANONYMOUS_ID, anonymous_id)

func set_stored_authentication_type(auth_type: String) -> void:
	_save_pref(PREFS_AUTHENTICATION_TYPE, auth_type)

func reset_stored_profile_id() -> void:
	_save_pref(PREFS_PROFILE_ID, "")

func reset_stored_anonymous_id() -> void:
	_save_pref(PREFS_ANONYMOUS_ID, "")

func _prefs_path() -> String:
	return "user://" + wrapper_name + "BrainCloudWrapper.cfg"

func _load_pref(key: String) -> String:
	var section := "brainCloud" + wrapper_name
	var cfg := ConfigFile.new()
	if cfg.load(_prefs_path()) != OK:
		return ""
	return str(cfg.get_value(section, key, ""))

func _save_pref(key: String, value: String) -> void:
	var section := "brainCloud" + wrapper_name
	var cfg := ConfigFile.new()
	cfg.load(_prefs_path())
	cfg.set_value(section, key, value)
	cfg.save(_prefs_path())

func authenticate_anonymous(force_create: bool = true) -> Dictionary:
	var anonymous_id := get_stored_anonymous_id()
	var profile_id := get_stored_profile_id()

	if anonymous_id.length() == 0:
		anonymous_id = _client.authentication_service.generate_anonymous_id()
		set_stored_anonymous_id(anonymous_id)

	_client.initialize_identity(profile_id, anonymous_id)
	set_stored_authentication_type(AuthenticationType.ANONYMOUS)

	var response := await _client.authentication_service.authenticate_anonymous(force_create)
	if response.get("status", 0) == StatusCodes.OK:
		_on_authenticated(response)
	return response

func authenticate_email_password(email: String, password: String, force_create: bool) -> Dictionary:
	_init_profile_for_authenticate()
	set_stored_authentication_type(AuthenticationType.EMAIL)
	var response := await _client.authentication_service.authenticate_email_password(email, password, force_create)
	if response.get("status", 0) == StatusCodes.OK:
		_on_authenticated(response)
	return response

func authenticate_universal(username: String, password: String, force_create: bool) -> Dictionary:
	_init_profile_for_authenticate()
	set_stored_authentication_type(AuthenticationType.UNIVERSAL)
	var response := await _client.authentication_service.authenticate_universal(username, password, force_create)
	if response.get("status", 0) == StatusCodes.OK:
		_on_authenticated(response)
	return response

func authenticate_google(google_user_id: String, server_auth_code: String, force_create: bool) -> Dictionary:
	_init_profile_for_authenticate()
	set_stored_authentication_type(AuthenticationType.GOOGLE)
	var response := await _client.authentication_service.authenticate_google(google_user_id, server_auth_code, force_create)
	if response.get("status", 0) == StatusCodes.OK:
		_on_authenticated(response)
	return response

func authenticate_apple(apple_user_id: String, identity_token: String, force_create: bool) -> Dictionary:
	_init_profile_for_authenticate()
	set_stored_authentication_type(AuthenticationType.APPLE)
	var response := await _client.authentication_service.authenticate_apple(apple_user_id, identity_token, force_create)
	if response.get("status", 0) == StatusCodes.OK:
		_on_authenticated(response)
	return response

func authenticate_facebook(facebook_id: String, token: String, force_create: bool) -> Dictionary:
	_init_profile_for_authenticate()
	set_stored_authentication_type(AuthenticationType.FACEBOOK)
	var response := await _client.authentication_service.authenticate_facebook(facebook_id, token, force_create)
	if response.get("status", 0) == StatusCodes.OK:
		_on_authenticated(response)
	return response

func authenticate_steam(steam_id: String, session_ticket: String, force_create: bool) -> Dictionary:
	_init_profile_for_authenticate()
	set_stored_authentication_type(AuthenticationType.STEAM)
	var response := await _client.authentication_service.authenticate_steam(steam_id, session_ticket, force_create)
	if response.get("status", 0) == StatusCodes.OK:
		_on_authenticated(response)
	return response

# Re-authenticates an expired session using ONLY the stored anonymous id and profile id.
# We deliberately never store or replay user passwords (email/universal credentials), so
# reconnection always goes through anonymous authentication - matching the C# SDK.
func reconnect() -> Dictionary:
	_init_identity_for_reconnect()
	return await authenticate_anonymous(false)

# Kept for backwards compatibility - identical to reconnect().
func reauthenticate() -> Dictionary:
	return await reconnect()

# Returns true if a reconnect is possible (both profile id and anonymous id are stored).
func can_reconnect() -> bool:
	return not get_stored_profile_id().is_empty() and not get_stored_anonymous_id().is_empty()

# Enables (or disables) transparent automatic re-authentication when an authenticated
# session expires. When enabled, the SDK silently re-authenticates anonymously and replays
# the lost calls without the game code having to handle session-expiry errors.
func enable_auto_reconnect(enabled: bool) -> void:
	_init_identity_for_reconnect()
	_client.enable_auto_reconnect(enabled)

func logout(forget_user: bool = false) -> Dictionary:
	var response := await _client.player_state_service.logout()
	if forget_user:
		reset_stored_profile_id()
		reset_stored_anonymous_id()
		set_stored_authentication_type("")
	return response

func reset_to_default_app() -> void:
	if _last_app_id.is_empty():
		return
	if _last_sign_profile.is_valid():
		_client.initialize(_last_sign_profile, _last_app_id, _last_app_version, _last_url)
	else:
		_client.initialize(_last_secret_key, _last_app_id, _last_app_version, _last_url)

func _on_authenticated(response: Dictionary) -> void:
	var data: Dictionary = response.get("data", {})
	var profile_id: String = data.get("profileId", "")
	if profile_id.length() > 0:
		set_stored_profile_id(profile_id)

func getCampaignService() -> BrainCloudCampaign:
	return campaign_service

# Loads the stored anonymous id and profile id into the authentication service so that a
# silent anonymous re-authentication (reconnect / auto-reconnect) can succeed. Generates a
# new anonymous id only if none has been stored yet.
func _init_identity_for_reconnect() -> void:
	var anonymous_id := get_stored_anonymous_id()
	if anonymous_id.is_empty():
		anonymous_id = _client.authentication_service.generate_anonymous_id()
		set_stored_anonymous_id(anonymous_id)
	_client.initialize_identity(get_stored_profile_id(), anonymous_id)

func _init_profile_for_authenticate() -> void:
	if _always_allow_profile_switch:
		_client.authentication_service.profile_id = ""
	else:
		_client.authentication_service.profile_id = get_stored_profile_id()
	var anon_id := get_stored_anonymous_id()
	if anon_id.length() == 0:
		anon_id = _client.authentication_service.generate_anonymous_id()
		set_stored_anonymous_id(anon_id)
	_client.authentication_service.anonymous_id = anon_id
