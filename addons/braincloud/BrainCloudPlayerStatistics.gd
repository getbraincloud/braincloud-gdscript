# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudPlayerStatistics
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

## Returns the next experience level for the user.
##
## Service Name - PlayerStatistics[br]
## Service Operation - ReadNextXpLevel
func get_next_experience_level() -> Dictionary:
	return await _send(ServiceOperation.READ_NEXT_XPLEVEL, {})

## Read all available user statistics.
##
## Service Name - PlayerStatistics[br]
## Service Operation - Read
func read_all_user_stats() -> Dictionary:
	return await _send(ServiceOperation.READ, {})

## Reads a subset of user statistics as defined by the input collection.
##
## Service Name - PlayerStatistics[br]
## Service Operation - ReadSubset
##
## @param statistics A collection containing the subset of statistics to read
func read_user_stats_subset(statistics: Array) -> Dictionary:
	return await _send(ServiceOperation.READ_SUBSET, {OperationParam.PLAYER_STATISTICS_SERVICE_STATISTICS: statistics})

## Retrieves the user statistics for the given category.
##
## Service Name - PlayerStatistics[br]
## Service Operation - READ_FOR_CATEGORY
##
## @param category The user statistics category
func read_user_stats_for_category(category: String) -> Dictionary:
	return await _send("READ_FOR_CATEGORY", {"category": category})

## Resets all of the statistics for this user back to their initial value.
##
## Service Name - PlayerStatistics[br]
## Service Operation - Reset
func reset_all_user_stats() -> Dictionary:
	return await _send(ServiceOperation.RESET, {})

## Atomically increment (or decrement) user statistics.
## Any rewards triggered from user statistic increments will be considered.
##
## Service Name - PlayerStatistics[br]
## Service Operation - Update
##
## @param json_data The statistics to increment/decrement as a Dictionary
func increment_user_stats(json_data: Dictionary) -> Dictionary:
	return await _send(ServiceOperation.UPDATE, {OperationParam.PLAYER_STATISTICS_SERVICE_STATISTICS: json_data})

## Increments the user's experience. If the user goes up a level,
## the new level details will be returned along with a list of rewards.
##
## Service Name - PlayerStatistics[br]
## Service Operation - UpdateIncrement
##
## @param xp_value The amount to increase the user's experience by
func increment_experience_points(xp_value: int) -> Dictionary:
	return await _send(ServiceOperation.UPDATE, {OperationParam.PLAYER_STATISTICS_SERVICE_EXPERIENCE_POINTS: xp_value})

## Sets the user's experience to an absolute value.
## Note this is simply a set and will not reward the user if their level changes.
##
## Service Name - PlayerStatistics[br]
## Service Operation - SetXpPoints
##
## @param xp_value The amount to set the user's experience to
func set_experience_points(xp_value: int) -> Dictionary:
	return await _send(ServiceOperation.SET_XPPOINTS, {OperationParam.PLAYER_STATISTICS_SERVICE_EXPERIENCE_POINTS: xp_value})

## Apply statistics grammar to a partial set of statistics.
##
## Service Name - PlayerStatistics[br]
## Service Operation - PROCESS_STATISTICS
##
## @param json_data The statistics grammar rules as a Dictionary
func process_statistics(json_data: Dictionary) -> Dictionary:
	return await _send(ServiceOperation.PROCESS_STATISTICS, {OperationParam.PLAYER_STATISTICS_SERVICE_STATISTICS: json_data})

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.PLAYER_STATISTICS, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
