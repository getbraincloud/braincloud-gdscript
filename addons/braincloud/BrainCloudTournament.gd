# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudTournament
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

func claim_tournament_reward(leaderboard_id: String, version_id: int) -> Dictionary:
	var data := {
		OperationParam.TOURNAMENT_LEADERBOARD_ID: leaderboard_id,
		OperationParam.TOURNAMENT_VERSION_ID: version_id
	}
	return await _send(ServiceOperation.CLAIM_TOURNAMENT_REWARD, data)

func get_tournament_status(leaderboard_id: String, version_id: int) -> Dictionary:
	var data := {
		OperationParam.TOURNAMENT_LEADERBOARD_ID: leaderboard_id,
		OperationParam.TOURNAMENT_VERSION_ID: version_id
	}
	return await _send(ServiceOperation.GET_TOURNAMENT_STATUS, data)

func get_division_info(division_set_id: String) -> Dictionary:
	var data := {
		"divisionSetId": division_set_id
	}
	return await _send(ServiceOperation.GET_DIVISION_INFO, data)

func get_my_divisions() -> Dictionary:
	return await _send(ServiceOperation.GET_MY_DIVISIONS, {})

func join_division(division_set_id: String, tournament_code: String, initial_score: int) -> Dictionary:
	var data := {
		"divisionSetId": division_set_id,
		OperationParam.TOURNAMENT_TOURNAMENT_CODE: tournament_code,
		OperationParam.TOURNAMENT_INITIAL_SCORE: initial_score
	}
	return await _send(ServiceOperation.JOIN_DIVISION, data)

func join_tournament(leaderboard_id: String, tournament_code: String, initial_score: int) -> Dictionary:
	var data := {
		OperationParam.TOURNAMENT_LEADERBOARD_ID: leaderboard_id,
		OperationParam.TOURNAMENT_TOURNAMENT_CODE: tournament_code,
		OperationParam.TOURNAMENT_INITIAL_SCORE: initial_score
	}
	return await _send(ServiceOperation.JOIN_TOURNAMENT, data)

func leave_tournament(leaderboard_id: String) -> Dictionary:
	var data := {
		OperationParam.TOURNAMENT_LEADERBOARD_ID: leaderboard_id
	}
	return await _send(ServiceOperation.LEAVE_TOURNAMENT, data)

func post_tournament_score(leaderboard_id: String, score: int, json_data: Dictionary, round_started_epoch: int) -> Dictionary:
	var data := {
		OperationParam.TOURNAMENT_LEADERBOARD_ID: leaderboard_id,
		OperationParam.TOURNAMENT_SCORE: score,
		OperationParam.TOURNAMENT_DATA: json_data,
		OperationParam.TOURNAMENT_ROUND_STARTED_EPOCH: round_started_epoch
	}
	return await _send(ServiceOperation.POST_TOURNAMENT_SCORE, data)

func post_tournament_score_with_results(leaderboard_id: String, score: int, json_data: Dictionary, round_started_epoch: int, sort: String, before_count: int, after_count: int, initial_score: int) -> Dictionary:
	var data := {
		OperationParam.TOURNAMENT_LEADERBOARD_ID: leaderboard_id,
		OperationParam.TOURNAMENT_SCORE: score,
		OperationParam.TOURNAMENT_DATA: json_data,
		OperationParam.TOURNAMENT_ROUND_STARTED_EPOCH: round_started_epoch,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_SORT: sort,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_BEFORE_COUNT: before_count,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_AFTER_COUNT: after_count,
		OperationParam.TOURNAMENT_INITIAL_SCORE: initial_score
	}
	return await _send(ServiceOperation.POST_TOURNAMENT_SCORE_WITH_RESULTS, data)

func view_current_reward(leaderboard_id: String) -> Dictionary:
	var data := {
		OperationParam.TOURNAMENT_LEADERBOARD_ID: leaderboard_id
	}
	return await _send(ServiceOperation.VIEW_CURRENT_REWARD, data)

func view_reward(leaderboard_id: String, version_id: int) -> Dictionary:
	var data := {
		OperationParam.TOURNAMENT_LEADERBOARD_ID: leaderboard_id,
		OperationParam.TOURNAMENT_VERSION_ID: version_id
	}
	return await _send(ServiceOperation.VIEW_REWARD, data)

func start_tournament(leaderboard_id: String, tournament_code: String, initial_score: int) -> Dictionary:
	var data := {
		OperationParam.TOURNAMENT_LEADERBOARD_ID: leaderboard_id,
		OperationParam.TOURNAMENT_TOURNAMENT_CODE: tournament_code,
		OperationParam.TOURNAMENT_INITIAL_SCORE: initial_score
	}
	return await _send(ServiceOperation.START_TOURNAMENT, data)

func get_completed_tournament(leaderboard_id: String, version_id: int) -> Dictionary:
	var data := {
		OperationParam.TOURNAMENT_LEADERBOARD_ID: leaderboard_id,
		OperationParam.TOURNAMENT_VERSION_ID: version_id
	}
	return await _send(ServiceOperation.GET_COMPLETED_TOURNAMENT, data)

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.TOURNAMENT, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
