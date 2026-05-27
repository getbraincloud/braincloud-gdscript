# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudFriend
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

## Retrieves profile information for the specified user by credential.
##
## Service Name - Friend[br]
## Service Operation - GetProfileInfoForCredential
##
## @param external_id The user's external ID
## @param auth_type The authentication type of the user ID
func get_profile_info_for_credential(external_id: String, auth_type: String) -> Dictionary:
	var data := {
		OperationParam.FRIEND_SERVICE_EXTERNAL_ID: external_id,
		OperationParam.FRIEND_SERVICE_AUTH_TYPE: auth_type
	}
	return await _send(ServiceOperation.GET_PROFILE_INFO_FOR_CREDENTIAL, data)

## Retrieves profile information for the specified external auth user.
##
## Service Name - Friend[br]
## Service Operation - GetProfileInfoForExternalAuthId
##
## @param external_id External ID of the user to find
## @param external_auth_type The external authentication type used for this user's external ID
func get_profile_info_for_external_auth_id(external_id: String, external_auth_type: String) -> Dictionary:
	var data := {
		OperationParam.FRIEND_SERVICE_EXTERNAL_ID: external_id,
		"externalAuthType": external_auth_type
	}
	return await _send(ServiceOperation.GET_PROFILE_INFO_FOR_EXTERNAL_AUTH_ID, data)

## Retrieves the external ID for the specified user profile ID on the specified social platform.
##
## Service Name - Friend[br]
## Service Operation - GetExternalIdForProfileId
##
## @param profile_id The profile (user) ID
## @param auth_type The associated authentication type
func get_external_id_for_profile_id(profile_id: String, auth_type: String) -> Dictionary:
	var data := {
		OperationParam.FRIEND_SERVICE_PROFILE_ID: profile_id,
		OperationParam.FRIEND_SERVICE_AUTH_TYPE: auth_type
	}
	return await _send(ServiceOperation.GET_EXTERNAL_ID_FOR_PROFILE_ID, data)

## Returns a particular entity of a particular friend.
##
## Service Name - Friend[br]
## Service Operation - ReadFriendEntity
##
## @param entity_id Id of entity to retrieve
## @param friend_id Profile Id of friend who owns the entity
func read_friend_entity(entity_id: String, friend_id: String) -> Dictionary:
	var data := {
		OperationParam.FRIEND_SERVICE_ENTITY_ID: entity_id,
		OperationParam.FRIEND_SERVICE_FRIEND_ID: friend_id
	}
	return await _send(ServiceOperation.READ_FRIEND_ENTITY, data)

## Returns entities of all friends, optionally filtered by type.
##
## Service Name - Friend[br]
## Service Operation - ReadFriendsEntities
##
## @param entity_type Types of entities to retrieve
func read_friends_entities(entity_type: String) -> Dictionary:
	var data := {
		OperationParam.FRIEND_SERVICE_ENTITY_TYPE: entity_type
	}
	return await _send(ServiceOperation.READ_FRIENDS_ENTITIES, data)

## Returns the online status of a list of users.
##
## Service Name - Friend[br]
## Service Operation - GetUsersOnlineStatus
##
## @param profile_ids Collection of profile IDs to check
func get_users_online_status(profile_ids: Array) -> Dictionary:
	var data := {
		OperationParam.FRIEND_SERVICE_PROFILE_IDS: profile_ids
	}
	return await _send(ServiceOperation.GET_USERS_ONLINE_STATUS, data)

## Retrieves a list of user and friend platform information for all friends of the current user.
##
## Service Name - Friend[br]
## Service Operation - ListFriends
##
## @param friend_platform Friend platform to query
## @param include_summary_data Whether to include summary data in the results
func list_friends(friend_platform: String, include_summary_data: bool) -> Dictionary:
	var data := {
		OperationParam.FRIEND_SERVICE_FRIEND_PLATFORM: friend_platform,
		OperationParam.FRIEND_SERVICE_INCLUDE_SUMMARY_DATA: include_summary_data
	}
	return await _send(ServiceOperation.LIST_FRIENDS, data)

## Links profiles for the specified external IDs for the given friend platform as internal friends.
##
## Service Name - Friend[br]
## Service Operation - AddFriendsFromPlatform
##
## @param friend_platform Platform to add from (e.g., FriendPlatform.Facebook)
## @param mode ADD or SYNC
## @param external_ids Collection of external IDs from the friend platform
func add_friends_from_platform(friend_platform: String, mode: String, external_ids: Array) -> Dictionary:
	var data := {
		OperationParam.FRIEND_SERVICE_FRIEND_PLATFORM: friend_platform,
		"mode": mode,
		OperationParam.FRIEND_SERVICE_EXTERNAL_ID_ARRAY: external_ids
	}
	return await _send(ServiceOperation.ADD_FRIENDS_FROM_PLATFORM, data)

## Unlinks the current user and the specified users as brainCloud friends.
##
## Service Name - Friend[br]
## Service Operation - RemoveFriends
##
## @param profile_ids Collection of profile IDs to remove as friends
func remove_friends(profile_ids: Array) -> Dictionary:
	var data := {
		OperationParam.FRIEND_SERVICE_PROFILE_IDS: profile_ids
	}
	return await _send(ServiceOperation.REMOVE_FRIENDS, data)

## Links the current user and the specified users as brainCloud friends.
##
## Service Name - Friend[br]
## Service Operation - AddFriends
##
## @param profile_ids Collection of profile IDs to add as friends
func add_friends(profile_ids: Array) -> Dictionary:
	var data := {
		OperationParam.FRIEND_SERVICE_PROFILE_IDS: profile_ids
	}
	return await _send(ServiceOperation.ADD_FRIENDS, data)

## Retrieves profile information for the user matching the specified Universal ID exactly.
##
## Service Name - Friend[br]
## Service Operation - FindUserByExactUniversalId
##
## @param search_text The Universal ID text to search for
func find_user_by_exact_universal_id(search_text: String) -> Dictionary:
	var data := {
		OperationParam.FRIEND_SERVICE_USER_NAME: search_text
	}
	return await _send(ServiceOperation.FIND_USER_BY_EXACT_UNIVERSAL_ID, data)

## Finds a list of users matching the search text by performing an exact name match.
##
## Service Name - Friend[br]
## Service Operation - FindUsersByExactName
##
## @param search_text The string to search for
## @param max_results Maximum number of results to return
func find_users_by_exact_name(search_text: String, max_results: int = 10) -> Dictionary:
	var data := {
		OperationParam.FRIEND_SERVICE_USER_NAME: search_text,
		OperationParam.FRIEND_SERVICE_MAX_RESULTS: max_results
	}
	return await _send(ServiceOperation.FIND_USERS_BY_EXACT_NAME, data)

## Finds a list of users matching the search text by performing a substring search of all user names.
##
## Service Name - Friend[br]
## Service Operation - FindUsersBySubstrName
##
## @param search_text The substring to search for (minimum 3 characters)
## @param max_results Maximum number of results to return
func find_users_by_substr_name(search_text: String, max_results: int) -> Dictionary:
	var data := {
		OperationParam.FRIEND_SERVICE_USER_NAME: search_text,
		OperationParam.FRIEND_SERVICE_MAX_RESULTS: max_results
	}
	return await _send(ServiceOperation.FIND_USERS_BY_SUBSTR_NAME, data)

## Retrieves profile information for users whose names start with the search text.
##
## Service Name - Friend[br]
## Service Operation - FindUsersByNameStartingWith
##
## @param search_text Name text on which to search
## @param max_results Maximum number of results to return
func find_user_by_name_starting_with(search_text: String, max_results: int) -> Dictionary:
	var data := {
		OperationParam.FRIEND_SERVICE_USER_NAME: search_text,
		OperationParam.FRIEND_SERVICE_MAX_RESULTS: max_results
	}
	return await _send(ServiceOperation.FIND_USERS_BY_NAME_STARTING_WITH, data)

## Retrieves profile information for users whose Universal IDs start with the search text.
##
## Service Name - Friend[br]
## Service Operation - FindUsersByUniversalIdStartingWith
##
## @param search_text Universal ID text on which to search
## @param max_results Maximum number of results to return
func find_users_by_universal_id_starting_with(search_text: String, max_results: int) -> Dictionary:
	var data := {
		OperationParam.FRIEND_SERVICE_USER_NAME: search_text,
		OperationParam.FRIEND_SERVICE_MAX_RESULTS: max_results
	}
	return await _send(ServiceOperation.FIND_USERS_BY_UNIVERSAL_ID_STARTING_WITH, data)

## Returns user state of a particular user.
##
## Service Name - Friend[br]
## Service Operation - GetSummaryDataForProfileId
##
## @param profile_id Profile Id of the user to retrieve summary data for
func get_summary_data_for_profile_id(profile_id: String) -> Dictionary:
	var data := {
		OperationParam.FRIEND_SERVICE_PROFILE_ID: profile_id
	}
	return await _send(ServiceOperation.GET_SUMMARY_DATA_FOR_PROFILE_ID, data)

## Retrieves the current player's social info from the specified friend platform.
##
## Service Name - Friend[br]
## Service Operation - GetMySocialInfo
##
## @param friend_platform Friend platform to query
## @param include_summary_data Whether to include summary data in the results
func get_my_social_info(friend_platform: String, include_summary_data: bool) -> Dictionary:
	var data := {
		OperationParam.FRIEND_SERVICE_FRIEND_PLATFORM: friend_platform,
		OperationParam.FRIEND_SERVICE_INCLUDE_SUMMARY_DATA: include_summary_data
	}
	return await _send(ServiceOperation.GET_MY_SOCIAL_INFO, data)

## Reads a friend's user state. If you are not friends with this user, you will get a NOT_FRIENDS error.
##
## Service Name - Friend[br]
## Service Operation - ReadFriendsPlayerState
##
## @param friend_id Target friend's profile ID
func read_friend_user_state(friend_id: String) -> Dictionary:
	var data := {"friendId": friend_id}
	return await _send(ServiceOperation.READ_FRIEND_PLAYER_STATE, data)

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.FRIEND, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
