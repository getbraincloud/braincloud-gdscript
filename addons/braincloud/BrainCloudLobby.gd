# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudLobby
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

func find_or_create_lobby(lobby_type: String, rating: int, max_steps: int, algo: Dictionary, filter_json: Dictionary, is_ready: bool, extra_json: Dictionary, team_code: String, other_user_cx_ids: Array) -> Dictionary:
	var data := {
		OperationParam.LOBBY_TYPE: lobby_type,
		OperationParam.LOBBY_RATING: rating,
		"maxSteps": max_steps,
		OperationParam.LOBBY_ALGO: algo,
		OperationParam.LOBBY_FILTER_JSON: filter_json,
		OperationParam.LOBBY_IS_READY: is_ready,
		OperationParam.LOBBY_EXTRA_JSON: extra_json,
		OperationParam.LOBBY_TEAM: team_code,
		OperationParam.LOBBY_OTHER_USER_CX_IDS: other_user_cx_ids
	}
	return await _send(ServiceOperation.LOBBY_FIND_OR_CREATE, data)

func find_or_create_lobby_with_ping_data(lobby_type: String, rating: int, max_steps: int, algo: Dictionary, filter_json: Dictionary, is_ready: bool, extra_json: Dictionary, team_code: String, other_user_cx_ids: Array) -> Dictionary:
	var data := {
		OperationParam.LOBBY_TYPE: lobby_type,
		OperationParam.LOBBY_RATING: rating,
		"maxSteps": max_steps,
		OperationParam.LOBBY_ALGO: algo,
		OperationParam.LOBBY_FILTER_JSON: filter_json,
		OperationParam.LOBBY_IS_READY: is_ready,
		OperationParam.LOBBY_EXTRA_JSON: extra_json,
		OperationParam.LOBBY_TEAM: team_code,
		OperationParam.LOBBY_OTHER_USER_CX_IDS: other_user_cx_ids,
		OperationParam.LOBBY_PING_DATA: {}
	}
	return await _send(ServiceOperation.LOBBY_FIND_OR_CREATE, data)

func cancel_find_request(lobby_type: String, connection_id: String) -> Dictionary:
	var data := {
		OperationParam.LOBBY_TYPE: lobby_type,
		"connectionId": connection_id
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
		OperationParam.LOBBY_TEAM: to_team_code
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

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.LOBBY, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
