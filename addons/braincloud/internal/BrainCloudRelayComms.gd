# Copyright 2026 bitHeads, Inc. All Rights Reserved.
# Transport-agnostic relay protocol layer: opcodes, wire framing, the RSMG handshake,
# ping/pong, and (UDP-only) reliable/ordered delivery. Talks to whichever transport is
# active (RelayWSSocket/RelayTCPSocket/RelayUDPSocket) through the small duck-typed
# interface those three implement — connect_to/poll/get_status/get_packets/send_bytes/
# close — mirroring cpp's IRelaySocket split (RelayComms.cpp holds this same protocol +
# reliability logic; only raw socket I/O is split by transport there too).
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

const _MAX_PLAYERS := 40

# 12-bit packetId sequencing (reliable/ordered UDP only). Wraparound-aware comparisons
# use the same 25%/75% threshold split as the cpp/csharp reference SDKs (RelayComms.cpp).
const MAX_PACKET_ID := 0xFFF
const _PACKET_LOWER_THRESHOLD := int(MAX_PACKET_ID * 0.25)
const _PACKET_HIGHER_THRESHOLD := int(MAX_PACKET_ID * 0.75)
const _MAX_ORDERED_HISTORY := 600

# Reliable-UDP resend backoff, indexed by channel (matches cpp's RELIABLE_RESEND_INTERVALS).
const _RELIABLE_RESEND_INTERVALS := [50.0, 50.0, 150.0, 500.0]
const _MAX_RELIABLE_RESEND_INTERVAL := 500.0
const _RELIABLE_GIVE_UP_MS := 10000

const _UDP_CONNECT_RESEND_INTERVAL_MS := 2000
const _UDP_IDLE_TIMEOUT_MS := 10000

var _transport = null       # RelayWSSocket | RelayTCPSocket | RelayUDPSocket
var _transport_kind := "ws" # "ws" | "tcp" | "udp" — which one _transport is

var _state: _State = _State.IDLE
var _client_ref: BrainCloudClient = null
var _lobby_id: String = ""
var _passcode: String = ""
var _net_id: int = -1
var _relay_callback: Callable
var _system_callback: Callable
var _pending_emit: Dictionary = {}
var _ping_ms: int = -1
var _ping_timer: float = 0.0
var _ping_interval: float = 1.0
var _ping_sent_at: float = -1.0

# UDP-only reliability/ordering state (see cpp RelayComms.cpp for the reference algorithm).
var _send_packet_id: Dictionary = {}   # counter_key(String) -> int, next packetId to assign
var _recv_packet_id: Dictionary = {}   # counter_key(String) -> int, last accepted packetId
var _reliables: Dictionary = {}        # ack_key(String) -> {data, resend_interval, last_resend_time, time_since_first_send}
var _ordered_pending: Dictionary = {}  # counter_key(String) -> Array[{packet_id, sender_net_id, payload}], sorted ascending
var _udp_connect_resend_timer: float = 0.0
var _last_recv_time_ms: int = 0

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

## Connects to a relay server.
##
## @param protocol "ws" | "wss" | "tcp" | "udp" (case-insensitive). Anything else falls
##        back to plain WebSocket. use_ssl only applies to the ws/wss transport.
func connect_relay(host: String, port: int, use_ssl: bool, lobby_id: String, passcode: String, protocol: String = "ws") -> void:
	_lobby_id = lobby_id
	_passcode = passcode
	_state = _State.CONNECTING
	_net_id = -1
	_pending_emit = {}
	_send_packet_id.clear()
	_recv_packet_id.clear()
	_reliables.clear()
	_ordered_pending.clear()
	_udp_connect_resend_timer = 0.0
	_last_recv_time_ms = Time.get_ticks_msec()

	_transport_kind = protocol.to_lower()
	if _transport_kind != "tcp" and _transport_kind != "udp":
		_transport_kind = "ws"

	match _transport_kind:
		"tcp": _transport = RelayTCPSocket.new()
		"udp": _transport = RelayUDPSocket.new()
		_:     _transport = RelayWSSocket.new()

	var err: Error = _transport.connect_to(host, port, use_ssl)
	if err != OK:
		_fail_connect("Relay %s connect failed: %d" % [_transport_kind.to_upper(), err])

func disconnect_relay() -> void:
	if _transport: _transport.close()
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

func end_match(json_payload: Dictionary) -> void:
	if _state != _State.CONNECTED:
		return
	var body := PackedByteArray([CL2RS_ENDMATCH]) + JSON.stringify(json_payload).to_utf8_buffer()
	_send_with_size_prefix(body)

func send_relay(data: PackedByteArray, to_net_id: int, reliable: bool, ordered: bool, channel: int) -> void:
	if _state != _State.CONNECTED:
		return

	# rh: bit15=reliable, bit14=ordered, bits13-12=channel, bits11-0=packetId
	var rh_no_id: int = 0
	if reliable: rh_no_id |= 0x8000
	if ordered:  rh_no_id |= 0x4000
	rh_no_id |= (channel & 0x3) << 12

	# 40-bit player mask: bit N = send to player N.  0xFF (TO_ALL_PLAYERS) → all 40 bits.
	var player_mask: int
	if to_net_id >= _MAX_PLAYERS:
		player_mask = (1 << _MAX_PLAYERS) - 1
	else:
		player_mask = 1 << to_net_id

	# Invert bit order to match server encoding, then shift left 8
	var pm: int = 0
	for i in range(_MAX_PLAYERS):
		pm |= ((player_mask >> (_MAX_PLAYERS - 1 - i)) & 1) << i
	pm = (pm << 8) & 0x0000FFFFFFFFFF00

	var pm0: int = (pm >> 32) & 0xFFFF
	var pm1: int = (pm >> 16) & 0xFFFF
	var pm2: int =  pm        & 0xFFFF
	var mask_bytes := PackedByteArray([
		(pm0 >> 8) & 0xFF, pm0 & 0xFF,
		(pm1 >> 8) & 0xFF, pm1 & 0xFF,
		(pm2 >> 8) & 0xFF, pm2 & 0xFF
	])

	# packetId is assigned regardless of transport (wire-format parity with cpp/csharp),
	# but only UDP actually acts on it for dedup/ordering/resend.
	var counter_key := _hex_key(PackedByteArray([(rh_no_id >> 8) & 0xFF, rh_no_id & 0xFF]) + mask_bytes)
	var packet_id: int = _send_packet_id.get(counter_key, 0)
	_send_packet_id[counter_key] = (packet_id + 1) & MAX_PACKET_ID
	var rh := rh_no_id | packet_id

	var header := PackedByteArray([
		CL2RS_RELAY,
		(rh >> 8) & 0xFF, rh & 0xFF
	]) + mask_bytes

	var framed := _send_with_size_prefix(header + data)

	if reliable and _transport_kind == "udp":
		var ack_id_bytes := PackedByteArray([(rh >> 8) & 0xFF, rh & 0xFF]) + mask_bytes
		var now := Time.get_ticks_msec()
		_reliables[_hex_key(ack_id_bytes)] = {
			"data": framed,
			"resend_interval": _RELIABLE_RESEND_INTERVALS[channel & 0x3],
			"last_resend_time": now,
			"time_since_first_send": now
		}

func _process(delta: float) -> void:
	if not _pending_emit.is_empty():
		var resp := _pending_emit
		_pending_emit = {}
		connect_result.emit(resp)
		return

	if _state == _State.IDLE or _state == _State.DISCONNECTED or _transport == null:
		return

	_transport.poll()
	var status: RelayTransportStatus.Status = _transport.get_status()

	match status:
		RelayTransportStatus.Status.CONNECTED:
			if _state == _State.CONNECTING:
				_on_socket_connected()
			if _state == _State.HANDSHAKE or _state == _State.CONNECTED:
				_tick_connected(delta)
			for packet in _transport.get_packets():
				_last_recv_time_ms = Time.get_ticks_msec()
				_on_recv(packet)
		RelayTransportStatus.Status.ERROR, RelayTransportStatus.Status.CLOSED:
			if _state != _State.DISCONNECTED:
				var was_connected := _net_id != -1
				_state = _State.DISCONNECTED
				if not was_connected:
					var detail := ""
					if _transport_kind == "ws" and _transport.has_method("get_close_info"):
						var info: Dictionary = _transport.get_close_info()
						detail = " (code=%d reason=%s)" % [info.get("code", -1), info.get("reason", "")]
					print("[RelayComms] %s closed before handshake%s" % [_transport_kind.to_upper(), detail])
					connect_result.emit({"status": 900, "reason_code": 0, "status_message": "Relay %s connection closed before handshake complete%s" % [_transport_kind.to_upper(), detail]})
				else:
					print("[RelayComms] %s disconnected unexpectedly while connected" % _transport_kind.to_upper())
					if _system_callback.is_valid():
						_system_callback.call({"op": "DISCONNECT"})
		_:
			pass # CONNECTING — still establishing the transport-level connection

func _tick_udp_reliables() -> void:
	var now := Time.get_ticks_msec()
	for key in _reliables.keys():
		var pkt: Dictionary = _reliables[key]
		if now - pkt["time_since_first_send"] > _RELIABLE_GIVE_UP_MS:
			_fail_transport("Relay UDP: reliable packet lost (no ack after %dms)" % _RELIABLE_GIVE_UP_MS)
			return
		if now - pkt["last_resend_time"] >= pkt["resend_interval"]:
			pkt["last_resend_time"] = now
			pkt["resend_interval"] = minf(pkt["resend_interval"] * 1.25, _MAX_RELIABLE_RESEND_INTERVAL)
			_transport_send(pkt["data"])

func _send_udp_ack(ack_id_bytes: PackedByteArray) -> void:
	var body := PackedByteArray([CL2RS_ACK]) + ack_id_bytes
	_send_with_size_prefix(body)

# ── Shared connected-state ticking (ping, UDP resend/timeout/connect-retry) ─

func _on_socket_connected() -> void:
	_state = _State.HANDSHAKE
	_last_recv_time_ms = Time.get_ticks_msec()
	_udp_connect_resend_timer = 0.0
	_send_connect_packet()

func _tick_connected(delta: float) -> void:
	if _state == _State.CONNECTED:
		_ping_timer += delta
		if _ping_timer >= _ping_interval:
			_ping_timer = 0.0
			_send_ping()

	if _transport_kind != "udp":
		return

	if _state == _State.HANDSHAKE:
		_udp_connect_resend_timer += delta
		if _udp_connect_resend_timer * 1000.0 >= _UDP_CONNECT_RESEND_INTERVAL_MS:
			_udp_connect_resend_timer = 0.0
			print("[RelayComms] UDP: no CONNECT ack yet, resending")
			_send_connect_packet()

	if Time.get_ticks_msec() - _last_recv_time_ms > _UDP_IDLE_TIMEOUT_MS:
		_fail_transport("Relay UDP: socket timeout (no data for %dms)" % _UDP_IDLE_TIMEOUT_MS)
		return

	_tick_udp_reliables()

func _fail_transport(msg: String) -> void:
	print("[RelayComms] ", msg)
	var was_connected := _net_id != -1
	_state = _State.DISCONNECTED
	if _transport: _transport.close()
	if not was_connected:
		connect_result.emit({"status": 900, "reason_code": 0, "status_message": msg})
	elif _system_callback.is_valid():
		_system_callback.call({"op": "DISCONNECT"})

func _fail_connect(msg: String) -> void:
	print("[RelayComms] ", msg)
	_state = _State.DISCONNECTED
	_pending_emit = {"status": 900, "reason_code": 0, "status_message": msg}

# ── Wire send/receive plumbing (transport-agnostic framing) ────────────────

func _transport_send(framed: PackedByteArray) -> void:
	if _transport: _transport.send_bytes(framed)

func _send_ping() -> void:
	_ping_sent_at = Time.get_ticks_msec()
	# Ping packet includes last known RTT as 2-byte big-endian uint16 (C++ RelayComms protocol).
	# Use 999 until the first pong comes back.
	var last_ping := clampi(_ping_ms if _ping_ms >= 0 else 999, 0, 999)
	_send_with_size_prefix(PackedByteArray([CL2RS_PING, (last_ping >> 8) & 0xFF, last_ping & 0xFF]))

func _send_connect_packet() -> void:
	var json_str := JSON.stringify({
		"cxId": _client_ref._rtt_comms.get_connection_id(),
		"lobbyId": _lobby_id,
		"passcode": _passcode,
		"version": BrainCloudClient.BRAINCLOUD_VERSION
	})
	var body := PackedByteArray([CL2RS_CONNECT]) + json_str.to_utf8_buffer()
	_send_with_size_prefix(body)

func _send_rsmg_ack(pkt_id_hi: int, pkt_id_lo: int) -> void:
	_send_with_size_prefix(PackedByteArray([CL2RS_RSMG_ACK, pkt_id_hi, pkt_id_lo]))

# Builds the [len_hi,len_lo]+data frame (length is self-inclusive, matching cpp/csharp),
# sends it on the active transport, and returns the framed bytes (needed by send_relay
# to keep a verbatim copy around for UDP reliable-resend).
func _send_with_size_prefix(data: PackedByteArray) -> PackedByteArray:
	var total := data.size() + 2
	var framed := PackedByteArray([(total >> 8) & 0xFF, total & 0xFF]) + data
	_transport_send(framed)
	return framed

func _on_recv(data: PackedByteArray) -> void:
	if data.size() < 3:
		return
	var control := data[2]

	match control:
		RS2CL_RSMG:
			_on_rsmg(data)
		RS2CL_RELAY:
			# Header layout: [0-1]=size, [2]=control, [3-4]=rh, [5-6]=pm0, [7-8]=pm1, [9-10]=pm2
			# Server sets pm2 low byte = sender netId when forwarding to recipients.
			if data.size() >= 11:
				_on_relay(data)
		RS2CL_DISCONNECT:
			_state = _State.DISCONNECTED
			if _transport: _transport.close()
			if _system_callback.is_valid():
				_system_callback.call({"op": "DISCONNECT"})
		RS2CL_PONG:
			if _ping_sent_at >= 0.0:
				_ping_ms = int(Time.get_ticks_msec() - _ping_sent_at)
				_ping_sent_at = -1.0
		RS2CL_ACK:
			if _transport_kind == "udp" and data.size() >= 11:
				_reliables.erase(_hex_key(data.slice(3, 11)))

func _on_relay(data: PackedByteArray) -> void:
	var sender_net_id := data[10]
	var payload := data.slice(11)

	if _transport_kind != "udp":
		if _relay_callback.is_valid():
			_relay_callback.call(sender_net_id, payload)
		return

	# UDP-only: reliability (ack) + ordering/dedup, mirroring cpp RelayComms::onRelay.
	var rh := (data[3] << 8) | data[4]
	var reliable := (rh & 0x8000) != 0
	var ordered  := (rh & 0x4000) != 0
	var packet_id := rh & MAX_PACKET_ID
	var mask_bytes := data.slice(5, 11)

	if reliable:
		# Ack reliables, always — a previous ack from us may have been dropped.
		_send_udp_ack(PackedByteArray([data[3], data[4]]) + mask_bytes)

	if not ordered:
		if _relay_callback.is_valid():
			_relay_callback.call(sender_net_id, payload)
		return

	var rh_no_id := rh & 0xF000
	var counter_key := _hex_key(PackedByteArray([(rh_no_id >> 8) & 0xFF, rh_no_id & 0xFF]) + mask_bytes)
	_handle_ordered_relay(counter_key, packet_id, sender_net_id, payload, reliable)

# Reliable+ordered: dedup, buffer out-of-order, replay consecutively as gaps fill.
# Unreliable+ordered: dedup/drop-if-stale only, no buffering.
func _handle_ordered_relay(counter_key: String, packet_id: int, sender_net_id: int, payload: PackedByteArray, reliable: bool) -> void:
	# Absent key defaults to MAX_PACKET_ID (not -1) — matches cpp, whose wraparound-aware
	# packetLE() correctly treats a fresh low packetId as newer than this sentinel.
	var prev_packet_id: int = _recv_packet_id.get(counter_key, MAX_PACKET_ID)

	if not reliable:
		if _packet_le(packet_id, prev_packet_id):
			return  # out-of-order unreliable packet — just drop it
		_recv_packet_id[counter_key] = packet_id
		if _relay_callback.is_valid():
			_relay_callback.call(sender_net_id, payload)
		return

	if _packet_le(packet_id, prev_packet_id):
		return  # duplicate reliable packet

	var queue: Array = _ordered_pending.get(counter_key, [])
	if packet_id != ((prev_packet_id + 1) & MAX_PACKET_ID):
		for entry in queue:
			if entry["packet_id"] == packet_id:
				return  # already queued, duplicate
		if queue.size() > _MAX_ORDERED_HISTORY:
			_fail_transport("Relay UDP: too many queued out-of-order packets")
			return
		var insert_idx := queue.size()
		for i in range(queue.size()):
			if _packet_le(packet_id, queue[i]["packet_id"]):
				insert_idx = i
				break
		queue.insert(insert_idx, {"packet_id": packet_id, "sender_net_id": sender_net_id, "payload": payload})
		_ordered_pending[counter_key] = queue
		return

	# In order — deliver, then drain any consecutive queued followers.
	_recv_packet_id[counter_key] = packet_id
	if _relay_callback.is_valid():
		_relay_callback.call(sender_net_id, payload)

	while not queue.is_empty():
		var head: Dictionary = queue[0]
		if head["packet_id"] != ((packet_id + 1) & MAX_PACKET_ID):
			break
		queue.pop_front()
		packet_id = head["packet_id"]
		_recv_packet_id[counter_key] = packet_id
		if _relay_callback.is_valid():
			_relay_callback.call(head["sender_net_id"], head["payload"])
	_ordered_pending[counter_key] = queue

# Wraparound-aware 12-bit packetId "a <= b" comparison — exact port of cpp's packetLE.
func _packet_le(a: int, b: int) -> bool:
	if a > _PACKET_HIGHER_THRESHOLD and b <= _PACKET_LOWER_THRESHOLD:
		return true
	if b > _PACKET_HIGHER_THRESHOLD and a <= _PACKET_LOWER_THRESHOLD:
		return false
	return a <= b

func _hex_key(b: PackedByteArray) -> String:
	return b.hex_encode()

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

	print("[RelayComms] RSMG op='%s' msg=%s" % [op, str(msg)])
	if op == "CONNECT" and _state == _State.HANDSHAKE:
		_net_id = msg.get("netId", -1)
		_state = _State.CONNECTED
		_send_ping()
		connect_result.emit({"status": 200, "data": msg})
	elif _system_callback.is_valid():
		_system_callback.call(msg)
