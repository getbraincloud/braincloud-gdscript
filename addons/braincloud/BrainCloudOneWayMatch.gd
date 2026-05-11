# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudOneWayMatch
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

func start_match(other_player_id: String, range_delta: int) -> Dictionary:
	var data := {
		OperationParam.ONE_WAY_MATCH_SERVICE_PLAYER_ID: other_player_id,
		OperationParam.ONE_WAY_MATCH_SERVICE_RANGE_DELTA: range_delta
	}
	return await _send(ServiceOperation.START_MATCH, data)

func cancel_match(playback_stream_id: String) -> Dictionary:
	var data := {
		OperationParam.ONE_WAY_MATCH_SERVICE_PLAY_BACK_STREAM_ID: playback_stream_id
	}
	return await _send(ServiceOperation.CANCEL_MATCH, data)

func complete_match(playback_stream_id: String) -> Dictionary:
	var data := {
		OperationParam.ONE_WAY_MATCH_SERVICE_PLAY_BACK_STREAM_ID: playback_stream_id
	}
	return await _send(ServiceOperation.COMPLETE_MATCH, data)

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.ONE_WAY_MATCH, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
