# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudRTTComms
extends Node

signal connect_result(response: Dictionary)

enum _State { IDLE, CONNECTING, HANDSHAKE, CONNECTED, DISCONNECTED }

var _ws: WebSocketPeer = null
var _state: _State = _State.IDLE
var _client_ref: BrainCloudClient = null
var _connection_id: String = ""
var _heart_beat_seconds: int = 30
var _heart_beat_timer: float = 0.0
var _event_callbacks: Dictionary = {}
var _auth: Dictionary = {}
var _pending_emit: Dictionary = {}

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

func connect_ws(endpoint: Dictionary, auth: Dictionary) -> void:
	_auth = auth
	_state = _State.CONNECTING
	_connection_id = ""
	_heart_beat_timer = 0.0
	_pending_emit = {}
	_ws = WebSocketPeer.new()

	var host: String = endpoint.get("host", "")
	var port: int = endpoint.get("port", 443)
	var ssl: bool = endpoint.get("ssl", true)
	var scheme := "wss" if ssl else "ws"

	# Godot 4.5+: headers are set via property before connect_to_url (not a parameter).
	# Godot's String::parse_url requires a path segment before query params, so use /?query.
	# Send auth both ways for maximum server compatibility.
	var query_parts: PackedStringArray = []
	var header_list: PackedStringArray = []
	for key in auth:
		query_parts.append("%s=%s" % [key, auth[key]])
		header_list.append("%s: %s" % [key, auth[key]])
	var url := "%s://%s:%d/?%s" % [scheme, host, port, "&".join(query_parts)]
	_ws.handshake_headers = header_list

	print("[RTTComms] Connecting to: %s" % url)

	# Use client_unsafe() to skip TLS cert verification for internal servers.
	# Internal brainCloud servers use GoDaddy certs that Godot's mbedTLS may not trust.
	var tls_opts := TLSOptions.client_unsafe() if ssl else null
	var err := _ws.connect_to_url(url, tls_opts)
	if err != OK:
		_state = _State.DISCONNECTED
		_pending_emit = {"status": 900, "reason_code": 0, "status_message": "RTT WebSocket connect_to_url failed: %d" % err}
		print("[RTTComms] connect_to_url error: %d" % err)

func disconnect_ws() -> void:
	if _ws != null:
		_ws.close()
	_state = _State.DISCONNECTED
	_connection_id = ""

func is_ws_connected() -> bool:
	return _state == _State.CONNECTED

func get_connection_id() -> String:
	return _connection_id

func set_heart_beat_seconds(secs: int) -> void:
	_heart_beat_seconds = secs

func register_event_callback(service: String, cb: Callable) -> void:
	_event_callbacks[service] = cb

func deregister_event_callback(service: String) -> void:
	_event_callbacks.erase(service)

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
			_send_connect_request()
		elif _state == _State.CONNECTED:
			_heart_beat_timer += delta
			if _heart_beat_timer >= float(_heart_beat_seconds):
				_heart_beat_timer = 0.0
				_send_heartbeat()
		while _ws.get_available_packet_count() > 0:
			var pkt := _ws.get_packet()
			_on_recv(pkt.get_string_from_utf8())
	elif ws_state == WebSocketPeer.STATE_CLOSED:
		if _state != _State.DISCONNECTED:
			_state = _State.DISCONNECTED
			if _connection_id.is_empty():
				var close_code := _ws.get_close_code()
				var close_reason := _ws.get_close_reason()
				connect_result.emit({"status": 900, "reason_code": 0,
					"status_message": "RTT WebSocket closed before handshake (ws_code=%d reason=%s)" % [close_code, close_reason]})

func _send_connect_request() -> void:
	var msg := {
		"service": "rtt",
		"operation": "CONNECT",
		"data": {
			"appId": _client_ref.get_app_id(),
			"sessionId": _client_ref.get_session_id(),
			"profileId": _client_ref.get_profile_id(),
			"system": {
				"platform": _client_ref.get_release_platform(),
				"protocol": "ws"
			},
			"auth": _auth
		}
	}
	_ws.send_text(JSON.stringify(msg))

func _send_heartbeat() -> void:
	_ws.send_text(JSON.stringify({"service": "rtt", "operation": "HEARTBEAT", "data": null}))

func _on_recv(text: String) -> void:
	var parsed := JSON.parse_string(text)
	if not parsed is Dictionary:
		return
	var msg: Dictionary = parsed
	var service: String = msg.get("service", "").to_lower()
	var operation: String = msg.get("operation", "").to_upper()

	if service == "rtt" and operation == "CONNECT":
		var data: Dictionary = msg.get("data", {})
		_connection_id = data.get("cxId", "")
		var hb: int = data.get("heartbeatSeconds", data.get("wsHeartbeatSecs", _heart_beat_seconds))
		_heart_beat_seconds = hb
		_heart_beat_timer = 0.0
		_state = _State.CONNECTED
		connect_result.emit({"status": 200, "data": data})
		return

	if service in _event_callbacks:
		var cb: Callable = _event_callbacks[service]
		if cb.is_valid():
			cb.call(msg)
