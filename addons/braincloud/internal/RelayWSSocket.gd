# Copyright 2026 bitHeads, Inc. All Rights Reserved.
# WebSocket relay transport — wraps WebSocketPeer. Implements the shared duck-typed
# transport interface (connect_to/poll/get_status/get_packets/send_bytes/close) that
# RelayTCPSocket/RelayUDPSocket also implement; BrainCloudRelayComms talks to whichever
# is active without knowing which one it has.
class_name RelayWSSocket
extends RefCounted

var _ws: WebSocketPeer = null
var _status: RelayTransportStatus.Status = RelayTransportStatus.Status.CONNECTING

func connect_to(host: String, port: int, use_ssl: bool) -> Error:
	_ws = WebSocketPeer.new()
	var scheme := "wss" if use_ssl else "ws"
	# Trailing slash required — Godot's URL parser needs a path segment for correct HTTP upgrade.
	var url := "%s://%s:%d/" % [scheme, host, port]

	# libwebsockets relay servers reject upgrades without an Origin header (RFC 6455 §10.2).
	_ws.handshake_headers = PackedStringArray(["Origin: http://%s:%d" % [host, port]])
	var tls_opts := TLSOptions.client_unsafe() if use_ssl else null
	print("[RelayWSSocket] connecting to: ", url)
	var err := _ws.connect_to_url(url, tls_opts)
	if err != OK:
		_status = RelayTransportStatus.Status.ERROR
	return err

func poll() -> void:
	if _ws == null:
		return
	_ws.poll()
	match _ws.get_ready_state():
		WebSocketPeer.STATE_OPEN:
			_status = RelayTransportStatus.Status.CONNECTED
		WebSocketPeer.STATE_CLOSED:
			_status = RelayTransportStatus.Status.CLOSED
		_:
			pass # CONNECTING/CLOSING — leave status as-is until OPEN or CLOSED

func get_status() -> RelayTransportStatus.Status:
	return _status

func get_packets() -> Array:
	var out: Array = []
	if _ws == null:
		return out
	while _ws.get_available_packet_count() > 0:
		out.append(_ws.get_packet())
	return out

func send_bytes(data: PackedByteArray) -> void:
	if _ws: _ws.send(data)

func close() -> void:
	if _ws: _ws.close()
	_status = RelayTransportStatus.Status.CLOSED

# WS-specific: extra diagnostic info for an unexpected close (checked via has_method
# since TCP/UDP have no equivalent).
func get_close_info() -> Dictionary:
	if _ws == null:
		return {"code": -1, "reason": ""}
	return {"code": _ws.get_close_code(), "reason": _ws.get_close_reason()}
