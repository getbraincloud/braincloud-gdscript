# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudScript
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

func run_script(script_name: String, json_script_data: Dictionary) -> Dictionary:
	var data := {
		OperationParam.SCRIPT_SERVICE_RUN_SCRIPT_NAME: script_name,
		OperationParam.SCRIPT_SERVICE_RUN_SCRIPT_DATA: json_script_data
	}
	return await _send(ServiceOperation.RUN_SCRIPT, data)

func schedule_run_script_utc(script_name: String, json_script_data: Dictionary, start_date_utc: int) -> Dictionary:
	var data := {
		OperationParam.SCRIPT_SERVICE_RUN_SCRIPT_NAME: script_name,
		OperationParam.SCRIPT_SERVICE_RUN_SCRIPT_DATA: json_script_data,
		OperationParam.SCRIPT_SERVICE_SCHEDULED_START_TIME: start_date_utc
	}
	return await _send(ServiceOperation.SCHEDULE_CLOUD_SCRIPT, data)

func schedule_run_script_minutes(script_name: String, json_script_data: Dictionary, minutes_from_now: int) -> Dictionary:
	var data := {
		OperationParam.SCRIPT_SERVICE_RUN_SCRIPT_NAME: script_name,
		OperationParam.SCRIPT_SERVICE_RUN_SCRIPT_DATA: json_script_data,
		"minutesFromNow": minutes_from_now
	}
	return await _send(ServiceOperation.SCHEDULE_CLOUD_SCRIPT, data)

func cancel_scheduled_script(job_id: String) -> Dictionary:
	var data := {
		OperationParam.SCRIPT_SERVICE_RUN_SCRIPT_JOB_ID: job_id
	}
	return await _send(ServiceOperation.CANCEL_SCHEDULED_SCRIPT, data)

func run_parent_script(script_name: String, json_script_data: Dictionary, parent_level: String) -> Dictionary:
	var data := {
		OperationParam.SCRIPT_SERVICE_RUN_SCRIPT_NAME: script_name,
		OperationParam.SCRIPT_SERVICE_RUN_SCRIPT_DATA: json_script_data,
		OperationParam.SCRIPT_SERVICE_PARENT_LEVEL: parent_level
	}
	return await _send(ServiceOperation.RUN_PARENT_SCRIPT, data)

func get_scheduled_cloud_scripts(start_time_utc: int = 0) -> Dictionary:
	var data := {}
	if start_time_utc > 0:
		data[OperationParam.SCRIPT_SERVICE_SCHEDULED_START_TIME] = start_time_utc
	return await _send(ServiceOperation.GET_SCHEDULED_CLOUD_SCRIPTS, data)

func get_running_or_queued_cloud_scripts() -> Dictionary:
	return await _send(ServiceOperation.GET_RUNNING_OR_QUEUED_CLOUD_SCRIPTS, {})

func run_peer_script(script_name: String, json_script_data: Dictionary, peer_code: String) -> Dictionary:
	var data := {
		OperationParam.SCRIPT_SERVICE_RUN_SCRIPT_NAME: script_name,
		OperationParam.SCRIPT_SERVICE_RUN_SCRIPT_DATA: json_script_data,
		OperationParam.SCRIPT_SERVICE_PEER_CODE: peer_code
	}
	return await _send(ServiceOperation.RUN_PEER_SCRIPT, data)

func run_peer_script_async(script_name: String, json_script_data: Dictionary, peer_code: String) -> Dictionary:
	var data := {
		OperationParam.SCRIPT_SERVICE_RUN_SCRIPT_NAME: script_name,
		OperationParam.SCRIPT_SERVICE_RUN_SCRIPT_DATA: json_script_data,
		OperationParam.SCRIPT_SERVICE_PEER_CODE: peer_code
	}
	return await _send(ServiceOperation.RUN_PEER_SCRIPT_ASYNC, data)

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.SCRIPT, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
