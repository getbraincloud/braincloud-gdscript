# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudGamification
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

func read_all_gamification(include_meta_data: bool) -> Dictionary:
	var data := {
		OperationParam.GAMIFICATION_SERVICE_INCLUDE_META_DATA: include_meta_data
	}
	return await _send(ServiceOperation.READ, data)

func read_milestones(include_meta_data: bool) -> Dictionary:
	var data := {
		OperationParam.GAMIFICATION_SERVICE_INCLUDE_META_DATA: include_meta_data
	}
	return await _send(ServiceOperation.READ_MILESTONES, data)

func read_achievements(include_meta_data: bool) -> Dictionary:
	var data := {
		OperationParam.GAMIFICATION_SERVICE_INCLUDE_META_DATA: include_meta_data
	}
	return await _send(ServiceOperation.READ_ACHIEVEMENTS, data)

func read_xp_levels_meta_data() -> Dictionary:
	return await _send(ServiceOperation.READ_XP_LEVELS, {})

func read_achieved_achievements(include_meta_data: bool) -> Dictionary:
	var data := {
		OperationParam.GAMIFICATION_SERVICE_INCLUDE_META_DATA: include_meta_data
	}
	return await _send(ServiceOperation.READ_ACHIEVED_ACHIEVEMENTS, data)

func read_milestones_by_category(category: String, include_meta_data: bool) -> Dictionary:
	var data := {
		OperationParam.GAMIFICATION_SERVICE_MILESTONES_CATEGORY: category,
		OperationParam.GAMIFICATION_SERVICE_INCLUDE_META_DATA: include_meta_data
	}
	return await _send(ServiceOperation.READ_MILESTONES_BY_CATEGORY, data)

func award_achievements(achievement_ids: Array) -> Dictionary:
	var data := {
		OperationParam.GAMIFICATION_SERVICE_ACHIEVEMENTS_NAME: achievement_ids
	}
	return await _send(ServiceOperation.AWARD_ACHIEVEMENTS, data)

func read_completed_quests(include_meta_data: bool) -> Dictionary:
	var data := {
		OperationParam.GAMIFICATION_SERVICE_INCLUDE_META_DATA: include_meta_data
	}
	return await _send(ServiceOperation.READ_COMPLETED_QUESTS, data)

func read_in_progress_quests(include_meta_data: bool) -> Dictionary:
	var data := {
		OperationParam.GAMIFICATION_SERVICE_INCLUDE_META_DATA: include_meta_data
	}
	return await _send(ServiceOperation.READ_IN_PROGRESS_QUESTS, data)

func read_quests_by_status(quest_status: String, include_meta_data: bool) -> Dictionary:
	var data := {
		"questStatus": quest_status,
		OperationParam.GAMIFICATION_SERVICE_INCLUDE_META_DATA: include_meta_data
	}
	return await _send(ServiceOperation.READ_QUESTS_WITH_STATUS, data)

func read_quests_by_category(category: String, include_meta_data: bool) -> Dictionary:
	var data := {
		OperationParam.GAMIFICATION_SERVICE_QUESTS_CATEGORY: category,
		OperationParam.GAMIFICATION_SERVICE_INCLUDE_META_DATA: include_meta_data
	}
	return await _send(ServiceOperation.READ_QUESTS_BY_CATEGORY, data)

func read_quests_with_status(include_meta_data: bool) -> Dictionary:
	var data := {
		OperationParam.GAMIFICATION_SERVICE_INCLUDE_META_DATA: include_meta_data
	}
	return await _send(ServiceOperation.READ_QUESTS, data)

func reset_milestones(milestone_ids: Array) -> Dictionary:
	var data := {
		"milestoneIds": milestone_ids
	}
	return await _send(ServiceOperation.RESET_MILESTONES, data)

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.GAMIFICATION, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
