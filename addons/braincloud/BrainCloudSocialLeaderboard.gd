# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudSocialLeaderboard
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

## Returns the social leaderboard for the given leaderboard, showing the scores of the current user and their friends.
##
## Service Name - SocialLeaderboard[br]
## Service Operation - GetSocialLeaderboard
##
## @param leaderboard_id The id of the leaderboard to retrieve
## @param replace_name Whether to replace the player name with "You"
func get_social_leaderboard(leaderboard_id: String, replace_name: bool) -> Dictionary:
	var data := {
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_LEADERBOARD_ID: leaderboard_id,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_REPLACE_SCORE: replace_name
	}
	return await _send(ServiceOperation.GET_SOCIAL_LEADERBOARD, data)

## Returns the social leaderboard for the given leaderboard at a specific version.
##
## Service Name - SocialLeaderboard[br]
## Service Operation - GetSocialLeaderboardByVersion
##
## @param leaderboard_id The id of the leaderboard to retrieve
## @param replace_name Whether to replace the player name with "You"
## @param version_id The version of the leaderboard to retrieve
func get_social_leaderboard_by_version(leaderboard_id: String, replace_name: bool, version_id: int) -> Dictionary:
	var data := {
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_LEADERBOARD_ID: leaderboard_id,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_REPLACE_SCORE: replace_name,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_VERSION_ID: version_id
	}
	return await _send(ServiceOperation.GET_SOCIAL_LEADERBOARD_BY_VERSION, data)

## Returns the social leaderboard for multiple leaderboards at once.
##
## Service Name - SocialLeaderboard[br]
## Service Operation - GetMultiSocialLeaderboard
##
## @param leaderboard_ids Array of leaderboard ids to retrieve
## @param leaderboard_results_count The maximum number of results per leaderboard
## @param replace_name Whether to replace the player name with "You"
func get_multi_social_leaderboard(leaderboard_ids: Array, leaderboard_results_count: int, replace_name: bool) -> Dictionary:
	var data := {
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_LEADERBOARD_IDS: leaderboard_ids,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_LEADERBOARD_RESULT_COUNT: leaderboard_results_count,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_REPLACE_SCORE: replace_name
	}
	return await _send(ServiceOperation.GET_MULTI_SOCIAL_LEADERBOARD, data)

## Returns a page of the global leaderboard.
##
## Service Name - SocialLeaderboard[br]
## Service Operation - GetGlobalLeaderboardPage
##
## @param leaderboard_id The id of the leaderboard to retrieve
## @param sort Sort order ("HIGH_TO_LOW" or "LOW_TO_HIGH")
## @param start_index Numeric start index of the entries to return
## @param end_index Numeric end index of the entries to return
func get_global_leaderboard_page(leaderboard_id: String, sort: String, start_index: int, end_index: int) -> Dictionary:
	var data := {
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_LEADERBOARD_ID: leaderboard_id,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_SORT: sort,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_START_INDEX: start_index,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_END_INDEX: end_index
	}
	return await _send(ServiceOperation.GET_GLOBAL_LEADERBOARD_PAGE, data)

## Returns a page of the global leaderboard at a specific version.
##
## Service Name - SocialLeaderboard[br]
## Service Operation - GetGlobalLeaderboardPage
##
## @param leaderboard_id The id of the leaderboard to retrieve
## @param sort Sort order ("HIGH_TO_LOW" or "LOW_TO_HIGH")
## @param start_index Numeric start index of the entries to return
## @param end_index Numeric end index of the entries to return
## @param version_id The version of the leaderboard to retrieve
func get_global_leaderboard_page_by_version(leaderboard_id: String, sort: String, start_index: int, end_index: int, version_id: int) -> Dictionary:
	var data := {
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_LEADERBOARD_ID: leaderboard_id,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_SORT: sort,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_START_INDEX: start_index,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_END_INDEX: end_index,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_VERSION_ID: version_id
	}
	return await _send(ServiceOperation.GET_GLOBAL_LEADERBOARD_PAGE, data)

## Returns a view of the global leaderboard centered on the current player.
##
## Service Name - SocialLeaderboard[br]
## Service Operation - GetGlobalLeaderboardView
##
## @param leaderboard_id The id of the leaderboard to retrieve
## @param sort Sort order ("HIGH_TO_LOW" or "LOW_TO_HIGH")
## @param before_count The number of entries above the current player to return
## @param after_count The number of entries below the current player to return
func get_global_leaderboard_view(leaderboard_id: String, sort: String, before_count: int, after_count: int) -> Dictionary:
	var data := {
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_LEADERBOARD_ID: leaderboard_id,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_SORT: sort,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_BEFORE_COUNT: before_count,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_AFTER_COUNT: after_count
	}
	return await _send(ServiceOperation.GET_GLOBAL_LEADERBOARD_VIEW, data)

## Returns a view of the global leaderboard at a specific version, centered on the current player.
##
## Service Name - SocialLeaderboard[br]
## Service Operation - GetGlobalLeaderboardView
##
## @param leaderboard_id The id of the leaderboard to retrieve
## @param sort Sort order ("HIGH_TO_LOW" or "LOW_TO_HIGH")
## @param before_count The number of entries above the current player to return
## @param after_count The number of entries below the current player to return
## @param version_id The version of the leaderboard to retrieve
func get_global_leaderboard_view_by_version(leaderboard_id: String, sort: String, before_count: int, after_count: int, version_id: int) -> Dictionary:
	var data := {
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_LEADERBOARD_ID: leaderboard_id,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_SORT: sort,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_BEFORE_COUNT: before_count,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_AFTER_COUNT: after_count,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_VERSION_ID: version_id
	}
	return await _send(ServiceOperation.GET_GLOBAL_LEADERBOARD_VIEW, data)

## Returns the total number of entries in a global leaderboard.
##
## Service Name - SocialLeaderboard[br]
## Service Operation - GetGlobalLeaderboardEntryCount
##
## @param leaderboard_id The id of the leaderboard
func get_global_leaderboard_entry_count(leaderboard_id: String) -> Dictionary:
	var data := {
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_LEADERBOARD_ID: leaderboard_id
	}
	return await _send(ServiceOperation.GET_GLOBAL_LEADERBOARD_ENTRY_COUNT, data)

## Returns the total number of entries in a global leaderboard at a specific version.
##
## Service Name - SocialLeaderboard[br]
## Service Operation - GetGlobalLeaderboardEntryCount
##
## @param leaderboard_id The id of the leaderboard
## @param version_id The version of the leaderboard
func get_global_leaderboard_entry_count_by_version(leaderboard_id: String, version_id: int) -> Dictionary:
	var data := {
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_LEADERBOARD_ID: leaderboard_id,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_VERSION_ID: version_id
	}
	return await _send(ServiceOperation.GET_GLOBAL_LEADERBOARD_ENTRY_COUNT, data)

## Returns the versions available for a global leaderboard.
##
## Service Name - SocialLeaderboard[br]
## Service Operation - GetGlobalLeaderboardVersions
##
## @param leaderboard_id The id of the leaderboard
func get_global_leaderboard_versions(leaderboard_id: String) -> Dictionary:
	var data := {
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_LEADERBOARD_ID: leaderboard_id
	}
	return await _send(ServiceOperation.GET_GLOBAL_LEADERBOARD_VERSIONS, data)

## Posts a score to the specified leaderboard.
##
## Service Name - SocialLeaderboard[br]
## Service Operation - PostScore
##
## @param leaderboard_id The id of the leaderboard to post the score to
## @param score The score to post
## @param json_other_data Optional extra data to post with the score
func post_score_to_leaderboard(leaderboard_id: String, score: int, json_other_data: Dictionary) -> Dictionary:
	var data := {
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_LEADERBOARD_ID: leaderboard_id,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_BEST_SCORE: score,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_DATA: json_other_data
	}
	return await _send(ServiceOperation.POST_SCORE, data)

## Posts a score to a dynamic leaderboard, creating it if it does not exist.
##
## Service Name - SocialLeaderboard[br]
## Service Operation - PostScoreToDynamicLeaderboard
##
## @param leaderboard_id The id of the leaderboard to post the score to
## @param score The score to post
## @param json_other_data Optional extra data to post with the score
## @param leaderboard_type The type of leaderboard (e.g. "LAST_VALUE", "HIGH_VALUE")
## @param rotation_type The rotation type (e.g. "NEVER", "DAILY", "WEEKLY")
## @param rotation_reset The UTC time of the next rotation reset (ms since epoch)
## @param retain_count The number of previous versions to retain
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

## Posts a score to a dynamic leaderboard using a UTC rotation reset time.
##
## Service Name - SocialLeaderboard[br]
## Service Operation - PostScoreToDynamicLeaderboardUtc
##
## @param leaderboard_id The id of the leaderboard to post the score to
## @param score The score to post
## @param json_other_data Optional extra data to post with the score
## @param leaderboard_type The type of leaderboard
## @param rotation_type The rotation type
## @param rotation_reset_utc The UTC time of the next rotation reset (ms since epoch)
## @param retain_count The number of previous versions to retain
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

## Removes the current player's score from the specified leaderboard.
##
## Service Name - SocialLeaderboard[br]
## Service Operation - RemovePlayerScore
##
## @param leaderboard_id The id of the leaderboard
## @param version_id The version of the leaderboard (-1 for current version)
func remove_player_score(leaderboard_id: String, version_id: int) -> Dictionary:
	var data := {
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_LEADERBOARD_ID: leaderboard_id,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_VERSION_ID: version_id
	}
	return await _send(ServiceOperation.REMOVE_PLAYER_SCORE, data)

## Returns the current player's score for the specified leaderboard.
##
## Service Name - SocialLeaderboard[br]
## Service Operation - GetPlayerScore
##
## @param leaderboard_id The id of the leaderboard
## @param version_id The version of the leaderboard (-1 for current version)
func get_player_score(leaderboard_id: String, version_id: int) -> Dictionary:
	var data := {
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_LEADERBOARD_ID: leaderboard_id,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_VERSION_ID: version_id
	}
	return await _send(ServiceOperation.GET_PLAYER_SCORE, data)

## Returns the current player's scores from multiple leaderboards.
##
## Service Name - SocialLeaderboard[br]
## Service Operation - GetPlayerScoresFromLeaderboards
##
## @param leaderboard_ids Array of leaderboard ids to retrieve scores from
func get_player_scores_from_leaderboards(leaderboard_ids: Array) -> Dictionary:
	var data := {
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_LEADERBOARD_IDS: leaderboard_ids
	}
	return await _send(ServiceOperation.GET_PLAYER_SCORES_FROM_LEADERBOARDS, data)

## Returns a list of the current player's scores for the specified leaderboard across versions.
##
## Service Name - SocialLeaderboard[br]
## Service Operation - GetPlayerScores
##
## @param leaderboard_id The id of the leaderboard
## @param version_id The version of the leaderboard (-1 for current version)
## @param max_results The maximum number of scores to return
func get_player_scores(leaderboard_id: String, version_id: int, max_results: int) -> Dictionary:
	var data := {
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_LEADERBOARD_ID: leaderboard_id,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_VERSION_ID: version_id,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_NUM_RESULTS_TO_RETURN: max_results
	}
	return await _send(ServiceOperation.GET_PLAYER_SCORES, data)

## Returns a list of all available leaderboards.
##
## Service Name - SocialLeaderboard[br]
## Service Operation - ListAllLeaderboards
func list_all_leaderboards() -> Dictionary:
	return await _send(ServiceOperation.LIST_ALL_LEADERBOARDS, {})

## Returns a page of the group leaderboard for the specified leaderboard.
##
## Service Name - SocialLeaderboard[br]
## Service Operation - GetGroupLeaderboard
##
## @param leaderboard_id The id of the leaderboard to retrieve
## @param group_id The id of the group
func get_group_leaderboard(leaderboard_id: String, group_id: String) -> Dictionary:
	var data := {
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_LEADERBOARD_ID: leaderboard_id,
		OperationParam.GROUP_ID: group_id
	}
	return await _send(ServiceOperation.GET_GROUP_LEADERBOARD, data)

## Returns a view of the group leaderboard centered on the specified group.
##
## Service Name - SocialLeaderboard[br]
## Service Operation - GetGroupLeaderboardView
##
## @param leaderboard_id The id of the leaderboard
## @param group_id The id of the group
## @param sort Sort order ("HIGH_TO_LOW" or "LOW_TO_HIGH")
## @param before_count The number of entries above the group to return
## @param after_count The number of entries below the group to return
func get_group_leaderboard_view(leaderboard_id: String, group_id: String, sort: String, before_count: int, after_count: int) -> Dictionary:
	var data := {
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_LEADERBOARD_ID: leaderboard_id,
		OperationParam.GROUP_ID: group_id,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_SORT: sort,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_BEFORE_COUNT: before_count,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_AFTER_COUNT: after_count
	}
	return await _send(ServiceOperation.GET_GROUP_LEADERBOARD_VIEW, data)

## Posts a score to a dynamic leaderboard using a config object, creating the leaderboard if it does not exist.
##
## Service Name - SocialLeaderboard[br]
## Service Operation - PostScoreToDynamicLeaderboardUsingConfig
##
## @param leaderboard_id The id of the leaderboard to post the score to
## @param score The score to post
## @param score_data Optional extra data to post with the score
## @param config_json Configuration for creating the leaderboard if it does not exist
func post_score_to_leaderboard_using_config(leaderboard_id: String, score: int, score_data: Dictionary, config_json: Dictionary) -> Dictionary:
	var data := {
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_LEADERBOARD_ID: leaderboard_id,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_SCORE: score,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_SCORE_DATA: score_data,
		OperationParam.SOCIAL_LEADERBOARD_SERVICE_CONFIG_JSON: config_json
	}
	return await _send(ServiceOperation.POST_SCORE_TO_DYNAMIC_LEADERBOARD_USING_CONFIG, data)

## Removes a group's score from the specified leaderboard.
##
## Service Name - SocialLeaderboard[br]
## Service Operation - RemoveGroupScore
##
## @param leaderboard_id The id of the leaderboard
## @param group_id The id of the group
## @param score The score to remove
## @param version_id The version of the leaderboard (-1 for current version)
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
