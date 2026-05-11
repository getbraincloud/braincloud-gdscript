# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudEvent
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

func send_event(to_player_id: String, event_type: String, json_event_data: Dictionary) -> Dictionary:
	var data := {
		OperationParam.EVENT_SERVICE_SEND_TO_PLAYER_ID: to_player_id,
		OperationParam.EVENT_SERVICE_SEND_EVENT_TYPE: event_type,
		OperationParam.EVENT_SERVICE_SEND_EVENT_DATA: json_event_data
	}
	return await _send(ServiceOperation.SEND, data)

func update_incoming_event_data(event_id: String, json_event_data: Dictionary) -> Dictionary:
	var data := {
		OperationParam.EVENT_SERVICE_EVENT_ID: event_id,
		OperationParam.EVENT_SERVICE_UPDATE_EVENT_DATA: json_event_data
	}
	return await _send(ServiceOperation.UPDATE_EVENT_DATA, data)

func delete_incoming_event(event_id: String) -> Dictionary:
	var data := {
		OperationParam.EVENT_SERVICE_EVENT_ID: event_id
	}
	return await _send(ServiceOperation.DELETE_INCOMING, data)

func get_events() -> Dictionary:
	return await _send(ServiceOperation.GET_EVENTS, {})

func delete_incoming_events(event_ids: Array) -> Dictionary:
	var data := {
		OperationParam.EVENT_SERVICE_DELETE_INCOMING_EVENTS_IDS: event_ids
	}
	return await _send(ServiceOperation.DELETE_INCOMING_EVENTS, data)

func delete_incoming_events_older_than(date_millis: int) -> Dictionary:
	var data := {
		OperationParam.EVENT_SERVICE_DELETE_INCOMING_EVENTS_OLDER_THAN: date_millis
	}
	return await _send(ServiceOperation.DELETE_INCOMING_EVENTS_OLDER_THAN, data)

func delete_incoming_events_by_type_older_than(event_type: String, date_millis: int) -> Dictionary:
	var data := {
		OperationParam.EVENT_SERVICE_SEND_EVENT_TYPE: event_type,
		OperationParam.EVENT_SERVICE_DELETE_INCOMING_EVENTS_OLDER_THAN: date_millis
	}
	return await _send(ServiceOperation.DELETE_INCOMING_EVENTS_BY_TYPE_OLDER_THAN, data)

func update_incoming_event_data_if_exists(event_id: String, json_event_data: Dictionary) -> Dictionary:
	var data := {
		OperationParam.EVENT_SERVICE_EVENT_ID: event_id,
		OperationParam.EVENT_SERVICE_UPDATE_EVENT_DATA: json_event_data
	}
	return await _send(ServiceOperation.UPDATE_EVENT_DATA_IF_EXISTS, data)

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.EVENT, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
