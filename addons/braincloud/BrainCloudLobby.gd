# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudLobby
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

func find_lobby(lobby_type: String, rating: int, max_steps: int, algo: Dictionary, filter_json: Dictionary, is_ready: bool, extra_json: Dictionary, team_code: String, other_user_cx_ids: Array) -> Dictionary:
	var data := {
		OperationParam.LOBBY_TYPE: lobby_type,
		OperationParam.LOBBY_RATING: rating,
		OperationParam.LOBBY_MAX_STEPS: max_steps,
		OperationParam.LOBBY_ALGO: algo,
		OperationParam.LOBBY_FILTER_JSON: filter_json,
		OperationParam.LOBBY_IS_READY: is_ready,
		OperationParam.LOBBY_EXTRA_JSON: extra_json,
		OperationParam.LOBBY_TEAM: team_code,
		OperationParam.LOBBY_OTHER_USER_CX_IDS: other_user_cx_ids
	}
	return await _send(ServiceOperation.LOBBY_FIND, data)

func find_or_create_lobby(lobby_type: String, rating: int, max_steps: int, algo: Dictionary, filter_json: Dictionary, settings: Dictionary, is_ready: bool, extra_json: Dictionary, team_code: String, other_user_cx_ids: Array) -> Dictionary:
	var data := {
		OperationParam.LOBBY_TYPE: lobby_type,
		OperationParam.LOBBY_RATING: rating,
		OperationParam.LOBBY_MAX_STEPS: max_steps,
		OperationParam.LOBBY_ALGO: algo,
		OperationParam.LOBBY_FILTER_JSON: filter_json,
		OperationParam.LOBBY_SETTINGS: settings,
		OperationParam.LOBBY_IS_READY: is_ready,
		OperationParam.LOBBY_EXTRA_JSON: extra_json,
		OperationParam.LOBBY_TEAM: team_code,
		OperationParam.LOBBY_OTHER_USER_CX_IDS: other_user_cx_ids
	}
	return await _send(ServiceOperation.LOBBY_FIND_OR_CREATE, data)

func find_or_create_lobby_with_ping_data(lobby_type: String, rating: int, max_steps: int, algo: Dictionary, filter_json: Dictionary, settings: Dictionary, is_ready: bool, extra_json: Dictionary, team_code: String, other_user_cx_ids: Array) -> Dictionary:
	var data := {
		OperationParam.LOBBY_TYPE: lobby_type,
		OperationParam.LOBBY_RATING: rating,
		OperationParam.LOBBY_MAX_STEPS: max_steps,
		OperationParam.LOBBY_ALGO: algo,
		OperationParam.LOBBY_FILTER_JSON: filter_json,
		OperationParam.LOBBY_SETTINGS: settings,
		OperationParam.LOBBY_IS_READY: is_ready,
		OperationParam.LOBBY_EXTRA_JSON: extra_json,
		OperationParam.LOBBY_TEAM: team_code,
		OperationParam.LOBBY_OTHER_USER_CX_IDS: other_user_cx_ids,
		OperationParam.LOBBY_PING_DATA: {}
	}
	return await _send(ServiceOperation.LOBBY_FIND_OR_CREATE, data)

func create_lobby(lobby_type: String, rating: int, is_ready: bool, extra_json: Dictionary, team_code: String, settings: Dictionary, other_user_cx_ids: Array) -> Dictionary:
	var data := {
		OperationParam.LOBBY_TYPE: lobby_type,
		OperationParam.LOBBY_RATING: rating,
		OperationParam.LOBBY_SETTINGS: settings,
		OperationParam.LOBBY_IS_READY: is_ready,
		OperationParam.LOBBY_EXTRA_JSON: extra_json,
		OperationParam.LOBBY_TEAM: team_code,
		OperationParam.LOBBY_OTHER_USER_CX_IDS: other_user_cx_ids
	}
	return await _send(ServiceOperation.LOBBY_CREATE, data)

func join_lobby(lobby_id: String, is_ready: bool, extra_json: Dictionary, team_code: String, other_user_cx_ids: Array) -> Dictionary:
	var data := {
		OperationParam.LOBBY_ID: lobby_id,
		OperationParam.LOBBY_IS_READY: is_ready,
		OperationParam.LOBBY_EXTRA_JSON: extra_json,
		OperationParam.LOBBY_TEAM: team_code,
		OperationParam.LOBBY_OTHER_USER_CX_IDS: other_user_cx_ids
	}
	return await _send(ServiceOperation.LOBBY_JOIN, data)

func leave_lobby(lobby_id: String) -> Dictionary:
	var data := {
		OperationParam.LOBBY_ID: lobby_id
	}
	return await _send(ServiceOperation.LOBBY_LEAVE, data)

func remove_member(lobby_id: String, connection_id: String) -> Dictionary:
	var data := {
		OperationParam.LOBBY_ID: lobby_id,
		OperationParam.LOBBY_CONNECTION_ID: connection_id
	}
	return await _send(ServiceOperation.LOBBY_REMOVE_MEMBER, data)

func cancel_find_request(lobby_type: String, entry_id: String) -> Dictionary:
	var data := {
		OperationParam.LOBBY_TYPE: lobby_type,
		OperationParam.LOBBY_CONNECTION_ID: "",
		OperationParam.LOBBY_ENTRY_ID: entry_id
	}
	return await _send(ServiceOperation.LOBBY_CANCEL_FIND, data)

func get_lobby_data(lobby_id: String) -> Dictionary:
	var data := {
		OperationParam.LOBBY_ID: lobby_id
	}
	return await _send(ServiceOperation.LOBBY_GET, data)

func destroy_lobby(lobby_id: String) -> Dictionary:
	var data := {
		OperationParam.LOBBY_ID: lobby_id
	}
	return await _send(ServiceOperation.LOBBY_DESTROY, data)

func send_signal(lobby_id: String, signal_data: Dictionary) -> Dictionary:
	var data := {
		OperationParam.LOBBY_ID: lobby_id,
		OperationParam.LOBBY_SIGNAL_DATA: signal_data
	}
	return await _send(ServiceOperation.LOBBY_SEND_SIGNAL, data)

func switch_team(lobby_id: String, to_team_code: String) -> Dictionary:
	var data := {
		OperationParam.LOBBY_ID: lobby_id,
		OperationParam.LOBBY_TO_TEAM_CODE: to_team_code
	}
	return await _send(ServiceOperation.LOBBY_SWITCH_TEAM, data)

func update_ready(lobby_id: String, is_ready: bool, extra_json: Dictionary) -> Dictionary:
	var data := {
		OperationParam.LOBBY_ID: lobby_id,
		OperationParam.LOBBY_IS_READY: is_ready,
		OperationParam.LOBBY_EXTRA_JSON: extra_json
	}
	return await _send(ServiceOperation.LOBBY_UPDATE_READY, data)

func update_settings(lobby_id: String, settings: Dictionary) -> Dictionary:
	var data := {
		OperationParam.LOBBY_ID: lobby_id,
		OperationParam.LOBBY_SETTINGS: settings
	}
	return await _send(ServiceOperation.LOBBY_UPDATE_SETTINGS, data)

func get_regions_for_lobbies(lobby_types: Array) -> Dictionary:
	var data := {
		OperationParam.LOBBY_TYPES: lobby_types
	}
	return await _send(ServiceOperation.LOBBY_GET_REGIONS, data)

func get_lobby_instances(lobby_type: String, criteria_json: Dictionary) -> Dictionary:
	var data := {
		OperationParam.LOBBY_TYPE: lobby_type,
		OperationParam.LOBBY_CRITERIA: criteria_json
	}
	return await _send(ServiceOperation.LOBBY_GET_INSTANCES, data)

func get_lobby_instances_with_ping_data(lobby_type: String, criteria_json: Dictionary) -> Dictionary:
	var data := {
		OperationParam.LOBBY_TYPE: lobby_type,
		OperationParam.LOBBY_CRITERIA: criteria_json,
		OperationParam.LOBBY_PING_DATA: {}
	}
	return await _send(ServiceOperation.LOBBY_GET_INSTANCES_WITH_PING, data)

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.LOBBY, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
