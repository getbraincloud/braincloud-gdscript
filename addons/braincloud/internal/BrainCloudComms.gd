# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudComms
extends Node

const NO_PACKET_EXPECTED := -1
const VERSION := "1.0.0"

var _client_ref: Node = null
var _initialized: bool = false
var _enabled: bool = true
var _packet_id: int = 1
var _expected_incoming_packet_id: int = NO_PACKET_EXPECTED
var _service_calls_waiting: Array[ServerCall] = []
var _service_calls_in_progress: Array[ServerCall] = []
var _service_calls_in_timeout_queue: Array[ServerCall] = []
var _active_request: RequestState = null
var _last_time_packet_sent: float = 0.0
var _idle_timeout_secs: float = 5.0 * 60.0
var _max_bundle_messages: int = 10
var _kill_switch_threshold: int = 11
var _identical_failed_auth_attempt_threshold: int = 3
var _failed_authentication_attempts: int = 0
var _authentication_timeout_duration: float = 30.0
var _authentication_timeout_start: float = 0.0
var _received_packet_id_checker: int = 0
var _auto_reconnect_enabled: bool = false
var _kill_switch_engaged: bool = false
var _kill_switch_error_count: int = 0
var _kill_switch_service: String = ""
var _kill_switch_operation: String = ""
var _is_authenticated: bool = false
var _blocking_queue: bool = false
var _cache_messages_on_network_error: bool = false
var _app_id: String = ""
var _session_id: String = ""
var _server_url: String = ""
var _upload_url: String = ""
var _app_profiles: Dictionary = {} # app_id -> Callable(payload: PackedByteArray) -> String
var _cached_status_code: int = StatusCodes.FORBIDDEN
var _cached_reason_code: int = ReasonCodes.NO_SESSION
var _cached_status_message: String = "No session"
var _authentication_packet_timeout_secs: float = 15.0
var _supports_compression: bool = false
var _client_side_compression_threshold: int = 51200
var packet_timeouts: Array[int] = [15, 20, 35, 50]
var upload_low_transfer_rate_timeout: int = 120
var upload_low_transfer_rate_threshold: int = 50

var _event_callback: Callable = Callable()
var _reward_callback: Callable = Callable()
var _network_error_callback: Callable = Callable()
var _global_error_callback: Callable = Callable()
var _auto_reconnect_callback: Callable = Callable()


# Keep-alive transport

enum _Phase { IDLE, CONNECTING, REQUESTING, READING }

var _http: HTTPClient = null
var _http_phase: int = _Phase.IDLE
var _http_host: String = ""
var _http_port: int = -1
var _http_tls: bool = false
var _http_path: String = "/"
var _http_body: PackedByteArray = PackedByteArray()
var _http_request_state: RequestState = null
# Held until the connection is up, then handed to HTTPClient.request().
var _http_pending_headers: PackedStringArray = PackedStringArray()
var _http_pending_body: PackedByteArray = PackedByteArray()
var _http_has_pending: bool = false
func _init(client_ref: Node) -> void:
	_client_ref = client_ref
	_reset_error_cache()

func _process(_delta: float) -> void:
	# an in-flight response still has to be read even while the
	# queue is blocked, or a blocking call could never complete.
	_poll_http()
	update()

func get_app_id() -> String:
	return _app_id

func get_session_id() -> String:
	return _session_id

func sign_payload(payload: PackedByteArray) -> String:
	var profile: Callable = _app_profiles.get(_app_id, Callable())
	if not profile.is_valid():
		return _calculate_md5_bytes(payload + ("NO SECRET DEFINED FOR '%s'" % _app_id).to_utf8_buffer())
	return profile.call(payload)

func get_server_url() -> String:
	return _server_url

func get_is_authenticated() -> bool:
	return _is_authenticated

func get_received_packet_id() -> int:
	return _received_packet_id_checker

func initialize(server_url: String, app_id: String, secret_key: String) -> void:
	reset_communication()
	_expected_incoming_packet_id = NO_PACKET_EXPECTED
	_server_url = server_url

	var suffix := "/dispatcherv2"
	var format_url := server_url
	if format_url.ends_with(suffix):
		format_url = format_url.substr(0, format_url.length() - suffix.length())
	while format_url.length() > 0 and format_url.ends_with("/"):
		format_url = format_url.substr(0, format_url.length() - 1)

	_upload_url = format_url + "/uploader"
	_app_profiles[app_id] = func(payload: PackedByteArray) -> String:
		return _calculate_md5_bytes(payload + secret_key.to_utf8_buffer())
	_app_id = app_id
	_blocking_queue = false
	_initialized = true

# Initializes with a signing profile instead of a plaintext secret -- see
# BrainCloudNative.resolve_config's second callback argument.
func initialize_with_profile(server_url: String, app_id: String, sign_profile: Callable) -> void:
	reset_communication()
	_expected_incoming_packet_id = NO_PACKET_EXPECTED
	_server_url = server_url

	var suffix := "/dispatcherv2"
	var format_url := server_url
	if format_url.ends_with(suffix):
		format_url = format_url.substr(0, format_url.length() - suffix.length())
	while format_url.length() > 0 and format_url.ends_with("/"):
		format_url = format_url.substr(0, format_url.length() - 1)

	_upload_url = format_url + "/uploader"
	_app_profiles[app_id] = sign_profile
	_app_id = app_id
	_blocking_queue = false
	_initialized = true

func initialize_with_apps(server_url: String, default_app_id: String, app_id_secret_map: Dictionary) -> void:
	for app_id: String in app_id_secret_map:
		var secret_key: String = app_id_secret_map[app_id]
		_app_profiles[app_id] = func(payload: PackedByteArray) -> String:
			return _calculate_md5_bytes(payload + secret_key.to_utf8_buffer())
	initialize(server_url, default_app_id, app_id_secret_map.get(default_app_id, ""))

func register_event_callback(cb: Callable) -> void:
	_event_callback = cb

func deregister_event_callback() -> void:
	_event_callback = Callable()

func register_auto_reconnect_callback(cb: Callable) -> void:
	_auto_reconnect_callback = cb

func deregister_auto_reconnect_callback() -> void:
	_auto_reconnect_callback = Callable()

func enable_auto_reconnect(enabled: bool) -> void:
	_auto_reconnect_enabled = enabled

func get_auto_reconnect_enabled() -> bool:
	return _auto_reconnect_enabled

func register_reward_callback(cb: Callable) -> void:
	_reward_callback = cb

func deregister_reward_callback() -> void:
	_reward_callback = Callable()

func register_global_error_callback(cb: Callable) -> void:
	_global_error_callback = cb

func deregister_global_error_callback() -> void:
	_global_error_callback = Callable()

func register_network_error_callback(cb: Callable) -> void:
	_network_error_callback = cb

func deregister_network_error_callback() -> void:
	_network_error_callback = Callable()

func enable_network_error_message_caching(enabled: bool) -> void:
	_cache_messages_on_network_error = enabled

# Gzip outgoing request bodies that exceed the server-advertised threshold
# (compressIfLarger, defaults to 50KB). Responses are decompressed automatically by
# Godot's HTTPRequest (accept_gzip defaults to true).
func enable_compressed_requests(enabled: bool) -> void:
	_supports_compression = enabled

# Ask the server to gzip its responses (sent as the compressResponse auth param).
func enable_compressed_responses(enabled: bool) -> void:
	if _client_ref and _client_ref.authentication_service:
		_client_ref.authentication_service.compress_response = enabled

func enable_comms(value: bool) -> void:
	_enabled = value

func add_to_queue(call: ServerCall) -> void:
	if _initialized:
		_service_calls_waiting.append(call)
	else:
		call.on_failure(StatusCodes.CLIENT_NETWORK_ERROR, ReasonCodes.CLIENT_NOT_INITIALIZED, "Client not initialized")

func insert_end_of_bundle_marker() -> void:
	add_to_queue(EndOfBundleMarker.new())

func send_heartbeat() -> void:
	var sc := ServerCall.new(ServiceName.HEART_BEAT, ServiceOperation.READ, {})
	add_to_queue(sc)

func update() -> void:
	if not _initialized or not _enabled or _blocking_queue:
		return

	var bypass_timeout := false

	if _active_request != null:
		# Timeout check
		var elapsed := Time.get_ticks_msec() / 1000.0 - _active_request.time_sent
		var timeout := _get_packet_timeout(_active_request)
		if elapsed >= timeout or bypass_timeout:
			if not _resend_message(_active_request):
				var attempts: int = _active_request.retries + 1
				_active_request = null
				trigger_comms_error(
					StatusCodes.CLIENT_NETWORK_ERROR,
					ReasonCodes.CLIENT_NETWORK_ERROR_TIMEOUT,
					"Request TIMED OUT: no response from brainCloud within %.0fs, after %d attempt(s)" % [timeout, attempts])
	else:
		_active_request = _create_and_send_next_request_bundle()

	if _is_authenticated and not _blocking_queue:
		var now := Time.get_ticks_msec() / 1000.0
		if now - _last_time_packet_sent >= _idle_timeout_secs:
			send_heartbeat()

	if too_many_authentication_attempts():
		var now := Time.get_ticks_msec() / 1000.0
		if now - _authentication_timeout_start >= _authentication_timeout_duration:
			_kill_switch_engaged = false
			reset_kill_switch()

func trigger_comms_error(status: int, reason_code: int, status_message: String) -> void:
	var num_messages := max(1, _service_calls_in_progress.size())
	var bundle: Dictionary = {
		"packetId": _expected_incoming_packet_id,
		"responses": []
	}
	for i in range(num_messages):
		bundle["responses"].append({
			"status": status,
			"reason_code": reason_code,
			"status_message": status_message,
			"severity": "ERROR"
		})
	handle_response_bundle(JSON.stringify(bundle))

func handle_response_bundle(json_data: String) -> void:
	if _client_ref.logging_enabled:
		_client_ref.log("RESPONSE %s\n%s" % [Time.get_datetime_string_from_system(), json_data])

	var parse_result = JSON.parse_string(json_data)
	if parse_result == null or not parse_result is Dictionary:
		_cached_reason_code = ReasonCodes.JSON_PARSING_ERROR
		_cached_status_code = StatusCodes.CLIENT_NETWORK_ERROR
		_cached_status_message = "Received an invalid json format response"
		if _service_calls_in_progress.size() > 0:
			var sc := _service_calls_in_progress[0]
			_service_calls_in_progress.remove_at(0)
			sc.on_failure(_cached_status_code, _cached_reason_code, _cached_status_message)
		return

	var bundle_obj: Dictionary = parse_result
	var response_bundle: Array = bundle_obj.get("responses", [])
	var received_packet_id: int = bundle_obj.get("packetId", -1)
	_received_packet_id_checker = received_packet_id

	if received_packet_id != NO_PACKET_EXPECTED and (
		_expected_incoming_packet_id == NO_PACKET_EXPECTED or
		_expected_incoming_packet_id != received_packet_id
	):
		if _client_ref.logging_enabled:
			_client_ref.log("Dropping duplicate packet")
		for j in range(response_bundle.size()):
			if _service_calls_in_progress.size() > 0:
				_service_calls_in_progress.remove_at(0)
		return

	_expected_incoming_packet_id = NO_PACKET_EXPECTED

	for j in range(response_bundle.size()):
		var response: Dictionary = response_bundle[j]
		var status_code: int = response.get("status", 0)
		var sc: ServerCall = null

		if _service_calls_in_progress.size() > 0:
			sc = _service_calls_in_progress[0]
			_service_calls_in_progress.remove_at(0)

		if status_code == 200:
			reset_kill_switch()
			var service := sc.service if sc else ""
			var operation := sc.operation if sc else ""
			var _raw_data = response.get("data")
			var response_data: Dictionary = _raw_data if _raw_data is Dictionary else {}

			if service == ServiceName.AUTHENTICATE or service == ServiceName.IDENTITY:
				_authentication_packet_timeout_secs = 15.0
				_save_profile_and_session_ids(response_data)

			if operation == ServiceOperation.FULL_RESET or operation == ServiceOperation.LOGOUT:
				_is_authenticated = false
				_session_id = ""
				_client_ref.authentication_service.clear_saved_profile_id()
				_reset_error_cache()
			elif operation == ServiceOperation.AUTHENTICATE:
				_process_authenticate(response_data)
			elif operation == ServiceOperation.SWITCH_TO_CHILD_PROFILE or \
				 operation == ServiceOperation.SWITCH_TO_PARENT_PROFILE:
				_process_switch_response(response_data)

			_failed_authentication_attempts = 0

			if sc != null:
				sc.on_success(response)

			if _reward_callback.is_valid() and response_data.size() > 0:
				_check_and_fire_reward(operation, service, response_data)
		else:
			var reason_code: int = response.get("reason_code", 0)
			var operation := sc.operation if sc else ""

			if operation == ServiceOperation.AUTHENTICATE and not too_many_authentication_attempts():
				_failed_authentication_attempts += 1
				if too_many_authentication_attempts():
					_authentication_timeout_start = Time.get_ticks_msec() / 1000.0

			# If the authenticated session has expired and auto-reconnect (long session)
			# is enabled, silently re-authenticate and replay the lost call(s) instead of
			# surfacing the error. Mirrors the C# SDK's transparent reconnect behaviour.
			if reason_code == ReasonCodes.PLAYER_SESSION_EXPIRED and _auto_reconnect_enabled \
				and operation != ServiceOperation.AUTHENTICATE and _is_authenticated:
				_attempt_auto_reconnect(sc)
				return

			if reason_code in [ReasonCodes.PLAYER_SESSION_EXPIRED, ReasonCodes.NO_SESSION, ReasonCodes.PLAYER_SESSION_LOGGED_OUT]:
				_is_authenticated = false
				_session_id = ""
				_cached_status_code = status_code
				_cached_reason_code = reason_code
				_cached_status_message = response.get("status_message", "")

			if sc != null:
				sc.on_success(response)

			if _global_error_callback.is_valid():
				_global_error_callback.call(
					sc.service if sc else "",
					sc.operation if sc else "",
					status_code,
					reason_code,
					response
				)

			if sc != null:
				update_kill_switch(sc.service, sc.operation, status_code)

	var events = bundle_obj.get("events", null)
	if events != null and _event_callback.is_valid():
		_event_callback.call({"events": events})

func _check_and_fire_reward(operation: String, service: String, response_data: Dictionary) -> void:
	var rewards = null
	if operation == ServiceOperation.AUTHENTICATE:
		if response_data.has("rewards"):
			var outer: Variant = response_data["rewards"]
			if outer is Dictionary and outer.has("rewards"):
				var inner = outer["rewards"]
				if inner is Dictionary and inner.size() > 0:
					rewards = outer
	elif operation in [ServiceOperation.UPDATE, ServiceOperation.TRIGGER, ServiceOperation.TRIGGER_MULTIPLIED]:
		if response_data.has("rewards"):
			var inner = response_data["rewards"]
			if inner is Dictionary and inner.size() > 0:
				rewards = response_data

	if rewards != null:
		_reward_callback.call({"apiRewards": [{"rewards": rewards, "service": service, "operation": operation}]})

func _save_profile_and_session_ids(response_data: Dictionary) -> void:
	var session_id: String = response_data.get("sessionId", "")
	if session_id.length() > 0:
		_session_id = session_id
		_is_authenticated = true

	var profile_id: String = response_data.get("profileId", "")
	if profile_id.length() > 0:
		_client_ref.authentication_service.profile_id = profile_id

func _process_authenticate(json_data: Dictionary) -> void:
	if json_data.has("compressIfLarger"):
		_client_side_compression_threshold = json_data["compressIfLarger"]

	var player_session_expiry: float = float(json_data.get("playerSessionExpiry", 5 * 60))
	_idle_timeout_secs = player_session_expiry * 0.85

	if json_data.has("maxBundleMsgs"):
		_max_bundle_messages = json_data["maxBundleMsgs"]
	if json_data.has("maxKillCount"):
		_kill_switch_threshold = json_data["maxKillCount"]

	_reset_error_cache()
	_is_authenticated = true

func _process_switch_response(json_data: Dictionary) -> void:
	if json_data.has("switchToAppId"):
		_app_id = json_data["switchToAppId"]

func _create_and_send_next_request_bundle() -> RequestState:
	if _blocking_queue:
		for sc in _service_calls_in_timeout_queue:
			_service_calls_in_progress.insert(0, sc)
		_service_calls_in_timeout_queue.clear()
	else:
		if _service_calls_waiting.size() > 0:
			var num_messages := _service_calls_waiting.size()

			# Remove leading end-of-bundle markers; prioritize authenticate calls
			var i := 0
			while i < _service_calls_waiting.size():
				var call := _service_calls_waiting[i]
				if call.is_end_of_bundle:
					if i == 0:
						_service_calls_waiting.remove_at(0)
						num_messages -= 1
						continue
					else:
						num_messages = i
						_service_calls_waiting.remove_at(i)
						break
				if call.operation == ServiceOperation.AUTHENTICATE:
					if i != 0:
						_service_calls_waiting.remove_at(i)
						_service_calls_waiting.insert(0, call)
					num_messages = 1
					break
				i += 1

			num_messages = min(num_messages, _max_bundle_messages)
			if num_messages <= 0:
				return null

			if _service_calls_in_progress.size() > 0:
				_service_calls_in_progress.clear()

			_service_calls_in_progress = _service_calls_waiting.slice(0, num_messages)
			_service_calls_waiting = _service_calls_waiting.slice(num_messages)

	if _service_calls_in_progress.size() == 0:
		return null

	var request_state := RequestState.new()
	var message_list: Array = []
	var is_authorized := false

	for sc in _service_calls_in_progress:
		# Skip heartbeat if there are other messages
		if sc.service == ServiceName.HEART_BEAT and sc.operation == ServiceOperation.READ and \
			_service_calls_in_progress.size() > 1:
			continue

		var message: Dictionary = {
			"service": sc.service,
			"operation": sc.operation,
			"data": sc.data
		}
		message_list.append(message)

		if sc.operation == ServiceOperation.AUTHENTICATE:
			request_state.packet_no_retry = true

		if sc.operation in [
			ServiceOperation.AUTHENTICATE,
			ServiceOperation.RESET_EMAIL_PASSWORD,
			ServiceOperation.RESET_EMAIL_PASSWORD_ADVANCED,
			ServiceOperation.RESET_UNIVERSAL_ID_PASSWORD,
			ServiceOperation.RESET_UNIVERSAL_ID_PASSWORD_ADVANCED,
			ServiceOperation.GET_SERVER_VERSION
		]:
			is_authorized = true

		if sc.operation in [ServiceOperation.FULL_RESET, ServiceOperation.LOGOUT]:
			request_state.packet_requires_long_timeout = true

	request_state.packet_id = _packet_id
	_expected_incoming_packet_id = _packet_id
	request_state.message_list = message_list
	_packet_id += 1

	if not _kill_switch_engaged and not too_many_authentication_attempts():
		if _is_authenticated or is_authorized:
			_internal_send_message(request_state)
		else:
			_fake_error_response(request_state, _cached_status_code, _cached_reason_code, _cached_status_message)
			return null
	else:
		if too_many_authentication_attempts():
			_fake_error_response(
				request_state,
				StatusCodes.CLIENT_NETWORK_ERROR,
				ReasonCodes.CLIENT_DISABLED_FAILED_AUTH,
				"Client disabled due to repeated Authentication failures. Wait 30 seconds.")
		else:
			_fake_error_response(
				request_state,
				StatusCodes.CLIENT_NETWORK_ERROR,
				ReasonCodes.CLIENT_DISABLED,
				"Client disabled due to repeated errors from a single API call")
		return null

	return request_state

func _internal_send_message(request_state: RequestState) -> void:
	var packet: Dictionary = {
		"packetId": request_state.packet_id,
		"sessionId": _session_id,
		"messages": request_state.message_list
	}
	if _app_id.length() > 0:
		packet["gameId"] = _app_id

	var json_string := JSON.stringify(packet)
	# Sign the uncompressed body — the server decompresses before validating the signature.
	var sig := sign_payload(json_string.to_utf8_buffer())

	var headers: Array[String] = [
		"Content-Type: application/json;charset=utf-8",
		"X-SIG: " + sig,
		"X-APPID: " + _app_id
	]

	# Gzip the request body once it exceeds the server-advertised threshold.
	var body_bytes := json_string.to_utf8_buffer()
	if _supports_compression and body_bytes.size() >= _client_side_compression_threshold:
		body_bytes = body_bytes.compress(FileAccess.COMPRESSION_GZIP)
		headers.append("Content-Encoding: gzip")

	request_state.request_string = json_string
	request_state.signature = sig
	request_state.time_sent = Time.get_ticks_msec() / 1000.0

	if _client_ref.logging_enabled:
		_client_ref.log("REQUEST\n%s" % json_string)

	# A resend reuses the same connection, but anything still on the wire from the
	# previous attempt has to go first or the response stream would be interleaved.
	if _http_phase != _Phase.IDLE:
		_http_reset_connection()

	_http_request_state = request_state
	_http_body = PackedByteArray()
	_http_pending_headers = PackedStringArray(headers)
	_http_pending_body = body_bytes
	_http_has_pending = true
	_http_ensure_connected()

	_reset_idle_timer()

# Godot's HTTPRequest.Result values
#
# The bare integer ("result=2") means opening the source to decode it, which is no use
# in a CI log three days later. These turn it into "RESULT_CANT_CONNECT (2) - could not
# open a connection ...".

const _HTTP_RESULT_INFO := {
	HTTPRequest.RESULT_CHUNKED_BODY_SIZE_MISMATCH: ["RESULT_CHUNKED_BODY_SIZE_MISMATCH", "the response body length did not match its chunked encoding"],
	HTTPRequest.RESULT_CANT_CONNECT:               ["RESULT_CANT_CONNECT", "could not open a connection to the server - refused, dropped, or blocked"],
	HTTPRequest.RESULT_CANT_RESOLVE:               ["RESULT_CANT_RESOLVE", "the server hostname could not be resolved (DNS)"],
	HTTPRequest.RESULT_CONNECTION_ERROR:           ["RESULT_CONNECTION_ERROR", "the connection failed or was reset while in use"],
	HTTPRequest.RESULT_TLS_HANDSHAKE_ERROR:        ["RESULT_TLS_HANDSHAKE_ERROR", "the TLS handshake failed - certificate or protocol mismatch"],
	HTTPRequest.RESULT_NO_RESPONSE:                ["RESULT_NO_RESPONSE", "the connection closed before any response arrived"],
	HTTPRequest.RESULT_BODY_SIZE_LIMIT_EXCEEDED:   ["RESULT_BODY_SIZE_LIMIT_EXCEEDED", "the response body exceeded the configured size limit"],
	HTTPRequest.RESULT_BODY_DECOMPRESS_FAILED:     ["RESULT_BODY_DECOMPRESS_FAILED", "the response body could not be decompressed"],
	HTTPRequest.RESULT_REQUEST_FAILED:             ["RESULT_REQUEST_FAILED", "the request could not be sent"],
	HTTPRequest.RESULT_DOWNLOAD_FILE_CANT_OPEN:    ["RESULT_DOWNLOAD_FILE_CANT_OPEN", "the download file could not be opened"],
	HTTPRequest.RESULT_DOWNLOAD_FILE_WRITE_ERROR:  ["RESULT_DOWNLOAD_FILE_WRITE_ERROR", "the download file could not be written"],
	HTTPRequest.RESULT_REDIRECT_LIMIT_REACHED:     ["RESULT_REDIRECT_LIMIT_REACHED", "too many HTTP redirects"],
	HTTPRequest.RESULT_TIMEOUT:                    ["RESULT_TIMEOUT", "the request TIMED OUT waiting for the server to respond"],
}

# "RESULT_CANT_CONNECT (2) - could not open a connection ...", or a bare number for a
# value a future Godot release adds that is not in the table above.
static func _describe_http_result(result: int) -> String:
	if _HTTP_RESULT_INFO.has(result):
		var info: Array = _HTTP_RESULT_INFO[result]
		return "%s (%d) - %s" % [info[0], result, info[1]]
	return "UNKNOWN (%d)" % result

# Splits _server_url into the pieces HTTPClient needs. Re-derived on every send
# because initialize() / a child-app switch can change the URL underneath us.
func _http_parse_url(url: String) -> void:
	_http_tls = url.begins_with("https://")
	var rest := url
	var scheme_end := url.find("://")
	if scheme_end >= 0:
		rest = url.substr(scheme_end + 3)
	var slash := rest.find("/")
	var host_port := rest if slash < 0 else rest.substr(0, slash)
	_http_path = "/" if slash < 0 else rest.substr(slash)
	_http_port = 443 if _http_tls else 80
	var colon := host_port.rfind(":")
	if colon > 0:
		_http_port = int(host_port.substr(colon + 1))
		host_port = host_port.substr(0, colon)
	_http_host = host_port

func _http_reset_connection() -> void:
	if _http != null:
		_http.close()
	_http_phase = _Phase.IDLE
	_http_has_pending = false

func _http_ensure_connected() -> void:
	var prev_host := _http_host
	var prev_port := _http_port
	_http_parse_url(_server_url)
	if _http != null and (_http_host != prev_host or _http_port != prev_port):
		# Pointed somewhere else now - the old socket is no use.
		_http_reset_connection()
	if _http == null:
		_http = HTTPClient.new()

	var st := _http.get_status()
	if st == HTTPClient.STATUS_CONNECTED:
		# The whole point: the socket from the previous call is still open, so send now
		# rather than waiting a frame for the poll to notice.
		_http_issue_pending()
		return
	if st == HTTPClient.STATUS_RESOLVING or st == HTTPClient.STATUS_CONNECTING:
		_http_phase = _Phase.CONNECTING
		return

	var tls_options: TLSOptions = TLSOptions.client() if _http_tls else null
	var err := _http.connect_to_host(_http_host, _http_port, tls_options)
	if err != OK:
		_http_fail(HTTPRequest.RESULT_CANT_CONNECT)
		return
	_http_phase = _Phase.CONNECTING

func _http_issue_pending() -> void:
	# request_raw, not request: the body may already be gzipped bytes.
	var err := _http.request_raw(HTTPClient.METHOD_POST, _http_path, _http_pending_headers, _http_pending_body)
	_http_has_pending = false
	if err != OK:
		_http_fail(HTTPRequest.RESULT_REQUEST_FAILED)
		return
	_http_phase = _Phase.REQUESTING

# Drives the connect -> request -> read cycle one frame at a time. Called from
# _process ahead of update() so a response is still read while the queue is blocked.
func _poll_http() -> void:
	if _http == null or _http_phase == _Phase.IDLE:
		return

	_http.poll()
	var st := _http.get_status()

	# Map HTTPClient's failure states onto the HTTPRequest.Result codes the rest of the
	# file already speaks, so _describe_http_result keeps producing the same messages.
	if st == HTTPClient.STATUS_CANT_RESOLVE:
		_http_fail(HTTPRequest.RESULT_CANT_RESOLVE)
		return
	if st == HTTPClient.STATUS_CANT_CONNECT:
		_http_fail(HTTPRequest.RESULT_CANT_CONNECT)
		return
	if st == HTTPClient.STATUS_TLS_HANDSHAKE_ERROR:
		_http_fail(HTTPRequest.RESULT_TLS_HANDSHAKE_ERROR)
		return
	if st == HTTPClient.STATUS_CONNECTION_ERROR:
		_http_fail(HTTPRequest.RESULT_CONNECTION_ERROR)
		return

	match _http_phase:
		_Phase.CONNECTING:
			if st == HTTPClient.STATUS_CONNECTED and _http_has_pending:
				_http_issue_pending()
			elif st == HTTPClient.STATUS_DISCONNECTED:
				# Keep-alive socket reaped by the server while idle. Reconnect and retry
				# the send - this is routine, not an error worth surfacing.
				if _http_has_pending:
					_http_ensure_connected()
				else:
					_http_phase = _Phase.IDLE
		_Phase.REQUESTING:
			if st == HTTPClient.STATUS_BODY:
				_http_phase = _Phase.READING
			elif st == HTTPClient.STATUS_CONNECTED or st == HTTPClient.STATUS_DISCONNECTED:
				# Responded with no body at all.
				_http_complete()
		_Phase.READING:
			if st == HTTPClient.STATUS_BODY:
				var chunk := _http.read_response_body_chunk()
				if chunk.size() > 0:
					_http_body.append_array(chunk)
			else:
				# Left BODY - the response is complete. Status is CONNECTED when the
				# server honoured keep-alive, which is the case we want.
				_http_complete()

func _http_complete() -> void:
	var code := _http.get_response_code()
	var headers := _http.get_response_headers_as_dictionary()
	var body := _http_body
	_http_body = PackedByteArray()
	_http_phase = _Phase.IDLE

	# We never send Accept-Encoding, so a gzipped response should not happen - but
	# honour one rather than hand JSON.parse a blob of binary if a proxy adds it.
	for key in headers:
		if String(key).to_lower() == "content-encoding" and String(headers[key]).to_lower().contains("gzip"):
			var inflated := body.decompress_dynamic(-1, FileAccess.COMPRESSION_GZIP)
			if inflated.size() > 0:
				body = inflated
			break

	_deliver_response(HTTPRequest.RESULT_SUCCESS, code, body, _http_request_state)

func _http_fail(result: int) -> void:
	var rs: RequestState = _http_request_state
	_http_reset_connection()
	_deliver_response(result, 0, PackedByteArray(), rs)
func _deliver_response(result: int, response_code: int, body: PackedByteArray, request_state: RequestState) -> void:
	_http_request_state = null

	if request_state == null or _active_request != request_state:
		return

	_active_request = null

	if result != HTTPRequest.RESULT_SUCCESS:
		var error_msg := "Network error: " + _describe_http_result(result)
		trigger_comms_error(StatusCodes.CLIENT_NETWORK_ERROR, ReasonCodes.CLIENT_NETWORK_ERROR_TIMEOUT, error_msg)
		return

	if response_code == 200:
		_reset_idle_timer()
		handle_response_bundle(body.get_string_from_utf8())
	elif response_code in [502, 503, 504]:
		_client_ref.log("Server busy (%d), retrying..." % response_code)
		if not _resend_message(request_state):
			trigger_comms_error(StatusCodes.CLIENT_NETWORK_ERROR, ReasonCodes.CLIENT_NETWORK_ERROR_TIMEOUT, "Server unavailable")
	else:
		var error_response := body.get_string_from_utf8()
		trigger_comms_error(404, response_code, error_response)

func _resend_message(request_state: RequestState) -> bool:
	if request_state.retries >= _get_max_retries_for_packet(request_state):
		return false
	request_state.retries += 1
	_internal_send_message(request_state)
	return true

func _fake_error_response(request_state: RequestState, status_code: int, reason_code: int, status_message: String) -> void:
	_reset_idle_timer()
	trigger_comms_error(status_code, reason_code, status_message)
	_active_request = null

func _get_max_retries_for_packet(request_state: RequestState) -> int:
	if request_state.packet_no_retry:
		return 0
	return packet_timeouts.size()

func _get_packet_timeout(request_state: RequestState) -> float:
	if request_state.packet_no_retry:
		return _authentication_packet_timeout_secs
	var retry := request_state.retries
	if retry >= packet_timeouts.size():
		return float(packet_timeouts[-1]) if packet_timeouts.size() > 0 else 10.0
	return float(packet_timeouts[retry])

func _reset_idle_timer() -> void:
	_last_time_packet_sent = Time.get_ticks_msec() / 1000.0

func _reset_error_cache() -> void:
	_cached_status_code = StatusCodes.FORBIDDEN
	_cached_reason_code = ReasonCodes.NO_SESSION
	_cached_status_message = "No session"

func reset_communication() -> void:
	_http_reset_connection()
	_is_authenticated = false
	_blocking_queue = false
	_service_calls_waiting.clear()
	_service_calls_in_progress.clear()
	_service_calls_in_timeout_queue.clear()
	_active_request = null
	if _client_ref and _client_ref.authentication_service:
		_client_ref.authentication_service.profile_id = ""
	_session_id = ""
	_packet_id = 0

func shut_down() -> void:
	_service_calls_waiting.clear()
	_active_request = null
	reset_communication()

# Triggered when an authenticated session expires and auto-reconnect is enabled.
# Preserves the call that failed (plus any others from the same bundle), resets the
# packet state, and queues a silent anonymous re-authentication. The lost calls are
# replayed once the session is restored (see _on_auto_reconnect_response).
func _attempt_auto_reconnect(expired_call: ServerCall) -> void:
	var calls_to_replay: Array[ServerCall] = []
	if expired_call != null:
		calls_to_replay.append(expired_call)
	calls_to_replay.append_array(_service_calls_in_progress)
	_service_calls_in_progress.clear()

	if _client_ref.logging_enabled:
		_client_ref.log("Session expired. Attempting reconnect...")

	_packet_id = 0
	_expected_incoming_packet_id = NO_PACKET_EXPECTED

	# Re-authenticate anonymously using only the stored anonymous/profile ids - we never
	# store or replay passwords. The auth call is prioritized ahead of any queued calls.
	var auth_call: ServerCall = _client_ref.authentication_service.build_anonymous_reconnect_call()
	auth_call.response_received.connect(
		_on_auto_reconnect_response.bind(calls_to_replay), CONNECT_ONE_SHOT)
	_service_calls_waiting.insert(0, auth_call)

func _on_auto_reconnect_response(auth_response: Dictionary, calls_to_replay: Array[ServerCall]) -> void:
	if auth_response.get("status", 0) == StatusCodes.OK:
		# Session restored - re-queue the lost calls so the next update loop resends them.
		_client_ref.log("Auto-reconnect: session restored, replaying %d call(s)" % calls_to_replay.size())
		for sc in calls_to_replay:
			_service_calls_waiting.append(sc)
		if _auto_reconnect_callback.is_valid():
			_auto_reconnect_callback.call(auth_response)
	else:
		# Re-authentication failed - disable auto-reconnect to avoid an infinite loop and
		# surface the failure to the original callers.
		_client_ref.log("Auto-reconnect: re-authentication failed, disabling auto-reconnect")
		_auto_reconnect_enabled = false
		if _auto_reconnect_callback.is_valid():
			_auto_reconnect_callback.call(auth_response)
		for sc in calls_to_replay:
			sc.on_failure(
				auth_response.get("status", StatusCodes.CLIENT_NETWORK_ERROR),
				auth_response.get("reason_code", ReasonCodes.NO_SESSION),
				auth_response.get("status_message", "Re-authentication failed"))

func retry_cached_messages() -> void:
	if _blocking_queue:
		if _active_request != null:
			_active_request = null
		_packet_id -= 1
		_active_request = _create_and_send_next_request_bundle()
		_blocking_queue = false

func flush_cached_messages(send_api_error_callbacks: bool) -> void:
	if _blocking_queue:
		_active_request = null
		var calls_to_process: Array[ServerCall] = []
		calls_to_process.append_array(_service_calls_in_timeout_queue)
		_service_calls_in_timeout_queue.clear()
		calls_to_process.append_array(_service_calls_waiting)
		_service_calls_waiting.clear()
		_service_calls_in_progress.clear()

		if send_api_error_callbacks:
			for sc in calls_to_process:
				sc.on_failure(StatusCodes.CLIENT_NETWORK_ERROR, ReasonCodes.CLIENT_NETWORK_ERROR_TIMEOUT,
					"Request TIMED OUT: cancelled because an earlier request to brainCloud timed out")
		_blocking_queue = false

func update_kill_switch(service: String, operation: String, status_code: int) -> void:
	if status_code == StatusCodes.CLIENT_NETWORK_ERROR:
		return

	if _kill_switch_service.length() == 0:
		_kill_switch_service = service
		_kill_switch_operation = operation
		_kill_switch_error_count += 1
	elif service == _kill_switch_service and operation == _kill_switch_operation:
		_kill_switch_error_count += 1

	if not _kill_switch_engaged and _kill_switch_error_count >= _kill_switch_threshold:
		_kill_switch_engaged = true
		_client_ref.log("Client disabled due to repeated errors: %s | %s" % [service, operation])

	if operation == ServiceOperation.AUTHENTICATE:
		if too_many_authentication_attempts():
			_kill_switch_engaged = true
			_authentication_timeout_start = Time.get_ticks_msec() / 1000.0

func reset_kill_switch() -> void:
	_kill_switch_error_count = 0
	_kill_switch_service = ""
	_kill_switch_operation = ""
	_failed_authentication_attempts = 0

func too_many_authentication_attempts() -> bool:
	return _failed_authentication_attempts >= _identical_failed_auth_attempt_threshold

func is_authenticate_request_in_progress() -> bool:
	for sc in _service_calls_in_progress:
		if sc.operation == ServiceOperation.AUTHENTICATE:
			return true
	return false

func set_packet_timeouts_to_default() -> void:
	packet_timeouts = [15, 20, 35, 50]

func _calculate_md5_bytes(data: PackedByteArray) -> String:
	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_MD5)
	ctx.update(data)
	return ctx.finish().hex_encode()
