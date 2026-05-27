# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudPresence
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

## Initializes the user's presence for the given platform.
##
## Service Name - Presence[br]
## Service Operation - INITIALIZE_PRESENCE
##
## @param platform The platform identifier (e.g. "all", "brainCloud", "facebook")
## @param include_offline Whether to include offline profiles
func initialize_presence(platform: String, include_offline: bool) -> Dictionary:
	var data := {
		OperationParam.PRESENCE_PLATFORM: platform,
		OperationParam.PRESENCE_INCLUDE_OFFLINE: include_offline
	}
	return await _send(ServiceOperation.PRESENCE_INITIALIZE, data)

## Stops the caller from receiving RTT presence updates.
## Does not affect the broadcasting of their own presence updates to other listeners.
##
## Service Name - Presence[br]
## Service Operation - StopListening
func stop_listening() -> Dictionary:
	return await _send(ServiceOperation.PRESENCE_STOP_LISTENING, {})

## Registers the caller for RTT presence updates from the members of the given group.
## If bidirectional is true, also registers the group members for updates from the caller.
##
## Service Name - Presence[br]
## Service Operation - RegisterListenersForGroup
##
## @param group_id The group id to register for presence updates
## @param bidirectional Whether to also register targets for updates from the caller
func register_listeners_for_group(group_id: String, bidirectional: bool) -> Dictionary:
	var data := {
		OperationParam.PRESENCE_GROUP_ID: group_id,
		OperationParam.PRESENCE_BIDIRECTIONAL: bidirectional
	}
	return await _send(ServiceOperation.PRESENCE_REGISTER_LISTENERS_FOR_GROUP, data)

## Gets the presence data for the given platform.
## Can be one of "all", "brainCloud", or "facebook".
##
## Service Name - Presence[br]
## Service Operation - GetPresenceOfFriends
##
## @param platform The platform identifier
## @param include_offline Whether to include offline profiles
func get_presence_of_friends(platform: String, include_offline: bool) -> Dictionary:
	var data := {
		OperationParam.PRESENCE_PLATFORM: platform,
		OperationParam.PRESENCE_INCLUDE_OFFLINE: include_offline
	}
	return await _send(ServiceOperation.PRESENCE_GET_PRESENCE_OF_FRIENDS, data)

## Gets the presence data for the given group.
##
## Service Name - Presence[br]
## Service Operation - GetPresenceOfGroup
##
## @param platform The platform identifier
## @param group_id The group id to get presence data for
func get_presence_of_group(platform: String, group_id: String) -> Dictionary:
	var data := {
		OperationParam.PRESENCE_PLATFORM: platform,
		OperationParam.PRESENCE_GROUP_ID: group_id
	}
	return await _send(ServiceOperation.PRESENCE_GET_PRESENCE_OF_GROUP, data)

## Gets the presence data for the given profile ids.
##
## Service Name - Presence[br]
## Service Operation - GetPresenceOfUsers
##
## @param profile_ids Array of profile ids to get presence data for
## @param bidirectional Whether to also register the users for updates from the caller
func get_presence_of_users(profile_ids: Array, bidirectional: bool) -> Dictionary:
	var data := {
		OperationParam.PRESENCE_PROFILE_IDS: profile_ids,
		OperationParam.PRESENCE_BIDIRECTIONAL: bidirectional
	}
	return await _send(ServiceOperation.PRESENCE_GET_PRESENCE_OF_USERS, data)

## Updates the presence data activity field for the caller.
##
## Service Name - Presence[br]
## Service Operation - UpdateActivity
##
## @param activity The activity data as a Dictionary
func update_activity(activity: Dictionary) -> Dictionary:
	var data := {
		OperationParam.PRESENCE_ACTIVITY: activity
	}
	return await _send(ServiceOperation.PRESENCE_UPDATE_ACTIVITY, data)

## Updates the presence data visible field for the caller.
##
## Service Name - Presence[br]
## Service Operation - SetVisibility
##
## @param visible Whether the user's presence is visible to others
func force_presence(visible: bool) -> Dictionary:
	var data := {
		OperationParam.PRESENCE_VISIBLE: visible
	}
	return await _send(ServiceOperation.PRESENCE_FORCE_PRESENCE, data)

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.PRESENCE, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
