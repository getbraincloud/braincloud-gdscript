# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudRelay
extends RefCounted

const TO_ALL_PLAYERS := 0xFF

const CHANNEL_HIGH_PRIORITY_1 := 0
const CHANNEL_HIGH_PRIORITY_2 := 1
const CHANNEL_NORMAL_PRIORITY  := 2
const CHANNEL_LOW_PRIORITY     := 3

var _client_ref: BrainCloudClient
var _relay_comms: BrainCloudRelayComms
var _success_cb: Callable
var _failure_cb: Callable

func _init(client_ref: BrainCloudClient, relay_comms: BrainCloudRelayComms) -> void:
	_client_ref = client_ref
	_relay_comms = relay_comms

## connect_options keys: host, port, ssl, cxId, lobbyId, passcode
func relay_connect(connect_options: Dictionary, success_cb: Callable, failure_cb: Callable) -> void:
	_success_cb = success_cb
	_failure_cb = failure_cb

	var host: String = connect_options.get("host", "")
	var port: int = connect_options.get("port", 9301)
	var use_ssl: bool = connect_options.get("ssl", false)
	var cx_id: String = connect_options.get("cxId", "")
	var lobby_id: String = connect_options.get("lobbyId", "")
	var passcode: String = connect_options.get("passcode", "")

	_relay_comms.connect_relay(host, port, use_ssl, cx_id, lobby_id, passcode)
	var result: Dictionary = await _relay_comms.connect_result

	if result.get("status", 0) == 200:
		if _success_cb.is_valid():
			_success_cb.call(result)
	else:
		if _failure_cb.is_valid():
			_failure_cb.call(result)

func relay_disconnect() -> void:
	_relay_comms.disconnect_relay()

func relay_is_connected() -> bool:
	return _relay_comms.is_relay_connected()

func send(data: PackedByteArray, to_net_id: int, reliable: bool, ordered: bool, channel: int) -> void:
	_relay_comms.send_relay(data, to_net_id, reliable, ordered, channel)

func register_relay_callback(cb: Callable) -> void:
	_relay_comms.register_relay_callback(cb)

func deregister_relay_callback() -> void:
	_relay_comms.deregister_relay_callback()

func register_system_callback(cb: Callable) -> void:
	_relay_comms.register_system_callback(cb)

func deregister_system_callback() -> void:
	_relay_comms.deregister_system_callback()

func get_net_id() -> int:
	return _relay_comms.get_net_id()

func get_ping() -> int:
	return _relay_comms.get_ping()
