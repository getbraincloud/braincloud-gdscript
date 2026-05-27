# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudGlobalStatistics
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

## Method returns all of the global statistics.
##
## Service Name - GlobalStatistics[br]
## Service Operation - Read
func read_all_global_stats() -> Dictionary:
	return await _send(ServiceOperation.READ, {})

## Reads a subset of global statistics as defined by the input collection.
##
## Service Name - GlobalStatistics[br]
## Service Operation - ReadSubset
##
## @param global_stats A collection containing the statistic keys to read
func read_global_stats_subset(global_stats: Array) -> Dictionary:
	return await _send(ServiceOperation.READ_SUBSET, {OperationParam.GLOBAL_STATISTICS_SERVICE_STATISTICS: global_stats})

## Method retrieves the global statistics for the given category.
##
## Service Name - GlobalStatistics[br]
## Service Operation - READ_FOR_CATEGORY
##
## @param category The global statistics category
func query_global_stats_by_category(category: String) -> Dictionary:
	return await _send("READ_FOR_CATEGORY", {"category": category})

## Atomically increment (or decrement) global statistics.
## Global statistics are defined through the brainCloud portal.
##
## Service Name - GlobalStatistics[br]
## Service Operation - UpdateIncrement
##
## @param json_data The statistics to increment/decrement as a Dictionary
func increment_global_game_stat(json_data: Dictionary) -> Dictionary:
	return await _send(ServiceOperation.UPDATE, {OperationParam.GLOBAL_STATISTICS_SERVICE_STATISTICS: json_data})

## Atomically increment (or decrement) global statistics. Alias for increment_global_game_stat.
##
## Service Name - GlobalStatistics[br]
## Service Operation - UpdateIncrement
##
## @param json_data The statistics to increment/decrement as a Dictionary
func increment_global_stats(json_data: Dictionary) -> Dictionary:
	return await increment_global_game_stat(json_data)

## Apply statistics grammar to a partial set of statistics.
##
## Service Name - GlobalStatistics[br]
## Service Operation - PROCESS_STATISTICS
##
## @param json_data The statistics grammar rules as a Dictionary
func process_statistics(json_data: Dictionary) -> Dictionary:
	return await _send(ServiceOperation.PROCESS_STATISTICS, {OperationParam.GLOBAL_STATISTICS_SERVICE_STATISTICS: json_data})

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.GLOBAL_STATISTICS, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
