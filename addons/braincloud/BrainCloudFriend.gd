# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudFriend
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

func get_profile_info_for_credential(external_id: String, auth_type: String) -> Dictionary:
	var data := {
		OperationParam.FRIEND_SERVICE_EXTERNAL_ID: external_id,
		OperationParam.FRIEND_SERVICE_AUTH_TYPE: auth_type
	}
	return await _send(ServiceOperation.GET_PROFILE_INFO_FOR_CREDENTIAL, data)

func get_profile_info_for_external_auth_id(external_id: String, external_auth_type: String) -> Dictionary:
	var data := {
		OperationParam.FRIEND_SERVICE_EXTERNAL_ID: external_id,
		"externalAuthType": external_auth_type
	}
	return await _send(ServiceOperation.GET_PROFILE_INFO_FOR_EXTERNAL_AUTH_ID, data)

func get_external_id_for_profile_id(profile_id: String, auth_type: String) -> Dictionary:
	var data := {
		OperationParam.FRIEND_SERVICE_PROFILE_ID: profile_id,
		OperationParam.FRIEND_SERVICE_AUTH_TYPE: auth_type
	}
	return await _send(ServiceOperation.GET_EXTERNAL_ID_FOR_PROFILE_ID, data)

func read_friend_entity(entity_id: String, friend_id: String) -> Dictionary:
	var data := {
		OperationParam.FRIEND_SERVICE_ENTITY_ID: entity_id,
		OperationParam.FRIEND_SERVICE_FRIEND_ID: friend_id
	}
	return await _send(ServiceOperation.READ_FRIEND_ENTITY, data)

func read_friends_entities(entity_type: String) -> Dictionary:
	var data := {
		OperationParam.FRIEND_SERVICE_ENTITY_TYPE: entity_type
	}
	return await _send(ServiceOperation.READ_FRIENDS_ENTITIES, data)

func get_users_online_status(profile_ids: Array) -> Dictionary:
	var data := {
		OperationParam.FRIEND_SERVICE_PROFILE_IDS: profile_ids
	}
	return await _send(ServiceOperation.GET_USERS_ONLINE_STATUS, data)

func list_friends(friend_platform: String, include_summary_data: bool) -> Dictionary:
	var data := {
		OperationParam.FRIEND_SERVICE_FRIEND_PLATFORM: friend_platform,
		OperationParam.FRIEND_SERVICE_INCLUDE_SUMMARY_DATA: include_summary_data
	}
	return await _send(ServiceOperation.LIST_FRIENDS, data)

func add_friends_from_platform(friend_platform: String, mode: String, external_ids: Array) -> Dictionary:
	var data := {
		OperationParam.FRIEND_SERVICE_FRIEND_PLATFORM: friend_platform,
		"mode": mode,
		OperationParam.FRIEND_SERVICE_EXTERNAL_ID_ARRAY: external_ids
	}
	return await _send(ServiceOperation.ADD_FRIENDS_FROM_PLATFORM, data)

func remove_friends(profile_ids: Array) -> Dictionary:
	var data := {
		OperationParam.FRIEND_SERVICE_PROFILE_IDS: profile_ids
	}
	return await _send(ServiceOperation.REMOVE_FRIENDS, data)

func add_friends(profile_ids: Array) -> Dictionary:
	var data := {
		OperationParam.FRIEND_SERVICE_PROFILE_IDS: profile_ids
	}
	return await _send(ServiceOperation.ADD_FRIENDS, data)

func find_user_by_exact_universal_id(search_text: String) -> Dictionary:
	var data := {
		OperationParam.FRIEND_SERVICE_USER_NAME: search_text
	}
	return await _send(ServiceOperation.FIND_USER_BY_EXACT_UNIVERSAL_ID, data)

func find_users_by_exact_name(search_text: String, max_results: int = 10) -> Dictionary:
	var data := {
		OperationParam.FRIEND_SERVICE_USER_NAME: search_text,
		OperationParam.FRIEND_SERVICE_MAX_RESULTS: max_results
	}
	return await _send(ServiceOperation.FIND_USERS_BY_EXACT_NAME, data)

func find_users_by_substr_name(search_text: String, max_results: int) -> Dictionary:
	var data := {
		OperationParam.FRIEND_SERVICE_USER_NAME: search_text,
		OperationParam.FRIEND_SERVICE_MAX_RESULTS: max_results
	}
	return await _send(ServiceOperation.FIND_USERS_BY_SUBSTR_NAME, data)

func find_user_by_name_starting_with(search_text: String, max_results: int) -> Dictionary:
	var data := {
		OperationParam.FRIEND_SERVICE_USER_NAME: search_text,
		OperationParam.FRIEND_SERVICE_MAX_RESULTS: max_results
	}
	return await _send(ServiceOperation.FIND_USERS_BY_NAME_STARTING_WITH, data)

func find_users_by_universal_id_starting_with(search_text: String, max_results: int) -> Dictionary:
	var data := {
		OperationParam.FRIEND_SERVICE_USER_NAME: search_text,
		OperationParam.FRIEND_SERVICE_MAX_RESULTS: max_results
	}
	return await _send(ServiceOperation.FIND_USERS_BY_UNIVERSAL_ID_STARTING_WITH, data)

func get_summary_data_for_profile_id(profile_id: String) -> Dictionary:
	var data := {
		OperationParam.FRIEND_SERVICE_PROFILE_ID: profile_id
	}
	return await _send(ServiceOperation.GET_SUMMARY_DATA_FOR_PROFILE_ID, data)

func get_my_social_info(friend_platform: String, include_summary_data: bool) -> Dictionary:
	var data := {
		OperationParam.FRIEND_SERVICE_FRIEND_PLATFORM: friend_platform,
		OperationParam.FRIEND_SERVICE_INCLUDE_SUMMARY_DATA: include_summary_data
	}
	return await _send(ServiceOperation.GET_MY_SOCIAL_INFO, data)

func read_friend_user_state(friend_id: String) -> Dictionary:
	var data := {"friendId": friend_id}
	return await _send(ServiceOperation.READ_FRIEND_PLAYER_STATE, data)

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.FRIEND, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
