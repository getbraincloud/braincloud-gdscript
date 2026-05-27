# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudScript
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

## Executes a script on the server.
##
## Service Name - Script[br]
## Service Operation - Run
##
## @param script_name The name of the script to be run
## @param json_script_data Data to be sent to the script in json format
func run_script(script_name: String, json_script_data: Dictionary) -> Dictionary:
	var data := {
		OperationParam.SCRIPT_SERVICE_RUN_SCRIPT_NAME: script_name,
		OperationParam.SCRIPT_SERVICE_RUN_SCRIPT_DATA: json_script_data
	}
	return await _send(ServiceOperation.RUN_SCRIPT, data)

## Allows cloud script executions to be scheduled - UTC time.
##
## Service Name - Script[br]
## Service Operation - ScheduleCloudScript
##
## @param script_name The name of the script to be run
## @param json_script_data Data to be sent to the script in json format
## @param start_date_utc The start date in UTC milliseconds
func schedule_run_script_utc(script_name: String, json_script_data: Dictionary, start_date_utc: int) -> Dictionary:
	var data := {
		OperationParam.SCRIPT_SERVICE_RUN_SCRIPT_NAME: script_name,
		OperationParam.SCRIPT_SERVICE_RUN_SCRIPT_DATA: json_script_data,
		OperationParam.SCRIPT_SERVICE_SCHEDULED_START_TIME: start_date_utc
	}
	return await _send(ServiceOperation.SCHEDULE_CLOUD_SCRIPT, data)

## Allows cloud script executions to be scheduled.
##
## Service Name - Script[br]
## Service Operation - ScheduleCloudScript
##
## @param script_name The name of the script to be run
## @param json_script_data Data to be sent to the script in json format
## @param minutes_from_now Number of minutes from now to run script
func schedule_run_script_minutes(script_name: String, json_script_data: Dictionary, minutes_from_now: int) -> Dictionary:
	var data := {
		OperationParam.SCRIPT_SERVICE_RUN_SCRIPT_NAME: script_name,
		OperationParam.SCRIPT_SERVICE_RUN_SCRIPT_DATA: json_script_data,
		"minutesFromNow": minutes_from_now
	}
	return await _send(ServiceOperation.SCHEDULE_CLOUD_SCRIPT, data)

## Cancels a scheduled cloud code script.
##
## Service Name - Script[br]
## Service Operation - CANCEL_SCHEDULED_SCRIPT
##
## @param job_id ID of script job to cancel
func cancel_scheduled_script(job_id: String) -> Dictionary:
	var data := {
		OperationParam.SCRIPT_SERVICE_RUN_SCRIPT_JOB_ID: job_id
	}
	return await _send(ServiceOperation.CANCEL_SCHEDULED_SCRIPT, data)

## Run a cloud script in a parent app.
##
## Service Name - Script[br]
## Service Operation - RUN_PARENT_SCRIPT
##
## @param script_name The name of the script to be run
## @param json_script_data Data to be sent to the script in json format
## @param parent_level The level name of the parent to run the script from
func run_parent_script(script_name: String, json_script_data: Dictionary, parent_level: String) -> Dictionary:
	var data := {
		OperationParam.SCRIPT_SERVICE_RUN_SCRIPT_NAME: script_name,
		OperationParam.SCRIPT_SERVICE_RUN_SCRIPT_DATA: json_script_data,
		OperationParam.SCRIPT_SERVICE_PARENT_LEVEL: parent_level
	}
	return await _send(ServiceOperation.RUN_PARENT_SCRIPT, data)

## Returns a list of scheduled cloud scripts.
##
## Service Name - Script[br]
## Service Operation - GET_SCHEDULED_CLOUD_SCRIPTS
##
## @param start_time_utc Optional start time filter in UTC milliseconds; returns all if 0
func get_scheduled_cloud_scripts(start_time_utc: int = 0) -> Dictionary:
	var data := {}
	if start_time_utc > 0:
		data[OperationParam.SCRIPT_SERVICE_SCHEDULED_START_TIME] = start_time_utc
	return await _send(ServiceOperation.GET_SCHEDULED_CLOUD_SCRIPTS, data)

## Returns cloud scripts currently running or queued.
##
## Service Name - Script[br]
## Service Operation - GET_RUNNING_OR_QUEUED_CLOUD_SCRIPTS
func get_running_or_queued_cloud_scripts() -> Dictionary:
	return await _send(ServiceOperation.GET_RUNNING_OR_QUEUED_CLOUD_SCRIPTS, {})

## Runs a script from the context of a peer.
##
## Service Name - Script[br]
## Service Operation - RUN_PEER_SCRIPT
##
## @param script_name The name of the script to be run
## @param json_script_data Data to be sent to the script in json format
## @param peer_code The peer service code
func run_peer_script(script_name: String, json_script_data: Dictionary, peer_code: String) -> Dictionary:
	var data := {
		OperationParam.SCRIPT_SERVICE_RUN_SCRIPT_NAME: script_name,
		OperationParam.SCRIPT_SERVICE_RUN_SCRIPT_DATA: json_script_data,
		OperationParam.SCRIPT_SERVICE_PEER_CODE: peer_code
	}
	return await _send(ServiceOperation.RUN_PEER_SCRIPT, data)

## Runs a script asynchronously from the context of a peer.
## This method does not wait for the script to complete before returning.
##
## Service Name - Script[br]
## Service Operation - RUN_PEER_SCRIPT_ASYNC
##
## @param script_name The name of the script to be run
## @param json_script_data Data to be sent to the script in json format
## @param peer_code The peer service code
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
