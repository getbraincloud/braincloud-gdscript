# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudTournament
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

## Processes any outstanding rewards for the given player.
##
## Service Name - Tournament[br]
## Service Operation - CLAIM_TOURNAMENT_REWARD
##
## @param leaderboard_id The leaderboard for the tournament
## @param version_id Version of the tournament. Use -1 for the latest version
func claim_tournament_reward(leaderboard_id: String, version_id: int) -> Dictionary:
	var data := {
		OperationParam.TOURNAMENT_LEADERBOARD_ID: leaderboard_id,
		OperationParam.TOURNAMENT_VERSION_ID: version_id
	}
	return await _send(ServiceOperation.CLAIM_TOURNAMENT_REWARD, data)

## Gets tournament status associated with a leaderboard.
##
## Service Name - Tournament[br]
## Service Operation - GET_TOURNAMENT_STATUS
##
## @param leaderboard_id The leaderboard for the tournament
## @param version_id Version of the tournament. Use -1 for the latest version
func get_tournament_status(leaderboard_id: String, version_id: int) -> Dictionary:
	var data := {
		OperationParam.TOURNAMENT_LEADERBOARD_ID: leaderboard_id,
		OperationParam.TOURNAMENT_VERSION_ID: version_id
	}
	return await _send(ServiceOperation.GET_TOURNAMENT_STATUS, data)

## Gets the status of a division.
##
## Service Name - Tournament[br]
## Service Operation - GET_DIVISION_INFO
##
## @param division_set_id The id for the division
func get_division_info(division_set_id: String) -> Dictionary:
	var data := {
		"divisionSetId": division_set_id
	}
	return await _send(ServiceOperation.GET_DIVISION_INFO, data)

## Returns a list of the player's recently active divisions.
##
## Service Name - Tournament[br]
## Service Operation - GET_MY_DIVISIONS
func get_my_divisions() -> Dictionary:
	return await _send(ServiceOperation.GET_MY_DIVISIONS, {})

## Joins the specified division. Entry fees will be collected if required.
##
## Service Name - Tournament[br]
## Service Operation - JOIN_DIVISION
##
## @param division_set_id The id for the division
## @param tournament_code Tournament to join
## @param initial_score The initial score for players first joining. Usually 0, unless leaderboard is LOW_VALUE
func join_division(division_set_id: String, tournament_code: String, initial_score: int) -> Dictionary:
	var data := {
		"divisionSetId": division_set_id,
		OperationParam.TOURNAMENT_TOURNAMENT_CODE: tournament_code,
		OperationParam.TOURNAMENT_INITIAL_SCORE: initial_score
	}
	return await _send(ServiceOperation.JOIN_DIVISION, data)

## Joins the specified tournament. Any entry fees will be automatically collected.
##
## Service Name - Tournament[br]
## Service Operation - JOIN_TOURNAMENT
##
## @param leaderboard_id The leaderboard for the tournament
## @param tournament_code Tournament to join
## @param initial_score The initial score for players first joining. Usually 0, unless leaderboard is LOW_VALUE
func join_tournament(leaderboard_id: String, tournament_code: String, initial_score: int) -> Dictionary:
	var data := {
		OperationParam.TOURNAMENT_LEADERBOARD_ID: leaderboard_id,
		OperationParam.TOURNAMENT_TOURNAMENT_CODE: tournament_code,
		OperationParam.TOURNAMENT_INITIAL_SCORE: initial_score
	}
	return await _send(ServiceOperation.JOIN_TOURNAMENT, data)

## Removes the player's score from the tournament leaderboard.
##
## Service Name - Tournament[br]
## Service Operation - LEAVE_TOURNAMENT
##
## @param leaderboard_id The leaderboard for the tournament
func leave_tournament(leaderboard_id: String) -> Dictionary:
	var data := {
		OperationParam.TOURNAMENT_LEADERBOARD_ID: leaderboard_id
	}
	return await _send(ServiceOperation.LEAVE_TOURNAMENT, data)

## Posts the user's score to the tournament leaderboard.
##
## Service Name - Tournament[br]
## Service Operation - POST_TOURNAMENT_SCORE
##
## @param leaderboard_id The leaderboard for the tournament
## @param score The score to post
## @param json_data Optional data attached to the leaderboard entry
## @param round_started_epoch Time the match started in UTC milliseconds since epoch
func post_tournament_score(leaderboard_id: String, score: int, json_data: Dictionary, round_started_epoch: int) -> Dictionary:
	var data := {
		OperationParam.TOURNAMENT_LEADERBOARD_ID: leaderboard_id,
		OperationParam.TOURNAMENT_SCORE: score,
		OperationParam.TOURNAMENT_DATA: json_data,
		OperationParam.TOURNAMENT_ROUND_STARTED_EPOCH: round_started_epoch
	}
	return await _send(ServiceOperation.POST_TOURNAMENT_SCORE, data)

## Posts the user's score to the tournament leaderboard and returns surrounding results.
##
## Service Name - Tournament[br]
## Service Operation - POST_TOURNAMENT_SCORE_WITH_RESULTS
##
## @param leaderboard_id The leaderboard for the tournament
## @param score The score to post
## @param json_data Optional data attached to the leaderboard entry
## @param round_started_epoch Time the match started in UTC milliseconds since epoch
## @param sort Sort order of the page
## @param before_count Number of players before the current player to include
## @param after_count Number of players after the current player to include
## @param initial_score Initial score for players first joining. Usually 0, unless leaderboard is LOW_VALUE
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

## Returns the user's expected reward based on the current scores.
##
## Service Name - Tournament[br]
## Service Operation - VIEW_CURRENT_REWARD
##
## @param leaderboard_id The leaderboard for the tournament
func view_current_reward(leaderboard_id: String) -> Dictionary:
	var data := {
		OperationParam.TOURNAMENT_LEADERBOARD_ID: leaderboard_id
	}
	return await _send(ServiceOperation.VIEW_CURRENT_REWARD, data)

## Returns the user's reward from a finished tournament.
##
## Service Name - Tournament[br]
## Service Operation - VIEW_REWARD
##
## @param leaderboard_id The leaderboard for the tournament
## @param version_id Version of the tournament. Use -1 for the latest version
func view_reward(leaderboard_id: String, version_id: int) -> Dictionary:
	var data := {
		OperationParam.TOURNAMENT_LEADERBOARD_ID: leaderboard_id,
		OperationParam.TOURNAMENT_VERSION_ID: version_id
	}
	return await _send(ServiceOperation.VIEW_REWARD, data)

## Starts a tournament for the given leaderboard.
##
## Service Name - Tournament[br]
## Service Operation - START_TOURNAMENT
##
## @param leaderboard_id The leaderboard for the tournament
## @param tournament_code Tournament to start
## @param initial_score The initial score for players first joining. Usually 0, unless leaderboard is LOW_VALUE
func start_tournament(leaderboard_id: String, tournament_code: String, initial_score: int) -> Dictionary:
	var data := {
		OperationParam.TOURNAMENT_LEADERBOARD_ID: leaderboard_id,
		OperationParam.TOURNAMENT_TOURNAMENT_CODE: tournament_code,
		OperationParam.TOURNAMENT_INITIAL_SCORE: initial_score
	}
	return await _send(ServiceOperation.START_TOURNAMENT, data)

## Gets information about a completed tournament.
##
## Service Name - Tournament[br]
## Service Operation - GET_COMPLETED_TOURNAMENT
##
## @param leaderboard_id The leaderboard for the tournament
## @param version_id Version of the tournament
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
