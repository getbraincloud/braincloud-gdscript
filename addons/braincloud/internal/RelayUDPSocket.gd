# Copyright 2026 bitHeads, Inc. All Rights Reserved.
# UDP relay transport — wraps PacketPeerUDP. UDP is connectionless, so "connected" here
# just means the destination is set; the real handshake proof is the server's RSMG
# CONNECT (handled at the protocol layer in BrainCloudRelayComms). connect_to_host()
# already restricts get_packet() to the connected peer, matching cpp's manual
# source-address check in DefaultRelayUDPSocket.
class_name RelayUDPSocket
extends RefCounted

var _udp: PacketPeerUDP = null
var _status: RelayTransportStatus.Status = RelayTransportStatus.Status.CONNECTING

func connect_to(host: String, port: int, _use_ssl: bool) -> Error:
	_udp = PacketPeerUDP.new()
	var err := _udp.connect_to_host(host, port)
	if err != OK:
		_status = RelayTransportStatus.Status.ERROR
		return err
	_status = RelayTransportStatus.Status.CONNECTED
	return OK

func poll() -> void:
	pass # PacketPeerUDP needs no explicit poll; get_packet() reads directly.

func get_status() -> RelayTransportStatus.Status:
	return _status

func get_packets() -> Array:
	var out: Array = []
	if _udp == null:
		return out
	while _udp.get_available_packet_count() > 0:
		out.append(_udp.get_packet())
	return out

func send_bytes(data: PackedByteArray) -> void:
	if _udp: _udp.put_packet(data)

func close() -> void:
	if _udp: _udp.close()
	_status = RelayTransportStatus.Status.CLOSED
