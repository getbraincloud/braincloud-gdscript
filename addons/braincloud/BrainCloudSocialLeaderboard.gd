# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudSocialLeaderboard
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

func get_social_leaderboard(leaderboard_id: String, replace_name: bool) -> Dictionary:
	var data := {
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_LEADERBOARD_ID: leaderboard_id,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_REPLACE_SCORE: replace_name
	}
	return await _send(ServiceOperation.GET_SOCIAL_LEADERBOARD, data)

func get_social_leaderboard_by_version(leaderboard_id: String, replace_name: bool, version_id: int) -> Dictionary:
	var data := {
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_LEADERBOARD_ID: leaderboard_id,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_REPLACE_SCORE: replace_name,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_VERSION_ID: version_id
	}
	return await _send(ServiceOperation.GET_SOCIAL_LEADERBOARD_BY_VERSION, data)

func get_multi_social_leaderboard(leaderboard_ids: Array, leaderboard_results_count: int, replace_name: bool) -> Dictionary:
	var data := {
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_LEADERBOARD_IDS: leaderboard_ids,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_LEADERBOARD_RESULT_COUNT: leaderboard_results_count,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_REPLACE_SCORE: replace_name
	}
	return await _send(ServiceOperation.GET_MULTI_SOCIAL_LEADERBOARD, data)

func get_global_leaderboard_page(leaderboard_id: String, sort: String, start_index: int, end_index: int) -> Dictionary:
	var data := {
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_LEADERBOARD_ID: leaderboard_id,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_SORT: sort,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_START_INDEX: start_index,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_END_INDEX: end_index
	}
	return await _send(ServiceOperation.GET_GLOBAL_LEADERBOARD_PAGE, data)

func get_global_leaderboard_page_by_version(leaderboard_id: String, sort: String, start_index: int, end_index: int, version_id: int) -> Dictionary:
	var data := {
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_LEADERBOARD_ID: leaderboard_id,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_SORT: sort,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_START_INDEX: start_index,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_END_INDEX: end_index,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_VERSION_ID: version_id
	}
	return await _send(ServiceOperation.GET_GLOBAL_LEADERBOARD_PAGE, data)

func get_global_leaderboard_view(leaderboard_id: String, sort: String, before_count: int, after_count: int) -> Dictionary:
	var data := {
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_LEADERBOARD_ID: leaderboard_id,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_SORT: sort,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_BEFORE_COUNT: before_count,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_AFTER_COUNT: after_count
	}
	return await _send(ServiceOperation.GET_GLOBAL_LEADERBOARD_VIEW, data)

func get_global_leaderboard_view_by_version(leaderboard_id: String, sort: String, before_count: int, after_count: int, version_id: int) -> Dictionary:
	var data := {
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_LEADERBOARD_ID: leaderboard_id,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_SORT: sort,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_BEFORE_COUNT: before_count,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_AFTER_COUNT: after_count,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_VERSION_ID: version_id
	}
	return await _send(ServiceOperation.GET_GLOBAL_LEADERBOARD_VIEW, data)

func get_global_leaderboard_entry_count(leaderboard_id: String) -> Dictionary:
	var data := {
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_LEADERBOARD_ID: leaderboard_id
	}
	return await _send(ServiceOperation.GET_GLOBAL_LEADERBOARD_ENTRY_COUNT, data)

func get_global_leaderboard_entry_count_by_version(leaderboard_id: String, version_id: int) -> Dictionary:
	var data := {
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_LEADERBOARD_ID: leaderboard_id,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_VERSION_ID: version_id
	}
	return await _send(ServiceOperation.GET_GLOBAL_LEADERBOARD_ENTRY_COUNT, data)

func get_global_leaderboard_versions(leaderboard_id: String) -> Dictionary:
	var data := {
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_LEADERBOARD_ID: leaderboard_id
	}
	return await _send(ServiceOperation.GET_GLOBAL_LEADERBOARD_VERSIONS, data)

func post_score_to_leaderboard(leaderboard_id: String, score: int, json_other_data: Dictionary) -> Dictionary:
	var data := {
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_LEADERBOARD_ID: leaderboard_id,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_BEST_SCORE: score,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_DATA: json_other_data
	}
	return await _send(ServiceOperation.POST_SCORE, data)

func post_score_to_dynamic_leaderboard(leaderboard_id: String, score: int, json_other_data: Dictionary, leaderboard_type: String, rotation_type: String, rotation_reset: int, retain_count: int) -> Dictionary:
	var data := {
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_LEADERBOARD_ID: leaderboard_id,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_SCORE: score,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_DATA: json_other_data,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_LEADERBOARD_TYPE: leaderboard_type,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_ROTATION_TYPE: rotation_type,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_ROTATION_RESET: rotation_reset,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_RETAIN_COUNT: retain_count
	}
	return await _send(ServiceOperation.POST_SCORE_TO_DYNAMIC_LEADERBOARD, data)

func post_score_to_dynamic_leaderboard_utc(leaderboard_id: String, score: int, json_other_data: Dictionary, leaderboard_type: String, rotation_type: String, rotation_reset_utc: int, retain_count: int) -> Dictionary:
	var data := {
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_LEADERBOARD_ID: leaderboard_id,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_SCORE: score,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_DATA: json_other_data,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_LEADERBOARD_TYPE: leaderboard_type,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_ROTATION_TYPE: rotation_type,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_ROTATION_RESET: rotation_reset_utc,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_RETAIN_COUNT: retain_count
	}
	return await _send(ServiceOperation.POST_SCORE_TO_DYNAMIC_LEADERBOARD_UTC, data)

func remove_player_score(leaderboard_id: String, version_id: int) -> Dictionary:
	var data := {
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_LEADERBOARD_ID: leaderboard_id,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_VERSION_ID: version_id
	}
	return await _send(ServiceOperation.REMOVE_PLAYER_SCORE, data)

func get_player_score(leaderboard_id: String, version_id: int) -> Dictionary:
	var data := {
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_LEADERBOARD_ID: leaderboard_id,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_VERSION_ID: version_id
	}
	return await _send(ServiceOperation.GET_PLAYER_SCORE, data)

func get_player_scores_from_leaderboards(leaderboard_ids: Array) -> Dictionary:
	var data := {
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_LEADERBOARD_IDS: leaderboard_ids
	}
	return await _send(ServiceOperation.GET_PLAYER_SCORES_FROM_LEADERBOARDS, data)

func get_player_scores(leaderboard_id: String, version_id: int, max_results: int) -> Dictionary:
	var data := {
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_LEADERBOARD_ID: leaderboard_id,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_VERSION_ID: version_id,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_NUM_RESULTS_TO_RETURN: max_results
	}
	return await _send(ServiceOperation.GET_PLAYER_SCORES, data)

func list_all_leaderboards() -> Dictionary:
	return await _send(ServiceOperation.LIST_ALL_LEADERBOARDS, {})

func get_group_leaderboard(leaderboard_id: String, group_id: String) -> Dictionary:
	var data := {
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_LEADERBOARD_ID: leaderboard_id,
		OperationParam.GROUP_ID: group_id
	}
	return await _send(ServiceOperation.GET_GROUP_LEADERBOARD, data)

func get_group_leaderboard_view(leaderboard_id: String, group_id: String, sort: String, before_count: int, after_count: int) -> Dictionary:
	var data := {
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_LEADERBOARD_ID: leaderboard_id,
		OperationParam.GROUP_ID: group_id,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_SORT: sort,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_BEFORE_COUNT: before_count,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_AFTER_COUNT: after_count
	}
	return await _send(ServiceOperation.GET_GROUP_LEADERBOARD_VIEW, data)

func post_score_to_leaderboard_using_config(leaderboard_id: String, score: int, score_data: Dictionary, config_json: Dictionary) -> Dictionary:
	var data := {
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_LEADERBOARD_ID: leaderboard_id,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_SCORE: score,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_SCORE_DATA: score_data,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_CONFIG_JSON: config_json
	}
	return await _send(ServiceOperation.POST_SCORE_TO_DYNAMIC_LEADERBOARD_USING_CONFIG, data)

func remove_group_score(leaderboard_id: String, group_id: String, score: int, version_id: int) -> Dictionary:
	var data := {
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_LEADERBOARD_ID: leaderboard_id,
		OperationParam.GROUP_ID: group_id,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_SCORE: score,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_VERSION_ID: version_id
	}
	return await _send(ServiceOperation.REMOVE_GROUP_SCORE, data)

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.LEADERBOARD, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
