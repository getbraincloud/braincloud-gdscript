@tool
class_name BrainCloudBuilderApi
extends RefCounted

# Thin REST client for the brainCloud Builder API, used by the plugin dock to
# list a logged-in developer's teams/apps and configure the local project.
# Mirrors braincloud-unity-plugin's Editor/BuilderAPI.cs.

const VERSION := "v1"


static func base_host(server_url: String) -> String:
	var url := server_url.strip_edges()
	var scheme_end := url.find("://")
	if scheme_end == -1:
		return url
	var host := _host_only(url, scheme_end)
	if host.begins_with("portal."):
		host = "api." + host.substr(len("portal."))
	return url.substr(0, scheme_end + 3) + host


# The brainCloud portal (for humans) lives on the same host as the Builder/game
# API, just under the "portal." subdomain instead of "api." — used to build a
# "view this app in the portal" link from whatever Server URL is configured.
static func portal_host(server_url: String) -> String:
	var url := server_url.strip_edges()
	var scheme_end := url.find("://")
	if scheme_end == -1:
		return url
	var host := _host_only(url, scheme_end)
	if host.begins_with("api."):
		host = "portal." + host.substr(len("api."))
	return url.substr(0, scheme_end + 3) + host + "/"


static func _host_only(url: String, scheme_end: int) -> String:
	var rest := url.substr(scheme_end + 3)
	var path_index := rest.find("/")
	return rest if path_index == -1 else rest.substr(0, path_index)


static func basic_auth_header(email: String, api_key: String) -> String:
	return "Basic " + Marshalls.utf8_to_base64(email + ":" + api_key)


static func bearer_auth_header(access_token: String) -> String:
	return "Bearer " + access_token


# Turns a failed request's (response_code, body_text, body_json) into a short,
# human-readable reason — prefers a server-supplied message/reason code over a
# bare HTTP status, matching Unity's UnityWebRequest.error being surfaced
# directly in its login/team/app error messages.
static func describe_error(response_code: int, text: String, json) -> String:
	if json is Dictionary:
		if json.has("message") and not str(json["message"]).is_empty():
			return str(json["message"])
		if json.has("reason_code"):
			return "reason code " + str(json["reason_code"])
	if response_code > 0:
		return "HTTP %d" % response_code
	if not text.is_empty():
		return text
	return "network error"


# on_complete: func(success: bool, response_code: int, body_text: String, body_json: Variant)
static func request(parent: Node, method: HTTPClient.Method, url: String,
		headers: PackedStringArray, body: String, on_complete: Callable) -> void:
	var http := HTTPRequest.new()
	parent.add_child(http)
	http.timeout = 30.0

	var err := http.request(url, headers, method, body)
	if err != OK:
		http.queue_free()
		on_complete.call(false, 0, "Failed to start request (error %d)" % err, null)
		return

	var on_request_completed := func(result: int, response_code: int, _resp_headers: PackedStringArray, body_bytes: PackedByteArray):
		http.queue_free()
		var text := body_bytes.get_string_from_utf8()
		var parsed = null
		if not text.is_empty():
			var json := JSON.new()
			if json.parse(text) == OK:
				parsed = json.get_data()
		var success := result == HTTPRequest.RESULT_SUCCESS and response_code >= 200 and response_code < 300
		on_complete.call(success, response_code, text, parsed)
	http.request_completed.connect(on_request_completed, CONNECT_ONE_SHOT)


static func get_team_list(parent: Node, config: Dictionary, on_complete: Callable) -> void:
	var path := "/builder/%s/team" % config["version"]
	_call(parent, HTTPClient.METHOD_GET, path, "", config, on_complete)


static func get_app_list(parent: Node, config: Dictionary, team_id: String, on_complete: Callable) -> void:
	var path := "/builder/%s/team/%s/app" % [config["version"], team_id]
	_call(parent, HTTPClient.METHOD_GET, path, "", config, on_complete)


static func get_app_secret(parent: Node, config: Dictionary, team_id: String, app_id: String, on_complete: Callable) -> void:
	var path := "/builder/%s/team/%s/app/%s/appsecret" % [config["version"], team_id, app_id]
	_call(parent, HTTPClient.METHOD_GET, path, "", config, on_complete)


static func get_template_app_list(parent: Node, config: Dictionary, on_complete: Callable) -> void:
	_call(parent, HTTPClient.METHOD_GET, "/builder/v1/utility/templateapps?liveOnly=true", "", config, on_complete)


static func create_app(parent: Node, config: Dictionary, team_id: String, app_name: String,
		supported_platforms: Array, template_app_id: String, on_complete: Callable) -> void:
	var path := "/builder/%s/team/%s/app" % [config["version"], team_id]
	var dict: Dictionary = {
		"appName": app_name,
		"appOptions": {
			"supportedPlatforms": supported_platforms,
			"gamificationEnabled": true,
		},
	}
	if not template_app_id.is_empty():
		dict["templateAppId"] = template_app_id
	_call(parent, HTTPClient.METHOD_POST, path, JSON.stringify(dict), config, on_complete)


static func _call(parent: Node, method: HTTPClient.Method, path: String, body: String,
		config: Dictionary, on_complete: Callable) -> void:
	var url: String = config["base_host"] + path
	var headers := PackedStringArray([
		"Authorization: " + basic_auth_header(config["email"], config["api_key"]),
		"Content-Type: application/json",
		"Accept: application/json",
	])
	request(parent, method, url, headers, body, on_complete)
