# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudAsyncMatch
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

func create_match(json_opponents: Array, push_message: Dictionary) -> Dictionary:
	var data := {
		OperationParam.ASYNC_MATCH_SERVICE_OPPONENTS: json_opponents,
		OperationParam.ASYNC_MATCH_SERVICE_PUSH_MESSAGE: push_message
	}
	return await _send(ServiceOperation.CREATE, data)

func create_match_with_initial_turn(json_opponents: Array, json_match_state: Dictionary, push_message: Dictionary, next_player: String, json_summary: Dictionary) -> Dictionary:
	var data := {
		OperationParam.ASYNC_MATCH_SERVICE_OPPONENTS: json_opponents,
		OperationParam.ASYNC_MATCH_SERVICE_TURN_DATA: json_match_state,
		OperationParam.ASYNC_MATCH_SERVICE_PUSH_MESSAGE: push_message,
		"nextPlayer": next_player,
		OperationParam.ASYNC_MATCH_SERVICE_SUMMARY: json_summary
	}
	return await _send(ServiceOperation.CREATE, data)

func submit_turn(owner_id: String, match_id: String, version: int, json_match_state: Dictionary, push_message: Dictionary, next_player: String, json_summary: Dictionary, json_statistics: Dictionary) -> Dictionary:
	var data := {
		OperationParam.ASYNC_MATCH_SERVICE_OWNER_ID: owner_id,
		OperationParam.ASYNC_MATCH_SERVICE_MATCH_ID: match_id,
		OperationParam.ASYNC_MATCH_SERVICE_CURRENT_VERSION: version,
		OperationParam.ASYNC_MATCH_SERVICE_TURN_DATA: json_match_state,
		OperationParam.ASYNC_MATCH_SERVICE_PUSH_MESSAGE: push_message,
		"nextPlayer": next_player,
		OperationParam.ASYNC_MATCH_SERVICE_SUMMARY: json_summary,
		"statistics": json_statistics
	}
	return await _send(ServiceOperation.TURN, data)

func update_match_summary(owner_id: String, match_id: String, version: int, json_summary: Dictionary) -> Dictionary:
	var data := {
		OperationParam.ASYNC_MATCH_SERVICE_OWNER_ID: owner_id,
		OperationParam.ASYNC_MATCH_SERVICE_MATCH_ID: match_id,
		OperationParam.ASYNC_MATCH_SERVICE_CURRENT_VERSION: version,
		OperationParam.ASYNC_MATCH_SERVICE_SUMMARY: json_summary
	}
	return await _send(ServiceOperation.UPDATE_SUMMARY, data)

func abandon_match(owner_id: String, match_id: String) -> Dictionary:
	var data := {
		OperationParam.ASYNC_MATCH_SERVICE_OWNER_ID: owner_id,
		OperationParam.ASYNC_MATCH_SERVICE_MATCH_ID: match_id
	}
	return await _send(ServiceOperation.ABANDON, data)

func complete_match(owner_id: String, match_id: String) -> Dictionary:
	var data := {
		OperationParam.ASYNC_MATCH_SERVICE_OWNER_ID: owner_id,
		OperationParam.ASYNC_MATCH_SERVICE_MATCH_ID: match_id
	}
	return await _send(ServiceOperation.COMPLETE, data)

func read_match(owner_id: String, match_id: String) -> Dictionary:
	var data := {
		OperationParam.ASYNC_MATCH_SERVICE_OWNER_ID: owner_id,
		OperationParam.ASYNC_MATCH_SERVICE_MATCH_ID: match_id
	}
	return await _send(ServiceOperation.READ_MATCH, data)

func read_match_history(owner_id: String, match_id: String) -> Dictionary:
	var data := {
		OperationParam.ASYNC_MATCH_SERVICE_OWNER_ID: owner_id,
		OperationParam.ASYNC_MATCH_SERVICE_MATCH_ID: match_id
	}
	return await _send(ServiceOperation.READ_MATCH_HISTORY, data)

func find_matches() -> Dictionary:
	return await _send("FIND_MATCHES", {})

func find_complete_matches() -> Dictionary:
	return await _send("FIND_MATCHES_COMPLETED", {})

func delete_match(owner_id: String, match_id: String) -> Dictionary:
	var data := {
		OperationParam.ASYNC_MATCH_SERVICE_OWNER_ID: owner_id,
		OperationParam.ASYNC_MATCH_SERVICE_MATCH_ID: match_id
	}
	return await _send(ServiceOperation.DELETE, data)

func abandon_match_with_summary_data(owner_id: String, match_id: String, push_message: Dictionary, summary: Dictionary) -> Dictionary:
	var data := {
		OperationParam.ASYNC_MATCH_SERVICE_OWNER_ID: owner_id,
		OperationParam.ASYNC_MATCH_SERVICE_MATCH_ID: match_id,
		OperationParam.ASYNC_MATCH_SERVICE_PUSH_MESSAGE: push_message,
		OperationParam.ASYNC_MATCH_SERVICE_SUMMARY: summary
	}
	return await _send(ServiceOperation.ABANDON_MATCH_WITH_SUMMARY_DATA, data)

func complete_match_with_summary_data(owner_id: String, match_id: String, push_message: Dictionary, summary: Dictionary) -> Dictionary:
	var data := {
		OperationParam.ASYNC_MATCH_SERVICE_OWNER_ID: owner_id,
		OperationParam.ASYNC_MATCH_SERVICE_MATCH_ID: match_id,
		OperationParam.ASYNC_MATCH_SERVICE_PUSH_MESSAGE: push_message,
		OperationParam.ASYNC_MATCH_SERVICE_SUMMARY: summary
	}
	return await _send(ServiceOperation.COMPLETE_MATCH_WITH_SUMMARY_DATA, data)

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.ASYNC_MATCH, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
