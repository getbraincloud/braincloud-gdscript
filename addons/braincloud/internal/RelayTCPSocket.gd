# Copyright 2026 bitHeads, Inc. All Rights Reserved.
# TCP relay transport — wraps StreamPeerTCP, including the byte-stream deframing WS/UDP
# don't need (TCP has no built-in message boundaries). The 2-byte big-endian length
# prefix is self-inclusive (counts itself), matching cpp's DefaultRelayTCPSocket::peek
# and the framing BrainCloudRelayComms builds in _send_with_size_prefix.
class_name RelayTCPSocket
extends RefCounted

var _tcp: StreamPeerTCP = null
var _buffer: PackedByteArray = PackedByteArray()
var _status: RelayTransportStatus.Status = RelayTransportStatus.Status.CONNECTING

func connect_to(host: String, port: int, _use_ssl: bool) -> Error:
	_tcp = StreamPeerTCP.new()
	var err := _tcp.connect_to_host(host, port)
	if err != OK:
		_status = RelayTransportStatus.Status.ERROR
		return err
	_tcp.set_no_delay(true)
	return OK

func poll() -> void:
	if _tcp == null:
		return
	_tcp.poll()
	match _tcp.get_status():
		StreamPeerTCP.STATUS_CONNECTED:
			_status = RelayTransportStatus.Status.CONNECTED
		StreamPeerTCP.STATUS_ERROR, StreamPeerTCP.STATUS_NONE:
			_status = RelayTransportStatus.Status.ERROR
		_:
			pass # STATUS_CONNECTING — leave status as-is

func get_status() -> RelayTransportStatus.Status:
	return _status

func get_packets() -> Array:
	var out: Array = []
	if _tcp == null or _status != RelayTransportStatus.Status.CONNECTED:
		return out

	var avail := _tcp.get_available_bytes()
	if avail > 0:
		var res: Array = _tcp.get_partial_data(avail)
		if res[0] == OK:
			_buffer.append_array(res[1])

	# Peel off complete frames; a stream read can contain several queued messages or
	# a partial trailing one.
	while _buffer.size() >= 2:
		var packet_size := (_buffer[0] << 8) | _buffer[1]
		if packet_size < 3 or packet_size > 65535:
			_status = RelayTransportStatus.Status.ERROR
			return out
		if _buffer.size() < packet_size:
			break
		out.append(_buffer.slice(0, packet_size))
		_buffer = _buffer.slice(packet_size)
	return out

func send_bytes(data: PackedByteArray) -> void:
	if _tcp: _tcp.put_data(data)

func close() -> void:
	if _tcp: _tcp.disconnect_from_host()
	_status = RelayTransportStatus.Status.CLOSED
