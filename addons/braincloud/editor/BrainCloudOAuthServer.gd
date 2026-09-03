@tool
class_name BrainCloudOAuthServer
extends RefCounted

# Loopback HTTP listener used to catch the OAuth2 redirect during the plugin's
# "Log in with brainCloud" flow. Godot has no HttpListener equivalent, so this
# speaks just enough raw HTTP over a TCPServer to read one GET request and reply.

signal code_received(code: String, state: String)
signal login_error(message: String)

const _RESPONSE_HTML := """<html>
<head><style>
body { margin:0; padding:0; background:#000; font-family:Arial,Helvetica,sans-serif;
	display:flex; justify-content:center; align-items:center; height:100vh; color:#fff; }
.card { background:#111; padding:40px 30px; border-radius:10px; max-width:500px;
	text-align:center; box-shadow:0 4px 20px rgba(0,0,0,0.5); }
h2 { font-weight:500; margin:0 0 15px 0; }
p { color:#ccc; margin:8px 0; font-size:16px; }
</style></head>
<body><div class="card">
<h2>You're almost done!</h2>
<p>You may close this browser window and proceed to Godot.</p>
</div></body></html>"""

var _server: TCPServer = null
var _conn: StreamPeerTCP = null
var _buffer: String = ""
var _active: bool = false


func start(port: int) -> bool:
	stop()
	_server = TCPServer.new()
	if _server.listen(port, "127.0.0.1") != OK:
		_server = null
		return false
	_active = true
	return true


func is_active() -> bool:
	return _active


func poll() -> void:
	if not _active:
		return

	if _conn == null:
		if _server != null and _server.is_connection_available():
			_conn = _server.take_connection()
			_buffer = ""
		return

	_conn.poll()
	var status := _conn.get_status()
	if status != StreamPeerTCP.STATUS_CONNECTED:
		_conn = null
		return

	var available := _conn.get_available_bytes()
	if available > 0:
		var chunk := _conn.get_partial_data(available)
		if chunk[0] == OK:
			_buffer += (chunk[1] as PackedByteArray).get_string_from_utf8()

	if "\r\n\r\n" in _buffer or "\n\n" in _buffer:
		_handle_request(_buffer)


func stop() -> void:
	_active = false
	if _conn != null:
		_conn.disconnect_from_host()
		_conn = null
	if _server != null:
		_server.stop()
		_server = null
	_buffer = ""


func _handle_request(raw: String) -> void:
	var conn := _conn
	_conn = null
	_active = false
	if _server != null:
		_server.stop()
		_server = null

	var first_line := raw.split("\n")[0].strip_edges()
	var parts := first_line.split(" ")
	var path_and_query := parts[1] if parts.size() > 1 else ""

	var query := ""
	var q_index := path_and_query.find("?")
	if q_index != -1:
		query = path_and_query.substr(q_index + 1)

	var params: Dictionary = {}
	for pair in query.split("&"):
		if pair.is_empty():
			continue
		var kv := pair.split("=", true, 1)
		var key: String = kv[0].uri_decode()
		var value: String = kv[1].uri_decode() if kv.size() > 1 else ""
		params[key] = value

	_send_response(conn)

	if params.has("code") and params.has("state"):
		code_received.emit(params["code"], params["state"])
	else:
		login_error.emit("Redirect did not include a code and/or state parameter.")


func _send_response(conn: StreamPeerTCP) -> void:
	var body := _RESPONSE_HTML.to_utf8_buffer()
	var header := "HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\nContent-Length: %d\r\nConnection: close\r\n\r\n" % body.size()
	conn.put_data(header.to_utf8_buffer())
	conn.put_data(body)
	conn.disconnect_from_host()
