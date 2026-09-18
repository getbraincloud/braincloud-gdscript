# Copyright 2026 bitHeads, Inc. All Rights Reserved.
# WebSocket relay transport — wraps WebSocketPeer. Implements the shared duck-typed
# transport interface (connect_to/poll/get_status/get_packets/send_bytes/close) that
# RelayTCPSocket/RelayUDPSocket also implement; BrainCloudRelayComms talks to whichever
# is active without knowing which one it has.
class_name RelayWSSocket
extends RefCounted

var _ws: WebSocketPeer = null
var _status: RelayTransportStatus.Status = RelayTransportStatus.Status.CONNECTING
var _last_logged_state: int = -1
var _connect_started_ms: int = 0

static func _state_name(s: int) -> String:
	match s:
		WebSocketPeer.STATE_CONNECTING: return "CONNECTING"
		WebSocketPeer.STATE_OPEN:       return "OPEN"
		WebSocketPeer.STATE_CLOSING:    return "CLOSING"
		WebSocketPeer.STATE_CLOSED:     return "CLOSED"
	return "UNKNOWN(%d)" % s

func connect_to(host: String, port: int, use_ssl: bool) -> Error:
	_ws = WebSocketPeer.new()
	var scheme := "wss" if use_ssl else "ws"
	# Trailing slash required — Godot's URL parser needs a path segment for correct HTTP upgrade.
	var url := "%s://%s:%d/" % [scheme, host, port]

	# libwebsockets relay servers reject upgrades without an Origin header (RFC 6455 §10.2).
	# Scheme must track use_ssl — an "http://" Origin on a "wss://" handshake is a scheme
	# mismatch some servers/proxies reject outright, breaking wss specifically while ws
	# keeps working. (On Web export this header is set by the browser itself and this line
	# has no effect — browsers forbid scripts from overriding Origin — but it's still what
	# actually goes out on native desktop exports, where WebSocketPeer is Godot's own.)
	var origin_scheme := "https" if use_ssl else "http"
	_ws.handshake_headers = PackedStringArray(["Origin: %s://%s:%d" % [origin_scheme, host, port]])
	var tls_opts := TLSOptions.client_unsafe() if use_ssl else null
	print("[RelayWSSocket] connecting to: ", url)
	print("[RelayWSSocket]   headers=%s tls=%s" % [str(_ws.handshake_headers), ("client_unsafe" if use_ssl else "none")])
	_connect_started_ms = Time.get_ticks_msec()
	var err := _ws.connect_to_url(url, tls_opts)
	if err != OK:
		_status = RelayTransportStatus.Status.ERROR
		push_error("[RelayWSSocket] connect_to_url failed immediately: %s (Error %d)" % [error_string(err), err])
	return err

func poll() -> void:
	if _ws == null:
		return
	_ws.poll()
	var rs := _ws.get_ready_state()
	# Log every transport state transition once. Without this a failed relay connect
	# reports only "timed out" with no indication of whether the socket ever left
	# CONNECTING (nothing answered) or reached CLOSED (actively refused/reset).
	if rs != _last_logged_state:
		var elapsed := Time.get_ticks_msec() - _connect_started_ms
		var extra := ""
		if rs == WebSocketPeer.STATE_CLOSED:
			extra = " code=%d reason='%s'" % [_ws.get_close_code(), _ws.get_close_reason()]
		print("[RelayWSSocket] state %s -> %s after %dms%s"
			% [_state_name(_last_logged_state), _state_name(rs), elapsed, extra])
		_last_logged_state = rs
	match rs:
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

# WS-specific: full diagnostic snapshot for failure reporting. The ready state is the
# useful bit on a connect timeout — still CONNECTING means nothing ever answered the
# upgrade, whereas CLOSED means the peer actively refused or reset it.
func get_debug_info() -> Dictionary:
	if _ws == null:
		return {"state": "NO_SOCKET", "code": -1, "reason": "", "elapsed_ms": 0}
	return {
		"state": _state_name(_ws.get_ready_state()),
		"code": _ws.get_close_code(),
		"reason": _ws.get_close_reason(),
		"elapsed_ms": Time.get_ticks_msec() - _connect_started_ms,
	}
