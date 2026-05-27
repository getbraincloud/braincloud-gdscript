# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudAsyncMatch
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

## Creates an instance of an asynchronous match.
##
## Service Name - AsyncMatch[br]
## Service Operation - Create
##
## @param json_opponents Array identifying the opponent platform and id for this match
## @param push_message Optional push notification message to send to the other party
func create_match(json_opponents: Array, push_message: Dictionary) -> Dictionary:
	var data := {
		OperationParam.ASYNC_MATCH_SERVICE_OPPONENTS: json_opponents,
		OperationParam.ASYNC_MATCH_SERVICE_PUSH_MESSAGE: push_message
	}
	return await _send(ServiceOperation.CREATE, data)

## Creates an instance of an asynchronous match with an initial turn.
##
## Service Name - AsyncMatch[br]
## Service Operation - Create
##
## @param json_opponents Array identifying the opponent platform and id for this match
## @param json_match_state JSON blob provided by the caller
## @param push_message Optional push notification message to send to the other party
## @param next_player Optionally force the next player to be a specific player
## @param json_summary Optional summary of the game when listing their games
func create_match_with_initial_turn(json_opponents: Array, json_match_state: Dictionary, push_message: Dictionary, next_player: String, json_summary: Dictionary) -> Dictionary:
	var data := {
		OperationParam.ASYNC_MATCH_SERVICE_OPPONENTS: json_opponents,
		OperationParam.ASYNC_MATCH_SERVICE_TURN_DATA: json_match_state,
		OperationParam.ASYNC_MATCH_SERVICE_PUSH_MESSAGE: push_message,
		"nextPlayer": next_player,
		OperationParam.ASYNC_MATCH_SERVICE_SUMMARY: json_summary
	}
	return await _send(ServiceOperation.CREATE, data)

## Submits a turn for the given match.
##
## Service Name - AsyncMatch[br]
## Service Operation - SubmitTurn
##
## @param owner_id Match owner identifier
## @param match_id Match identifier
## @param version Game state version to ensure turns are submitted once and in order
## @param json_match_state JSON blob provided by the caller
## @param push_message Optional push notification message to send to the other party
## @param next_player Optionally force the next player to be a specific player
## @param json_summary Optional summary that other players see when listing their games
## @param json_statistics Optional statistics blob provided by the caller
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

## Allows the current player to update match summary without completing their turn.
##
## Service Name - AsyncMatch[br]
## Service Operation - UpdateMatchSummary
##
## @param owner_id Match owner identifier
## @param match_id Match identifier
## @param version Game state version to ensure data integrity
## @param json_summary JSON string that other players see as a summary of the game
func update_match_summary(owner_id: String, match_id: String, version: int, json_summary: Dictionary) -> Dictionary:
	var data := {
		OperationParam.ASYNC_MATCH_SERVICE_OWNER_ID: owner_id,
		OperationParam.ASYNC_MATCH_SERVICE_MATCH_ID: match_id,
		OperationParam.ASYNC_MATCH_SERVICE_CURRENT_VERSION: version,
		OperationParam.ASYNC_MATCH_SERVICE_SUMMARY: json_summary
	}
	return await _send(ServiceOperation.UPDATE_SUMMARY, data)

## Marks the given match as abandoned.
##
## Service Name - AsyncMatch[br]
## Service Operation - Abandon
##
## @param owner_id Match owner identifier
## @param match_id Match identifier
func abandon_match(owner_id: String, match_id: String) -> Dictionary:
	var data := {
		OperationParam.ASYNC_MATCH_SERVICE_OWNER_ID: owner_id,
		OperationParam.ASYNC_MATCH_SERVICE_MATCH_ID: match_id
	}
	return await _send(ServiceOperation.ABANDON, data)

## Marks the given match as complete.
##
## Service Name - AsyncMatch[br]
## Service Operation - Complete
##
## @param owner_id Match owner identifier
## @param match_id Match identifier
func complete_match(owner_id: String, match_id: String) -> Dictionary:
	var data := {
		OperationParam.ASYNC_MATCH_SERVICE_OWNER_ID: owner_id,
		OperationParam.ASYNC_MATCH_SERVICE_MATCH_ID: match_id
	}
	return await _send(ServiceOperation.COMPLETE, data)

## Returns the current state of the given match.
##
## Service Name - AsyncMatch[br]
## Service Operation - ReadMatch
##
## @param owner_id Match owner identifier
## @param match_id Match identifier
func read_match(owner_id: String, match_id: String) -> Dictionary:
	var data := {
		OperationParam.ASYNC_MATCH_SERVICE_OWNER_ID: owner_id,
		OperationParam.ASYNC_MATCH_SERVICE_MATCH_ID: match_id
	}
	return await _send(ServiceOperation.READ_MATCH, data)

## Returns the match history of the given match.
##
## Service Name - AsyncMatch[br]
## Service Operation - ReadMatchHistory
##
## @param owner_id Match owner identifier
## @param match_id Match identifier
func read_match_history(owner_id: String, match_id: String) -> Dictionary:
	var data := {
		OperationParam.ASYNC_MATCH_SERVICE_OWNER_ID: owner_id,
		OperationParam.ASYNC_MATCH_SERVICE_MATCH_ID: match_id
	}
	return await _send(ServiceOperation.READ_MATCH_HISTORY, data)

## Returns all matches that are NOT in a COMPLETE state for which the player is involved.
##
## Service Name - AsyncMatch[br]
## Service Operation - FindMatches
func find_matches() -> Dictionary:
	return await _send("FIND_MATCHES", {})

## Returns all matches that are in a COMPLETE state for which the player is involved.
##
## Service Name - AsyncMatch[br]
## Service Operation - FindMatchesCompleted
func find_complete_matches() -> Dictionary:
	return await _send("FIND_MATCHES_COMPLETED", {})

## Removes the match and match history from the server.
##
## Service Name - AsyncMatch[br]
## Service Operation - Delete
##
## @param owner_id Match owner identifier
## @param match_id Match identifier
func delete_match(owner_id: String, match_id: String) -> Dictionary:
	var data := {
		OperationParam.ASYNC_MATCH_SERVICE_OWNER_ID: owner_id,
		OperationParam.ASYNC_MATCH_SERVICE_MATCH_ID: match_id
	}
	return await _send(ServiceOperation.DELETE, data)

## Marks the given match as abandoned. This call can send a notification message.
##
## Service Name - AsyncMatch[br]
## Service Operation - AbandonMatchWithSummaryData
##
## @param owner_id Match owner identifier
## @param match_id Match identifier
## @param push_message Optional push notification message to send to the other party
## @param summary Summary data to associate with the abandoned match
func abandon_match_with_summary_data(owner_id: String, match_id: String, push_message: Dictionary, summary: Dictionary) -> Dictionary:
	var data := {
		OperationParam.ASYNC_MATCH_SERVICE_OWNER_ID: owner_id,
		OperationParam.ASYNC_MATCH_SERVICE_MATCH_ID: match_id,
		OperationParam.ASYNC_MATCH_SERVICE_PUSH_MESSAGE: push_message,
		OperationParam.ASYNC_MATCH_SERVICE_SUMMARY: summary
	}
	return await _send(ServiceOperation.ABANDON_MATCH_WITH_SUMMARY_DATA, data)

## Marks the given match as complete. This call can send a notification message.
##
## Service Name - AsyncMatch[br]
## Service Operation - CompleteMatchWithSummaryData
##
## @param owner_id Match owner identifier
## @param match_id Match identifier
## @param push_message Optional push notification message to send to the other party
## @param summary Summary data to associate with the completed match
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
