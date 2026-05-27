# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudMatchMaking
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

## Read the match making record.
##
## Service Name - MatchMaking[br]
## Service Operation - Read
func read() -> Dictionary:
	return await _send(ServiceOperation.READ, {})

## Sets the player rating.
##
## Service Name - MatchMaking[br]
## Service Operation - SetPlayerRating
##
## @param player_rating The new player rating
func set_player_rating(player_rating: int) -> Dictionary:
	var data := {
		OperationParam.MATCH_MAKING_SERVICE_PLAYER_RATING: player_rating
	}
	return await _send(ServiceOperation.SET_PLAYER_RATING, data)

## Resets the player rating.
##
## Service Name - MatchMaking[br]
## Service Operation - ResetPlayerRating
func reset_player_rating() -> Dictionary:
	return await _send(ServiceOperation.RESET_PLAYER_RATING, {})

## Increments the player rating.
##
## Service Name - MatchMaking[br]
## Service Operation - IncrementPlayerRating
##
## @param increment The increment amount
func increment_player_rating(increment: int) -> Dictionary:
	var data := {
		OperationParam.MATCH_MAKING_SERVICE_PLAYER_RATING: increment
	}
	return await _send(ServiceOperation.INCREMENT_PLAYER_RATING, data)

## Decrements the player rating.
##
## Service Name - MatchMaking[br]
## Service Operation - DecrementPlayerRating
##
## @param decrement The decrement amount
func decrement_player_rating(decrement: int) -> Dictionary:
	var data := {
		OperationParam.MATCH_MAKING_SERVICE_PLAYER_RATING: decrement
	}
	return await _send(ServiceOperation.DECREMENT_PLAYER_RATING, data)

## Turns the match making shield on.
##
## Service Name - MatchMaking[br]
## Service Operation - ShieldOn
func turn_shield_on() -> Dictionary:
	return await _send("SHIELD_ON", {})

## Turns the match making shield off.
##
## Service Name - MatchMaking[br]
## Service Operation - ShieldOff
func turn_shield_off() -> Dictionary:
	return await _send("SHIELD_OFF", {})

## Turns the shield on for the specified number of minutes.
##
## Service Name - MatchMaking[br]
## Service Operation - ShieldOnFor
##
## @param minutes Number of minutes to turn the shield on for
func turn_shield_on_for(minutes: int) -> Dictionary:
	var data := {
		"minutes": minutes
	}
	return await _send("SHIELD_ON_FOR", data)

## Increases the shield on time by the specified number of minutes.
##
## Service Name - MatchMaking[br]
## Service Operation - IncrementShieldOnFor
##
## @param minutes Number of minutes to increase the shield time for
func increment_shield_on_for(minutes: int) -> Dictionary:
	var data := {
		"minutes": minutes
	}
	return await _send("INCREMENT_SHIELD_ON_FOR", data)

## Finds matchmaking enabled players.
##
## Service Name - MatchMaking[br]
## Service Operation - FIND_PLAYERS
##
## @param range_delta The range delta
## @param num_matches The maximum number of matches to return
func find_players(range_delta: int, num_matches: int) -> Dictionary:
	var data := {
		"rangeDelta": range_delta,
		OperationParam.MATCH_MAKING_SERVICE_NUM_MATCHES: num_matches
	}
	return await _send("FIND_PLAYERS", data)

## Finds matchmaking enabled players using a cloud code filter.
##
## Service Name - MatchMaking[br]
## Service Operation - FIND_PLAYERS_USING_FILTER
##
## @param range_delta The range delta
## @param num_matches The maximum number of matches to return
## @param json_extra_params Parameters to pass to the CloudCode filter script
func find_players_using_filter(range_delta: int, num_matches: int, json_extra_params: Dictionary) -> Dictionary:
	var data := {
		"rangeDelta": range_delta,
		OperationParam.MATCH_MAKING_SERVICE_NUM_MATCHES: num_matches,
		OperationParam.MATCH_MAKING_SERVICE_EXTRA_PARMS: json_extra_params
	}
	return await _send("FIND_PLAYERS_USING_FILTER", data)

## Enables match making for the player.
##
## Service Name - MatchMaking[br]
## Service Operation - EnableMatchMaking
func enable_match_making() -> Dictionary:
	return await _send(ServiceOperation.ENABLE_FOR_MATCH, {})

## Disables match making for the player.
##
## Service Name - MatchMaking[br]
## Service Operation - DisableMatchMaking
func disable_match_making() -> Dictionary:
	return await _send(ServiceOperation.DISABLE_FOR_MATCH, {})

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.MATCH_MAKING, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
