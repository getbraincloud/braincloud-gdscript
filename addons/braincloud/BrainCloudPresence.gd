# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudPresence
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

func initialize_presence(platform: String, include_offline: bool) -> Dictionary:
	var data := {
		OperationParam.PRESENCE_PLATFORM: platform,
		OperationParam.PRESENCE_INCLUDE_OFFLINE: include_offline
	}
	return await _send(ServiceOperation.PRESENCE_INITIALIZE, data)

func stop_listening() -> Dictionary:
	return await _send(ServiceOperation.PRESENCE_STOP_LISTENING, {})

func register_listeners_for_group(group_id: String, bidirectional: bool) -> Dictionary:
	var data := {
		OperationParam.PRESENCE_GROUP_ID: group_id,
		OperationParam.PRESENCE_BIDIRECTIONAL: bidirectional
	}
	return await _send(ServiceOperation.PRESENCE_REGISTER_LISTENERS_FOR_GROUP, data)

func get_presence_of_friends(platform: String, include_offline: bool) -> Dictionary:
	var data := {
		OperationParam.PRESENCE_PLATFORM: platform,
		OperationParam.PRESENCE_INCLUDE_OFFLINE: include_offline
	}
	return await _send(ServiceOperation.PRESENCE_GET_PRESENCE_OF_FRIENDS, data)

func get_presence_of_group(platform: String, group_id: String) -> Dictionary:
	var data := {
		OperationParam.PRESENCE_PLATFORM: platform,
		OperationParam.PRESENCE_GROUP_ID: group_id
	}
	return await _send(ServiceOperation.PRESENCE_GET_PRESENCE_OF_GROUP, data)

func get_presence_of_users(profile_ids: Array, bidirectional: bool) -> Dictionary:
	var data := {
		OperationParam.PRESENCE_PROFILE_IDS: profile_ids,
		OperationParam.PRESENCE_BIDIRECTIONAL: bidirectional
	}
	return await _send(ServiceOperation.PRESENCE_GET_PRESENCE_OF_USERS, data)

func update_activity(activity: Dictionary) -> Dictionary:
	var data := {
		OperationParam.PRESENCE_ACTIVITY: activity
	}
	return await _send(ServiceOperation.PRESENCE_UPDATE_ACTIVITY, data)

func force_presence(visible: bool) -> Dictionary:
	var data := {
		OperationParam.PRESENCE_VISIBLE: visible
	}
	return await _send(ServiceOperation.PRESENCE_FORCE_PRESENCE, data)

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.PRESENCE, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
