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

## Connects to a relay server.
##
## @param connect_options Dictionary with keys: host, port, ssl, lobbyId, passcode
## @param success_cb Callable invoked on successful connection
## @param failure_cb Callable invoked if connection fails
func relay_connect(connect_options: Dictionary, success_cb: Callable, failure_cb: Callable) -> void:
	_success_cb = success_cb
	_failure_cb = failure_cb

	var host: String = connect_options.get("host", "")
	var port: int = connect_options.get("port", 9301)
	var use_ssl: bool = connect_options.get("ssl", false)
	var lobby_id: String = connect_options.get("lobbyId", "")
	var passcode: String = connect_options.get("passcode", "")

	_relay_comms.connect_relay(host, port, use_ssl, lobby_id, passcode)
	var result: Dictionary = await _relay_comms.connect_result

	if result.get("status", 0) == 200:
		if _success_cb.is_valid():
			_success_cb.call(result)
	else:
		if _failure_cb.is_valid():
			_failure_cb.call(result)

## Disconnects from the relay server.
func relay_disconnect() -> void:
	_relay_comms.disconnect_relay()

## Returns true if currently connected to a relay server.
func relay_is_connected() -> bool:
	return _relay_comms.is_relay_connected()

## Sends data to a player via the relay server.
##
## @param data The data to send as a PackedByteArray
## @param to_net_id The net id of the target player. Use TO_ALL_PLAYERS (0xFF) to broadcast
## @param reliable Whether to send the data reliably
## @param ordered Whether to maintain message order
## @param channel The channel to send on (CHANNEL_HIGH_PRIORITY_1 through CHANNEL_LOW_PRIORITY)
func send(data: PackedByteArray, to_net_id: int, reliable: bool, ordered: bool, channel: int) -> void:
	_relay_comms.send_relay(data, to_net_id, reliable, ordered, channel)

## Registers a callback for incoming relay data messages.
##
## @param cb Callable invoked when relay data is received
func register_relay_callback(cb: Callable) -> void:
	_relay_comms.register_relay_callback(cb)

## Deregisters the relay data callback.
func deregister_relay_callback() -> void:
	_relay_comms.deregister_relay_callback()

## Registers a callback for relay system messages.
##
## @param cb Callable invoked when a system message is received
func register_system_callback(cb: Callable) -> void:
	_relay_comms.register_system_callback(cb)

## Deregisters the relay system callback.
func deregister_system_callback() -> void:
	_relay_comms.deregister_system_callback()

## Returns the net id assigned to this client by the relay server.
func get_net_id() -> int:
	return _relay_comms.get_net_id()

## Returns the current ping to the relay server in milliseconds.
func get_ping() -> int:
	return _relay_comms.get_ping()

## Sends the end-match packet (CL2RS_ENDMATCH opcode) to the relay server.
## The relay server broadcasts an END_MATCH system message to all players.
##
## @param json_payload Dictionary with match-end metadata (cxId, lobbyId, op)
func end_match(json_payload: Dictionary) -> void:
	_relay_comms.end_match(json_payload)
