# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudPlayerStatisticsEvent
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

## Trigger an event server side that will increase the user's statistics.
## This may cause one or more awards to be sent back to the user -
## could be achievements, experience, etc. Achievements will be sent by this
## client library to the appropriate awards service (Apple Game Center, etc).
##
## This mechanism supercedes the PlayerStatisticsService API methods, since
## PlayerStatisticsService API method only update the raw statistics without
## triggering the rewards.
##
## Service Name - PlayerStatisticsEvent[br]
## Service Operation - Trigger
##
## @see BrainCloudPlayerStatistics
##
## @param event_name Name of the event to trigger
## @param multiplier Multiplier to apply to the event
func trigger_stats_event(event_name: String, multiplier: int) -> Dictionary:
	var data := {
		OperationParam.DATA_STREAM_EVENT_NAME: event_name,
		"multiplier": multiplier
	}
	return await _send(ServiceOperation.TRIGGER, data)

## Trigger multiple statistics events in a single request.
## See documentation for trigger_stats_event for more information.
##
## Service Name - PlayerStatisticsEvent[br]
## Service Operation - TriggerMultiple
##
## @param json_data Array of event objects: [{"eventName": "name", "eventMultiplier": 1}, ...]
func trigger_stats_events(json_data: Array) -> Dictionary:
	var data := {
		"events": json_data
	}
	return await _send(ServiceOperation.TRIGGER_MULTIPLE, data)

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.PLAYER_STATISTICS_EVENT, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
