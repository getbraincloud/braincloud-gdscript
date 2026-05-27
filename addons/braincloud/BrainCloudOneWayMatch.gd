# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudOneWayMatch
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

## Starts a match.
##
## Service Name - OneWayMatch[br]
## Service Operation - StartMatch
##
## @param other_player_id The player to start a match with
## @param range_delta The range delta used for the initial match search
func start_match(other_player_id: String, range_delta: int) -> Dictionary:
	var data := {
		OperationParam.ONE_WAY_MATCH_SERVICE_PLAYER_ID: other_player_id,
		OperationParam.ONE_WAY_MATCH_SERVICE_RANGE_DELTA: range_delta
	}
	return await _send(ServiceOperation.START_MATCH, data)

## Cancels a match.
##
## Service Name - OneWayMatch[br]
## Service Operation - CancelMatch
##
## @param playback_stream_id The playback stream id returned in the start match
func cancel_match(playback_stream_id: String) -> Dictionary:
	var data := {
		OperationParam.ONE_WAY_MATCH_SERVICE_PLAY_BACK_STREAM_ID: playback_stream_id
	}
	return await _send(ServiceOperation.CANCEL_MATCH, data)

## Completes a match.
##
## Service Name - OneWayMatch[br]
## Service Operation - CompleteMatch
##
## @param playback_stream_id The playback stream id returned in the initial start match
func complete_match(playback_stream_id: String) -> Dictionary:
	var data := {
		OperationParam.ONE_WAY_MATCH_SERVICE_PLAY_BACK_STREAM_ID: playback_stream_id
	}
	return await _send(ServiceOperation.COMPLETE_MATCH, data)

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.ONE_WAY_MATCH, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
