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
var _app_id_secret_map: Dictionary = {}
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

func _init(client_ref: Node) -> void:
	_client_ref = client_ref
	_reset_error_cache()

func _process(_delta: float) -> void:
	update()

func get_app_id() -> String:
	return _app_id

func get_session_id() -> String:
	return _session_id

func get_secret_key() -> String:
	return _app_id_secret_map.get(_app_id, "NO SECRET DEFINED FOR '%s'" % _app_id)

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
	_app_id_secret_map[app_id] = secret_key
	_app_id = app_id
	_blocking_queue = false
	_initialized = true

func initialize_with_apps(server_url: String, default_app_id: String, app_id_secret_map: Dictionary) -> void:
	_app_id_secret_map.clear()
	_app_id_secret_map.merge(app_id_secret_map)
	initialize(server_url, default_app_id, _app_id_secret_map.get(default_app_id, ""))

func register_event_callback(cb: Callable) -> void:
	_event_callback = cb

func deregister_event_callback() -> void:
	_event_callback = Callable()

func register_auto_reconnect_callback(cb: Callable) -> void:
	_auto_reconnect_callback = cb

func deregister_auto_reconnect_callback() -> void:
	_auto_reconnect_callback = Callable()

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
		var http := _active_request.http_request
		if http == null or http.get_http_client_status() == HTTPClient.STATUS_DISCONNECTED:
			# Response came back via callback; just check if it's done
			pass
		# Timeout check
		var elapsed := Time.get_ticks_msec() / 1000.0 - _active_request.time_sent
		var timeout := _get_packet_timeout(_active_request)
		if elapsed >= timeout or bypass_timeout:
			if not _resend_message(_active_request):
				_active_request = null
				trigger_comms_error(
					StatusCodes.CLIENT_NETWORK_ERROR,
					ReasonCodes.CLIENT_NETWORK_ERROR_TIMEOUT,
					"Timeout trying to reach brainCloud server")
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
	var sig := _calculate_md5(json_string + get_secret_key())

	var headers := PackedStringArray([
		"Content-Type: application/json;charset=utf-8",
		"X-SIG: " + sig,
		"X-APPID: " + _app_id
	])

	request_state.request_string = json_string
	request_state.signature = sig
	request_state.time_sent = Time.get_ticks_msec() / 1000.0

	if _client_ref.logging_enabled:
		_client_ref.log("REQUEST\n%s" % json_string)

	var http_request := HTTPRequest.new()
	_client_ref.add_child(http_request)
	http_request.request_completed.connect(_on_request_completed.bind(request_state, http_request))
	http_request.request(_server_url, headers, HTTPClient.METHOD_POST, json_string)
	request_state.http_request = http_request

	_reset_idle_timer()

func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, request_state: RequestState, http_request: HTTPRequest) -> void:
	http_request.queue_free()
	request_state.http_request = null

	if _active_request != request_state:
		return

	_active_request = null

	if result != HTTPRequest.RESULT_SUCCESS:
		var error_msg := "Network error: result=%d" % result
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
					"Timeout trying to reach brainCloud server")
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

func _calculate_md5(input: String) -> String:
	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_MD5)
	ctx.update(input.to_utf8_buffer())
	return ctx.finish().hex_encode()
