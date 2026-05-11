# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudRelay
extends RefCounted

var _client_ref: BrainCloudClient
var _connected: bool = false
var _relay_callback: Callable
var _system_callback: Callable
var _success_cb: Callable
var _failure_cb: Callable

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

func relay_connect(connect_options: Dictionary, success_cb: Callable, failure_cb: Callable) -> void:
	_success_cb = success_cb
	_failure_cb = failure_cb
	var sc := ServerCall.new(ServiceName.RELAY, ServiceOperation.RELAY_CONNECT, connect_options)
	_client_ref.comms.add_to_queue(sc)
	var result: Dictionary = await sc.response_received
	if result.get("status", 0) == 200:
		_connected = true
		if _success_cb.is_valid():
			_success_cb.call(result)
	else:
		if _failure_cb.is_valid():
			_failure_cb.call(result)

func relay_disconnect() -> void:
	_connected = false
	var sc := ServerCall.new(ServiceName.RELAY, ServiceOperation.RELAY_DISCONNECT, {})
	_client_ref.comms.add_to_queue(sc)

func relay_is_connected() -> bool:
	return _connected

func send(data: PackedByteArray, to_net_id: int, reliable: bool, ordered: bool, channel: int) -> void:
	# Relay send is handled at the transport layer; this stub records intent.
	pass

func register_relay_callback(cb: Callable) -> void:
	_relay_callback = cb

func deregister_relay_callback() -> void:
	_relay_callback = Callable()

func register_system_callback(cb: Callable) -> void:
	_system_callback = cb

func deregister_system_callback() -> void:
	_system_callback = Callable()
