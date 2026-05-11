# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudPlayerStatisticsEvent
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

func trigger_stats_event(event_name: String, multiplier: int) -> Dictionary:
	var data := {
		OperationParam.DATA_STREAM_EVENT_NAME: event_name,
		"multiplier": multiplier
	}
	return await _send(ServiceOperation.TRIGGER, data)

func trigger_stats_events(json_data: Array) -> Dictionary:
	var data := {
		"events": json_data
	}
	return await _send(ServiceOperation.TRIGGER_MULTIPLE, data)

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.PLAYER_STATISTICS_EVENT, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
