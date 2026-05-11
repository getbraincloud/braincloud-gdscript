# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudRTT
extends RefCounted

var _client_ref: BrainCloudClient
var _rtt_enabled: bool = false
var _event_callback: Callable
var _success_cb: Callable
var _failure_cb: Callable

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

## Enable RTT. connection_type is "WEBSOCKET" or "TCP".
func enable_rtt(connection_type: String, success_cb: Callable, failure_cb: Callable) -> void:
	_success_cb = success_cb
	_failure_cb = failure_cb
	_rtt_enabled = true
	var data := {
		"connectionType": connection_type
	}
	var sc := ServerCall.new(ServiceName.RTT_REGISTRATION, ServiceOperation.RTT_REQUEST_CLIENT_CONNECTION, data)
	_client_ref.comms.add_to_queue(sc)
	var result: Dictionary = await sc.response_received
	if result.get("status", 0) == 200:
		if _success_cb.is_valid():
			_success_cb.call(result)
	else:
		_rtt_enabled = false
		if _failure_cb.is_valid():
			_failure_cb.call(result)

func disable_rtt() -> void:
	_rtt_enabled = false

func is_rtt_enabled() -> bool:
	return _rtt_enabled

func register_rtt_event_callback(cb: Callable) -> void:
	_event_callback = cb

func deregister_rtt_event_callback() -> void:
	_event_callback = Callable()

func request_client_connection() -> Dictionary:
	return await _send(ServiceOperation.RTT_REQUEST_CLIENT_CONNECTION, {})

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.RTT_REGISTRATION, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
