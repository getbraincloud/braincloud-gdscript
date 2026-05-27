# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudEvent
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

## Sends an event to the designated user id with the attached json data.
## Any events sent to a user will show up in their incoming event mailbox.
##
## Service Name - Event[br]
## Service Operation - SEND
##
## @param to_player_id The id of the user who is being sent the event
## @param event_type The user-defined type of the event
## @param json_event_data The user-defined data for this event
func send_event(to_player_id: String, event_type: String, json_event_data: Dictionary) -> Dictionary:
	var data := {
		OperationParam.EVENT_SERVICE_SEND_TO_PLAYER_ID: to_player_id,
		OperationParam.EVENT_SERVICE_SEND_EVENT_TYPE: event_type,
		OperationParam.EVENT_SERVICE_SEND_EVENT_DATA: json_event_data
	}
	return await _send(ServiceOperation.SEND, data)

## Updates an event in the user's incoming event mailbox.
##
## Service Name - Event[br]
## Service Operation - UPDATE_EVENT_DATA
##
## @param event_id The event id
## @param json_event_data The user-defined data for this event
func update_incoming_event_data(event_id: String, json_event_data: Dictionary) -> Dictionary:
	var data := {
		OperationParam.EVENT_SERVICE_EVENT_ID: event_id,
		OperationParam.EVENT_SERVICE_UPDATE_EVENT_DATA: json_event_data
	}
	return await _send(ServiceOperation.UPDATE_EVENT_DATA, data)

## Deletes an event out of the user's incoming mailbox.
##
## Service Name - Event[br]
## Service Operation - DELETE_INCOMING
##
## @param event_id The event id
func delete_incoming_event(event_id: String) -> Dictionary:
	var data := {
		OperationParam.EVENT_SERVICE_EVENT_ID: event_id
	}
	return await _send(ServiceOperation.DELETE_INCOMING, data)

## Gets the events currently queued for the user.
##
## Service Name - Event[br]
## Service Operation - GET_EVENTS
func get_events() -> Dictionary:
	return await _send(ServiceOperation.GET_EVENTS, {})

## Deletes a list of events out of the user's incoming mailbox.
##
## Service Name - Event[br]
## Service Operation - DELETE_INCOMING_EVENTS
##
## @param event_ids Collection of event ids to delete
func delete_incoming_events(event_ids: Array) -> Dictionary:
	var data := {
		OperationParam.EVENT_SERVICE_DELETE_INCOMING_EVENTS_IDS: event_ids
	}
	return await _send(ServiceOperation.DELETE_INCOMING_EVENTS, data)

## Deletes any events older than the given date out of the user's incoming mailbox.
##
## Service Name - Event[br]
## Service Operation - DELETE_INCOMING_EVENTS_OLDER_THAN
##
## @param date_millis createdAt cut-off time; older events will be deleted (UTC since Epoch)
func delete_incoming_events_older_than(date_millis: int) -> Dictionary:
	var data := {
		OperationParam.EVENT_SERVICE_DELETE_INCOMING_EVENTS_OLDER_THAN: date_millis
	}
	return await _send(ServiceOperation.DELETE_INCOMING_EVENTS_OLDER_THAN, data)

## Deletes any events of the given type older than the given date out of the user's incoming mailbox.
##
## Service Name - Event[br]
## Service Operation - DELETE_INCOMING_EVENTS_BY_TYPE_OLDER_THAN
##
## @param event_type The user-defined type of the event
## @param date_millis createdAt cut-off time; older events will be deleted (UTC since Epoch)
func delete_incoming_events_by_type_older_than(event_type: String, date_millis: int) -> Dictionary:
	var data := {
		OperationParam.EVENT_SERVICE_SEND_EVENT_TYPE: event_type,
		OperationParam.EVENT_SERVICE_DELETE_INCOMING_EVENTS_OLDER_THAN: date_millis
	}
	return await _send(ServiceOperation.DELETE_INCOMING_EVENTS_BY_TYPE_OLDER_THAN, data)

## Updates an event in the user's incoming event mailbox.
## Returns null instead of an error if the event does not exist.
##
## Service Name - Event[br]
## Service Operation - UPDATE_EVENT_DATA_IF_EXISTS
##
## @param event_id The event id
## @param json_event_data The user-defined data for this event
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
