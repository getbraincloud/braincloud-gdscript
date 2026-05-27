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

## Enables Real-Time Tech (RTT) for the current session.
## Establishes a WebSocket connection for receiving real-time events.
##
## @param connection_type The connection type (e.g. "WEBSOCKET")
## @param success_cb Callable invoked on successful connection
## @param failure_cb Callable invoked if connection fails
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

## Disables RTT and closes the WebSocket connection.
func disable_rtt() -> void:
	_rtt_comms.disconnect_ws()

## Returns true if the RTT WebSocket connection is currently active.
func is_rtt_enabled() -> bool:
	return _rtt_comms.is_ws_connected()

## Registers a callback for incoming RTT event messages.
##
## @param cb Callable to invoke when an event message is received
func register_rtt_event_callback(cb: Callable) -> void:
	_event_callback = cb
	_rtt_comms.register_event_callback("event", cb)

## Deregisters the RTT event callback.
func deregister_rtt_event_callback() -> void:
	_event_callback = Callable()
	_rtt_comms.deregister_event_callback("event")

## Registers a callback for incoming RTT lobby messages.
##
## @param cb Callable to invoke when a lobby message is received
func register_rtt_lobby_callback(cb: Callable) -> void:
	_rtt_comms.register_event_callback("lobby", cb)

## Deregisters the RTT lobby callback.
func deregister_rtt_lobby_callback() -> void:
	_rtt_comms.deregister_event_callback("lobby")

## Registers a callback for incoming RTT chat messages.
##
## @param cb Callable to invoke when a chat message is received
func register_rtt_chat_callback(cb: Callable) -> void:
	_rtt_comms.register_event_callback("chat", cb)

## Deregisters the RTT chat callback.
func deregister_rtt_chat_callback() -> void:
	_rtt_comms.deregister_event_callback("chat")

## Registers a callback for incoming RTT presence messages.
##
## @param cb Callable to invoke when a presence message is received
func register_rtt_presence_callback(cb: Callable) -> void:
	_rtt_comms.register_event_callback("presence", cb)

## Deregisters the RTT presence callback.
func deregister_rtt_presence_callback() -> void:
	_rtt_comms.deregister_event_callback("presence")

## Sets the RTT heartbeat interval in seconds.
##
## @param secs The heartbeat interval in seconds
func set_rtt_heart_beat_seconds(secs: int) -> void:
	_heart_beat_seconds = secs
	_rtt_comms.set_heart_beat_seconds(secs)

## Returns the current RTT connection id.
func get_rtt_connection_id() -> String:
	return _rtt_comms.get_connection_id()

## Requests a client connection for RTT.
##
## Service Name - RTTRegistration[br]
## Service Operation - REQUEST_CLIENT_CONNECTION
func request_client_connection() -> Dictionary:
	return await _send(ServiceOperation.RTT_REQUEST_CLIENT_CONNECTION, {})

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.RTT_REGISTRATION, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
