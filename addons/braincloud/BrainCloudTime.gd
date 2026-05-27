# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudTime
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

## Method returns the server time in UTC. This is in UNIX millis time format.
## For instance 1396378241893 represents 2014-04-01 2:50:41.893 in GMT-4.
##
## Service Name - Time[br]
## Service Operation - Read
func read_server_time() -> Dictionary:
	return await _send(ServiceOperation.READ, {})

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.TIME, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
