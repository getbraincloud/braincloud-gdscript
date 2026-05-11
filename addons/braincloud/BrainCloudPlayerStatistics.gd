# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudPlayerStatistics
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

func get_next_experience_level() -> Dictionary:
	return await _send(ServiceOperation.READ_NEXT_XPLEVEL, {})

func read_all_user_stats() -> Dictionary:
	return await _send(ServiceOperation.READ, {})

func read_user_stats_subset(statistics: Array) -> Dictionary:
	return await _send(ServiceOperation.READ_SUBSET, {OperationParam.PLAYER_STATISTICS_SERVICE_STATISTICS: statistics})

func read_user_stats_for_category(category: String) -> Dictionary:
	return await _send("READ_FOR_CATEGORY", {"category": category})

func reset_all_user_stats() -> Dictionary:
	return await _send(ServiceOperation.RESET, {})

func increment_user_stats(json_data: Dictionary) -> Dictionary:
	return await _send(ServiceOperation.UPDATE, {OperationParam.PLAYER_STATISTICS_SERVICE_STATISTICS: json_data})

func increment_experience_points(xp_value: int) -> Dictionary:
	return await _send(ServiceOperation.UPDATE, {OperationParam.PLAYER_STATISTICS_SERVICE_EXPERIENCE_POINTS: xp_value})

func set_experience_points(xp_value: int) -> Dictionary:
	return await _send(ServiceOperation.SET_XPPOINTS, {OperationParam.PLAYER_STATISTICS_SERVICE_EXPERIENCE_POINTS: xp_value})

func process_statistics(json_data: Dictionary) -> Dictionary:
	return await _send(ServiceOperation.PROCESS_STATISTICS, {OperationParam.PLAYER_STATISTICS_SERVICE_STATISTICS: json_data})

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.PLAYER_STATISTICS, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
