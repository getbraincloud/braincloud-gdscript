# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudPlaybackStream
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

func start_stream(target_player_id: String, include_shared_data: bool) -> Dictionary:
	var data := {
		OperationParam.PLAYBACK_STREAM_SERVICE_TARGET_PLAYER_ID: target_player_id,
		OperationParam.PLAYBACK_STREAM_SERVICE_INCLUDE_SHARED_DATA: include_shared_data
	}
	return await _send("START_STREAM", data)

func read_stream(playback_stream_id: String) -> Dictionary:
	var data := {
		OperationParam.PLAYBACK_STREAM_SERVICE_PLAYBACK_STREAM_ID: playback_stream_id
	}
	return await _send("READ_STREAM", data)

func end_stream(playback_stream_id: String) -> Dictionary:
	var data := {
		OperationParam.PLAYBACK_STREAM_SERVICE_PLAYBACK_STREAM_ID: playback_stream_id
	}
	return await _send("END_STREAM", data)

func delete_stream(playback_stream_id: String) -> Dictionary:
	var data := {
		OperationParam.PLAYBACK_STREAM_SERVICE_PLAYBACK_STREAM_ID: playback_stream_id
	}
	return await _send("DELETE_STREAM", data)

func add_event(playback_stream_id: String, event_data: Dictionary, summary: Dictionary) -> Dictionary:
	var data := {
		OperationParam.PLAYBACK_STREAM_SERVICE_PLAYBACK_STREAM_ID: playback_stream_id,
		OperationParam.PLAYBACK_STREAM_SERVICE_EVENT_DATA: event_data,
		OperationParam.PLAYBACK_STREAM_SERVICE_SUMMARY: summary
	}
	return await _send("ADD_EVENT", data)

func get_recent_streams_for_initiating_player(initiating_player_id: String, max_num_returned: int) -> Dictionary:
	var data := {
		"initiatingPlayerId": initiating_player_id,
		OperationParam.PLAYBACK_STREAM_SERVICE_MAX_NUM_RETURNED: max_num_returned
	}
	return await _send("GET_RECENT_STREAMS_FOR_INITIATING_PLAYER", data)

func get_recent_streams_for_target_player(target_player_id: String, max_num_returned: int) -> Dictionary:
	var data := {
		OperationParam.PLAYBACK_STREAM_SERVICE_TARGET_PLAYER_ID: target_player_id,
		OperationParam.PLAYBACK_STREAM_SERVICE_MAX_NUM_RETURNED: max_num_returned
	}
	return await _send("GET_RECENT_STREAMS_FOR_TARGET_PLAYER", data)

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.PLAYBACK_STREAM, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
