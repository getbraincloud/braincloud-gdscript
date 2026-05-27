# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudPlaybackStream
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

## Starts a stream.
##
## Service Name - PlaybackStream[br]
## Service Operation - StartStream
##
## @param target_player_id The player to start a stream with
## @param include_shared_data Whether to include shared data in the stream
func start_stream(target_player_id: String, include_shared_data: bool) -> Dictionary:
	var data := {
		OperationParam.PLAYBACK_STREAM_SERVICE_TARGET_PLAYER_ID: target_player_id,
		OperationParam.PLAYBACK_STREAM_SERVICE_INCLUDE_SHARED_DATA: include_shared_data
	}
	return await _send("START_STREAM", data)

## Reads a stream.
##
## Service Name - PlaybackStream[br]
## Service Operation - ReadStream
##
## @param playback_stream_id Identifies the stream to read
func read_stream(playback_stream_id: String) -> Dictionary:
	var data := {
		OperationParam.PLAYBACK_STREAM_SERVICE_PLAYBACK_STREAM_ID: playback_stream_id
	}
	return await _send("READ_STREAM", data)

## Ends a stream.
##
## Service Name - PlaybackStream[br]
## Service Operation - EndStream
##
## @param playback_stream_id Identifies the stream to end
func end_stream(playback_stream_id: String) -> Dictionary:
	var data := {
		OperationParam.PLAYBACK_STREAM_SERVICE_PLAYBACK_STREAM_ID: playback_stream_id
	}
	return await _send("END_STREAM", data)

## Deletes a stream.
##
## Service Name - PlaybackStream[br]
## Service Operation - DeleteStream
##
## @param playback_stream_id Identifies the stream to delete
func delete_stream(playback_stream_id: String) -> Dictionary:
	var data := {
		OperationParam.PLAYBACK_STREAM_SERVICE_PLAYBACK_STREAM_ID: playback_stream_id
	}
	return await _send("DELETE_STREAM", data)

## Adds a stream event.
##
## Service Name - PlaybackStream[br]
## Service Operation - AddEvent
##
## @param playback_stream_id Identifies the stream to add the event to
## @param event_data Describes the event
## @param summary Current summary data as of this event
func add_event(playback_stream_id: String, event_data: Dictionary, summary: Dictionary) -> Dictionary:
	var data := {
		OperationParam.PLAYBACK_STREAM_SERVICE_PLAYBACK_STREAM_ID: playback_stream_id,
		OperationParam.PLAYBACK_STREAM_SERVICE_EVENT_DATA: event_data,
		OperationParam.PLAYBACK_STREAM_SERVICE_SUMMARY: summary
	}
	return await _send("ADD_EVENT", data)

## Gets recent stream summaries for initiating player.
##
## Service Name - PlaybackStream[br]
## Service Operation - GetRecentStreamsForInitiatingPlayer
##
## @param initiating_player_id The player that started the stream
## @param max_num_returned The max number of streams to query
func get_recent_streams_for_initiating_player(initiating_player_id: String, max_num_returned: int) -> Dictionary:
	var data := {
		"initiatingPlayerId": initiating_player_id,
		OperationParam.PLAYBACK_STREAM_SERVICE_MAX_NUM_RETURNED: max_num_returned
	}
	return await _send("GET_RECENT_STREAMS_FOR_INITIATING_PLAYER", data)

## Gets recent stream summaries for target player.
##
## Service Name - PlaybackStream[br]
## Service Operation - GetRecentStreamsForTargetPlayer
##
## @param target_player_id The player that was the target of the stream
## @param max_num_returned The max number of streams to query
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
