# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudRelayComms
extends Node

signal connect_result(response: Dictionary)

enum _State { IDLE, CONNECTING, HANDSHAKE, CONNECTED, DISCONNECTED }

const CL2RS_CONNECT   := 0
const CL2RS_DISCONNECT := 1
const CL2RS_RELAY     := 2
const CL2RS_ACK       := 3
const CL2RS_PING      := 4
const CL2RS_RSMG_ACK  := 5
const CL2RS_ENDMATCH  := 6

const RS2CL_RSMG       := 0
const RS2CL_DISCONNECT := 1
const RS2CL_RELAY      := 2
const RS2CL_ACK        := 3
const RS2CL_PONG       := 4

var _ws: WebSocketPeer = null
var _state: _State = _State.IDLE
var _client_ref: BrainCloudClient = null
var _rtt_cx_id: String = ""
var _lobby_id: String = ""
var _passcode: String = ""
var _net_id: int = -1
var _relay_callback: Callable
var _system_callback: Callable
var _pending_emit: Dictionary = {}
var _ping_ms: int = -1
var _ping_timer: float = 0.0
var _ping_interval: float = 2.0
var _ping_sent_at: float = -1.0

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

func connect_relay(host: String, port: int, use_ssl: bool, cx_id: String, lobby_id: String, passcode: String) -> void:
	_rtt_cx_id = cx_id
	_lobby_id = lobby_id
	_passcode = passcode
	_state = _State.CONNECTING
	_net_id = -1
	_pending_emit = {}
	_ws = WebSocketPeer.new()

	var scheme := "wss" if use_ssl else "ws"
	var url := "%s://%s:%d" % [scheme, host, port]

	var tls_opts := TLSOptions.client_unsafe() if use_ssl else null
	var err := _ws.connect_to_url(url, tls_opts)
	if err != OK:
		_state = _State.DISCONNECTED
		_pending_emit = {"status": 900, "reason_code": 0, "status_message": "Relay WebSocket connect_to_url failed: %d" % err}

func disconnect_relay() -> void:
	if _ws != null:
		_ws.close()
	_state = _State.DISCONNECTED
	_ping_ms = -1
	_ping_sent_at = -1.0

func is_relay_connected() -> bool:
	return _state == _State.CONNECTED

func get_net_id() -> int:
	return _net_id

func get_ping() -> int:
	return _ping_ms

func register_relay_callback(cb: Callable) -> void:
	_relay_callback = cb

func deregister_relay_callback() -> void:
	_relay_callback = Callable()

func register_system_callback(cb: Callable) -> void:
	_system_callback = cb

func deregister_system_callback() -> void:
	_system_callback = Callable()

func send_relay(data: PackedByteArray, to_net_id: int, _reliable: bool, _ordered: bool, _channel: int) -> void:
	if _state != _State.CONNECTED:
		return
	var header := PackedByteArray([CL2RS_RELAY, to_net_id & 0xFF])
	_send_with_size_prefix(header + data)

func _process(delta: float) -> void:
	if not _pending_emit.is_empty():
		var resp := _pending_emit
		_pending_emit = {}
		connect_result.emit(resp)
		return

	if _ws == null or _state == _State.IDLE or _state == _State.DISCONNECTED:
		return

	_ws.poll()
	var ws_state := _ws.get_ready_state()

	if ws_state == WebSocketPeer.STATE_OPEN:
		if _state == _State.CONNECTING:
			_state = _State.HANDSHAKE
			_send_connect_packet()
		elif _state == _State.CONNECTED:
			_ping_timer += delta
			if _ping_timer >= _ping_interval:
				_ping_timer = 0.0
				_send_ping()
		while _ws.get_available_packet_count() > 0:
			_on_recv(_ws.get_packet())
	elif ws_state == WebSocketPeer.STATE_CLOSED:
		if _state != _State.DISCONNECTED:
			_state = _State.DISCONNECTED
			if _net_id == -1:
				connect_result.emit({"status": 900, "reason_code": 0, "status_message": "Relay WebSocket closed before handshake complete"})

func _send_ping() -> void:
	_ping_sent_at = Time.get_ticks_msec()
	_send_with_size_prefix(PackedByteArray([CL2RS_PING]))

func _send_connect_packet() -> void:
	var json_str := JSON.stringify({
		"cxId": _rtt_cx_id,
		"lobbyId": _lobby_id,
		"passcode": _passcode,
		"version": BrainCloudClient.BRAINCLOUD_VERSION
	})
	var body := PackedByteArray([CL2RS_CONNECT]) + json_str.to_utf8_buffer()
	_send_with_size_prefix(body)

func _send_rsmg_ack(pkt_id_hi: int, pkt_id_lo: int) -> void:
	_send_with_size_prefix(PackedByteArray([CL2RS_RSMG_ACK, pkt_id_hi, pkt_id_lo]))

func _send_with_size_prefix(data: PackedByteArray) -> void:
	var total := data.size() + 2
	var prefixed := PackedByteArray([(total >> 8) & 0xFF, total & 0xFF]) + data
	_ws.send(prefixed)

func _on_recv(data: PackedByteArray) -> void:
	if data.size() < 3:
		return
	var control := data[2]

	match control:
		RS2CL_RSMG:
			_on_rsmg(data)
		RS2CL_RELAY:
			if _relay_callback.is_valid() and data.size() > 3:
				var sender_net_id := data[3]
				_relay_callback.call(sender_net_id, data.slice(4))
		RS2CL_DISCONNECT:
			_state = _State.DISCONNECTED
			_ws.close()
		RS2CL_PONG:
			if _ping_sent_at >= 0.0:
				_ping_ms = int(Time.get_ticks_msec() - _ping_sent_at)
				_ping_sent_at = -1.0
		RS2CL_ACK:
			pass

func _on_rsmg(data: PackedByteArray) -> void:
	if data.size() < 5:
		return
	_send_rsmg_ack(data[3], data[4])

	var json_str := data.slice(5).get_string_from_utf8()
	var parsed := JSON.parse_string(json_str)
	if not parsed is Dictionary:
		return
	var msg: Dictionary = parsed
	var op: String = msg.get("op", "")

	if op == "CONNECT":
		if msg.get("cxId", "") == _rtt_cx_id:
			_net_id = msg.get("netId", -1)
			_state = _State.CONNECTED
			connect_result.emit({"status": 200, "data": msg})
	elif _system_callback.is_valid():
		_system_callback.call(msg)
