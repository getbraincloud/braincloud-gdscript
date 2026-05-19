# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudTime
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

func read_server_time() -> Dictionary:
	return await _send(ServiceOperation.READ, {})

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.TIME, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
