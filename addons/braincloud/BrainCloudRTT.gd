# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudRTT
extends RefCounted

var _client_ref: BrainCloudClient
var _rtt_comms: BrainCloudRTTComms
var _event_callback: Callable
var _success_cb: Callable
var _failure_cb: Callable
var _heart_beat_seconds: int = 10

func _init(client_ref: BrainCloudClient, rtt_comms: BrainCloudRTTComms) -> void:
	_client_ref = client_ref
	_rtt_comms = rtt_comms

func enable_rtt(connection_type: String, success_cb: Callable, failure_cb: Callable) -> void:
	_success_cb = success_cb
	_failure_cb = failure_cb

	var sc := ServerCall.new(ServiceName.RTT_REGISTRATION, ServiceOperation.RTT_REQUEST_CLIENT_CONNECTION, {"connectionType": connection_type})
	_client_ref.comms.add_to_queue(sc)
	var result: Dictionary = await sc.response_received

	if result.get("status", 0) != 200:
		if _failure_cb.is_valid():
			_failure_cb.call(result)
		return

	var data: Dictionary = result.get("data", {})
	var endpoints: Array = data.get("endpoints", [])
	var auth: Dictionary = data.get("auth", {})
	var ws_endpoint: Dictionary = {}
	for ep in endpoints:
		if ep.get("protocol", "") == "ws":
			ws_endpoint = ep
			break

	if ws_endpoint.is_empty():
		var err_resp := {"status": 900, "reason_code": 0, "status_message": "No WebSocket endpoint in RTT response"}
		if _failure_cb.is_valid():
			_failure_cb.call(err_resp)
		return

	_rtt_comms.set_heart_beat_seconds(_heart_beat_seconds)
	_rtt_comms.connect_ws(ws_endpoint, auth)
	var ws_result: Dictionary = await _rtt_comms.connect_result

	if ws_result.get("status", 0) == 200:
		if _success_cb.is_valid():
			_success_cb.call(ws_result)
	else:
		if _failure_cb.is_valid():
			_failure_cb.call(ws_result)

func disable_rtt() -> void:
	_rtt_comms.disconnect_ws()

func is_rtt_enabled() -> bool:
	return _rtt_comms.is_ws_connected()

func register_rtt_event_callback(cb: Callable) -> void:
	_event_callback = cb
	_rtt_comms.register_event_callback("event", cb)

func deregister_rtt_event_callback() -> void:
	_event_callback = Callable()
	_rtt_comms.deregister_event_callback("event")

func register_rtt_lobby_callback(cb: Callable) -> void:
	_rtt_comms.register_event_callback("lobby", cb)

func deregister_rtt_lobby_callback() -> void:
	_rtt_comms.deregister_event_callback("lobby")

func register_rtt_chat_callback(cb: Callable) -> void:
	_rtt_comms.register_event_callback("chat", cb)

func deregister_rtt_chat_callback() -> void:
	_rtt_comms.deregister_event_callback("chat")

func register_rtt_presence_callback(cb: Callable) -> void:
	_rtt_comms.register_event_callback("presence", cb)

func deregister_rtt_presence_callback() -> void:
	_rtt_comms.deregister_event_callback("presence")

func set_rtt_heart_beat_seconds(secs: int) -> void:
	_heart_beat_seconds = secs
	_rtt_comms.set_heart_beat_seconds(secs)

func get_rtt_connection_id() -> String:
	return _rtt_comms.get_connection_id()

func request_client_connection() -> Dictionary:
	return await _send(ServiceOperation.RTT_REQUEST_CLIENT_CONNECTION, {})

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.RTT_REGISTRATION, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
