# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudMatchMaking
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

func read() -> Dictionary:
	return await _send(ServiceOperation.READ, {})

func set_player_rating(player_rating: int) -> Dictionary:
	var data := {
		OperationParam.MATCH_MAKING_SERVICE_PLAYER_RATING: player_rating
	}
	return await _send(ServiceOperation.SET_PLAYER_RATING, data)

func reset_player_rating() -> Dictionary:
	return await _send(ServiceOperation.RESET_PLAYER_RATING, {})

func increment_player_rating(increment: int) -> Dictionary:
	var data := {
		OperationParam.MATCH_MAKING_SERVICE_PLAYER_RATING: increment
	}
	return await _send(ServiceOperation.INCREMENT_PLAYER_RATING, data)

func decrement_player_rating(decrement: int) -> Dictionary:
	var data := {
		OperationParam.MATCH_MAKING_SERVICE_PLAYER_RATING: decrement
	}
	return await _send(ServiceOperation.DECREMENT_PLAYER_RATING, data)

func turn_shield_on() -> Dictionary:
	return await _send("SHIELD_ON", {})

func turn_shield_off() -> Dictionary:
	return await _send("SHIELD_OFF", {})

func turn_shield_on_for(minutes: int) -> Dictionary:
	var data := {
		"minutes": minutes
	}
	return await _send("SHIELD_ON_FOR", data)

func increment_shield_on_for(minutes: int) -> Dictionary:
	var data := {
		"minutes": minutes
	}
	return await _send("INCREMENT_SHIELD_ON_FOR", data)

func find_players(range_delta: int, num_matches: int) -> Dictionary:
	var data := {
		"rangeDelta": range_delta,
		OperationParam.MATCH_MAKING_SERVICE_NUM_MATCHES: num_matches
	}
	return await _send("FIND_PLAYERS", data)

func find_players_using_filter(range_delta: int, num_matches: int, json_extra_params: Dictionary) -> Dictionary:
	var data := {
		"rangeDelta": range_delta,
		OperationParam.MATCH_MAKING_SERVICE_NUM_MATCHES: num_matches,
		OperationParam.MATCH_MAKING_SERVICE_EXTRA_PARMS: json_extra_params
	}
	return await _send("FIND_PLAYERS_USING_FILTER", data)

func enable_match_making() -> Dictionary:
	return await _send(ServiceOperation.ENABLE_FOR_MATCH, {})

func disable_match_making() -> Dictionary:
	return await _send(ServiceOperation.DISABLE_FOR_MATCH, {})

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.MATCH_MAKING, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
