# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudGamification
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

## Retrieves all gamification data for the player.
##
## Service Name - Gamification[br]
## Service Operation - Read
##
## @param include_meta_data Whether to include meta data in the response
func read_all_gamification(include_meta_data: bool) -> Dictionary:
	var data := {
		OperationParam.GAMIFICATION_SERVICE_INCLUDE_META_DATA: include_meta_data
	}
	return await _send(ServiceOperation.READ, data)

## Retrieves all milestones defined for the game.
##
## Service Name - Gamification[br]
## Service Operation - ReadMilestones
##
## @param include_meta_data Whether to include meta data in the response
func read_milestones(include_meta_data: bool) -> Dictionary:
	var data := {
		OperationParam.GAMIFICATION_SERVICE_INCLUDE_META_DATA: include_meta_data
	}
	return await _send(ServiceOperation.READ_MILESTONES, data)

## Reads all of the achievements defined for the game.
##
## Service Name - Gamification[br]
## Service Operation - ReadAchievements
##
## @param include_meta_data Whether to include meta data in the response
func read_achievements(include_meta_data: bool) -> Dictionary:
	var data := {
		OperationParam.GAMIFICATION_SERVICE_INCLUDE_META_DATA: include_meta_data
	}
	return await _send(ServiceOperation.READ_ACHIEVEMENTS, data)

## Returns all defined XP levels and any rewards associated with those levels.
##
## Service Name - Gamification[br]
## Service Operation - ReadXpLevels
func read_xp_levels_meta_data() -> Dictionary:
	return await _send(ServiceOperation.READ_XP_LEVELS, {})

## Retrieves the list of achieved achievements.
##
## Service Name - Gamification[br]
## Service Operation - ReadAchievedAchievements
##
## @param include_meta_data Whether to include meta data in the response
func read_achieved_achievements(include_meta_data: bool) -> Dictionary:
	var data := {
		OperationParam.GAMIFICATION_SERVICE_INCLUDE_META_DATA: include_meta_data
	}
	return await _send(ServiceOperation.READ_ACHIEVED_ACHIEVEMENTS, data)

## Retrieves milestones of the given category.
##
## Service Name - Gamification[br]
## Service Operation - ReadMilestonesByCategory
##
## @param category The milestone category
## @param include_meta_data Whether to include meta data in the response
func read_milestones_by_category(category: String, include_meta_data: bool) -> Dictionary:
	var data := {
		OperationParam.GAMIFICATION_SERVICE_MILESTONES_CATEGORY: category,
		OperationParam.GAMIFICATION_SERVICE_INCLUDE_META_DATA: include_meta_data
	}
	return await _send(ServiceOperation.READ_MILESTONES_BY_CATEGORY, data)

## Awards the achievements specified.
##
## Service Name - Gamification[br]
## Service Operation - AwardAchievements
##
## @param achievement_ids Collection of achievement ids to award
func award_achievements(achievement_ids: Array) -> Dictionary:
	var data := {
		OperationParam.GAMIFICATION_SERVICE_ACHIEVEMENTS_NAME: achievement_ids
	}
	return await _send(ServiceOperation.AWARD_ACHIEVEMENTS, data)

## Returns all completed quests.
##
## Service Name - Gamification[br]
## Service Operation - ReadCompletedQuests
##
## @param include_meta_data Whether to include meta data in the response
func read_completed_quests(include_meta_data: bool) -> Dictionary:
	var data := {
		OperationParam.GAMIFICATION_SERVICE_INCLUDE_META_DATA: include_meta_data
	}
	return await _send(ServiceOperation.READ_COMPLETED_QUESTS, data)

## Returns quests that are currently in progress.
##
## Service Name - Gamification[br]
## Service Operation - ReadInProgressQuests
##
## @param include_meta_data Whether to include meta data in the response
func read_in_progress_quests(include_meta_data: bool) -> Dictionary:
	var data := {
		OperationParam.GAMIFICATION_SERVICE_INCLUDE_META_DATA: include_meta_data
	}
	return await _send(ServiceOperation.READ_IN_PROGRESS_QUESTS, data)

## Returns quests filtered by the given status.
##
## Service Name - Gamification[br]
## Service Operation - ReadQuestsWithStatus
##
## @param quest_status The quest status to filter by
## @param include_meta_data Whether to include meta data in the response
func read_quests_by_status(quest_status: String, include_meta_data: bool) -> Dictionary:
	var data := {
		"questStatus": quest_status,
		OperationParam.GAMIFICATION_SERVICE_INCLUDE_META_DATA: include_meta_data
	}
	return await _send(ServiceOperation.READ_QUESTS_WITH_STATUS, data)

## Returns quests for the given category.
##
## Service Name - Gamification[br]
## Service Operation - ReadQuestsByCategory
##
## @param category The quest category
## @param include_meta_data Whether to include meta data in the response
func read_quests_by_category(category: String, include_meta_data: bool) -> Dictionary:
	var data := {
		OperationParam.GAMIFICATION_SERVICE_QUESTS_CATEGORY: category,
		OperationParam.GAMIFICATION_SERVICE_INCLUDE_META_DATA: include_meta_data
	}
	return await _send(ServiceOperation.READ_QUESTS_BY_CATEGORY, data)

## Returns all quests with their status.
##
## Service Name - Gamification[br]
## Service Operation - ReadQuests
##
## @param include_meta_data Whether to include meta data in the response
func read_quests_with_status(include_meta_data: bool) -> Dictionary:
	var data := {
		OperationParam.GAMIFICATION_SERVICE_INCLUDE_META_DATA: include_meta_data
	}
	return await _send(ServiceOperation.READ_QUESTS, data)

## Resets the specified milestones back to their initial state.
##
## Service Name - Gamification[br]
## Service Operation - RESET_MILESTONES
##
## @param milestone_ids Collection of milestone ids to reset
func reset_milestones(milestone_ids: Array) -> Dictionary:
	var data := {
		"milestoneIds": milestone_ids
	}
	return await _send(ServiceOperation.RESET_MILESTONES, data)

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.GAMIFICATION, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
