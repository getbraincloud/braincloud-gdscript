# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudDataStream
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

func custom_page_event(event_name: String, json_event_properties: Dictionary) -> Dictionary:
	var data := {
		OperationParam.DATA_STREAM_EVENT_NAME: event_name,
		OperationParam.DATA_STREAM_EVENT_PROPERTIES: json_event_properties
	}
	return await _send("CUSTOM_PAGE_EVENT", data)

func custom_screen_event(event_name: String, json_event_properties: Dictionary) -> Dictionary:
	var data := {
		OperationParam.DATA_STREAM_EVENT_NAME: event_name,
		OperationParam.DATA_STREAM_EVENT_PROPERTIES: json_event_properties
	}
	return await _send("CUSTOM_SCREEN_EVENT", data)

func custom_track_event(event_name: String, json_event_properties: Dictionary) -> Dictionary:
	var data := {
		OperationParam.DATA_STREAM_EVENT_NAME: event_name,
		OperationParam.DATA_STREAM_EVENT_PROPERTIES: json_event_properties
	}
	return await _send("CUSTOM_TRACK_EVENT", data)

func submit_crash_report(crash_info: Dictionary, extras: Dictionary) -> Dictionary:
	var data := {
		OperationParam.DATA_STREAM_CRASH_INFO: crash_info,
		OperationParam.DATA_STREAM_EXTRAS: extras
	}
	return await _send(ServiceOperation.SUBMIT_CRASH_REPORT, data)

func log_simple_event(event_name: String, event_properties: Dictionary) -> Dictionary:
	var data := {
		OperationParam.DATA_STREAM_EVENT_NAME: event_name,
		OperationParam.DATA_STREAM_EVENT_PROPERTIES: event_properties
	}
	return await _send(ServiceOperation.LOG_EVENT, data)

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
