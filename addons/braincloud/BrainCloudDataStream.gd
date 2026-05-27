# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudDataStream
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

## Creates a custom data stream page event.
##
## @param event_name Name of the event
## @param json_event_properties Properties of the event
func custom_page_event(event_name: String, json_event_properties: Dictionary) -> Dictionary:
	var data := {
		OperationParam.DATA_STREAM_EVENT_NAME: event_name,
		OperationParam.DATA_STREAM_EVENT_PROPERTIES: json_event_properties
	}
	return await _send("CUSTOM_PAGE_EVENT", data)

## Creates a custom data stream screen event.
##
## @param event_name Name of the event
## @param json_event_properties Properties of the event
func custom_screen_event(event_name: String, json_event_properties: Dictionary) -> Dictionary:
	var data := {
		OperationParam.DATA_STREAM_EVENT_NAME: event_name,
		OperationParam.DATA_STREAM_EVENT_PROPERTIES: json_event_properties
	}
	return await _send("CUSTOM_SCREEN_EVENT", data)

## Creates a custom data stream track event.
##
## @param event_name Name of the event
## @param json_event_properties Properties of the event
func custom_track_event(event_name: String, json_event_properties: Dictionary) -> Dictionary:
	var data := {
		OperationParam.DATA_STREAM_EVENT_NAME: event_name,
		OperationParam.DATA_STREAM_EVENT_PROPERTIES: json_event_properties
	}
	return await _send("CUSTOM_TRACK_EVENT", data)

## Sends a crash report to the server.
##
## @param crash_info Dictionary containing crash type, error message, log, and other crash details
## @param extras Additional key/value pairs to attach to the report
func submit_crash_report(crash_info: Dictionary, extras: Dictionary) -> Dictionary:
	var data := {
		OperationParam.DATA_STREAM_CRASH_INFO: crash_info,
		OperationParam.DATA_STREAM_EXTRAS: extras
	}
	return await _send(ServiceOperation.SUBMIT_CRASH_REPORT, data)

## Logs a simple analytics event.
##
## @param event_name Name of the event
## @param event_properties Key/value properties to attach to the event
func log_simple_event(event_name: String, event_properties: Dictionary) -> Dictionary:
	var data := {
		OperationParam.DATA_STREAM_EVENT_NAME: event_name,
		OperationParam.DATA_STREAM_EVENT_PROPERTIES: event_properties
	}
	return await _send(ServiceOperation.LOG_EVENT, data)

## Logs an exception event with associated crash context.
##
## @param event_name Name of the event
## @param event_properties Key/value properties to attach to the event
## @param crash_info Dictionary containing crash details at the time of the exception
func log_exception_event(event_name: String, event_properties: Dictionary, crash_info: Dictionary) -> Dictionary:
	var data := {
		OperationParam.DATA_STREAM_EVENT_NAME: event_name,
		OperationParam.DATA_STREAM_EVENT_PROPERTIES: event_properties,
		OperationParam.DATA_STREAM_CRASH_INFO: crash_info
	}
	return await _send(ServiceOperation.LOG_EXCEPTION, data)

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.DATA_STREAM, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
