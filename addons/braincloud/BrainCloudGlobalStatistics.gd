# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudGlobalStatistics
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

func read_all_global_stats() -> Dictionary:
	return await _send(ServiceOperation.READ, {})

func read_global_stats_subset(global_stats: Array) -> Dictionary:
	return await _send(ServiceOperation.READ_SUBSET, {OperationParam.GLOBAL_STATISTICS_SERVICE_STATISTICS: global_stats})

func query_global_stats_by_category(category: String) -> Dictionary:
	return await _send("READ_FOR_CATEGORY", {"category": category})

func increment_global_game_stat(json_data: Dictionary) -> Dictionary:
	return await _send(ServiceOperation.UPDATE, {OperationParam.GLOBAL_STATISTICS_SERVICE_STATISTICS: json_data})

func increment_global_stats(json_data: Dictionary) -> Dictionary:
	return await increment_global_game_stat(json_data)

func process_statistics(json_data: Dictionary) -> Dictionary:
	return await _send(ServiceOperation.PROCESS_STATISTICS, {OperationParam.GLOBAL_STATISTICS_SERVICE_STATISTICS: json_data})

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.GLOBAL_STATISTICS, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
