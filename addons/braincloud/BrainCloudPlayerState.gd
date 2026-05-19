# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudPlayerState
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

func read_player_state() -> Dictionary:
	return await _send(ServiceOperation.READ, {})

func delete_player() -> Dictionary:
	return await _send(ServiceOperation.FULL_RESET, {})

func reset_player_state() -> Dictionary:
	return await _send(ServiceOperation.DATA_RESET, {})

func logout() -> Dictionary:
	return await _send(ServiceOperation.LOGOUT, {})

func update_name(player_name: String) -> Dictionary:
	return await _send(ServiceOperation.UPDATE_NAME, {OperationParam.PLAYER_STATE_SERVICE_UPDATE_NAME: player_name})

func update_player_name(player_name: String) -> Dictionary:
	return await update_name(player_name)

func update_summary(json_summary_data: Dictionary) -> Dictionary:
	return await _send(ServiceOperation.UPDATE_SUMMARY, {OperationParam.PLAYER_STATE_SERVICE_SUMMARY: json_summary_data})

func update_summary_friend_data(json_summary_data: Dictionary) -> Dictionary:
	return await update_summary(json_summary_data)

func update_picture_url(picture_url: String) -> Dictionary:
	return await _send(ServiceOperation.UPDATE_PICTURE_URL, {OperationParam.PLAYER_STATE_SERVICE_PICTURE_URL: picture_url})

func update_contact_email(contact_email: String) -> Dictionary:
	return await _send(ServiceOperation.UPDATE_CONTACT_EMAIL, {OperationParam.PLAYER_STATE_SERVICE_CONTACT_EMAIL: contact_email})

func update_user_name(user_name: String) -> Dictionary:
	return await _send(ServiceOperation.UPDATE_USER_NAME, {OperationParam.PLAYER_STATE_SERVICE_NEW_NAME: user_name})

func update_attributes(json_attributes: Dictionary, wipe_existing: bool) -> Dictionary:
	var data := {
		OperationParam.PLAYER_STATE_SERVICE_ATTRIBUTES: json_attributes,
		OperationParam.PLAYER_STATE_SERVICE_WIPE_EXISTING: wipe_existing
	}
	return await _send(ServiceOperation.UPDATE_ATTRIBUTES, data)

func remove_attributes(attribute_names: Array) -> Dictionary:
	return await _send(ServiceOperation.REMOVE_ATTRIBUTES, {"attributes": attribute_names})

func get_attributes() -> Dictionary:
	return await _send(ServiceOperation.READ_STATISTICS, {})

func update_language_code(language_code: String) -> Dictionary:
	return await _send(ServiceOperation.UPDATE_LANGUAGE_CODE, {OperationParam.PLAYER_STATE_SERVICE_LANGUAGE_CODE: language_code})

func update_timezone_offset(timezone_offset: float) -> Dictionary:
	return await _send(ServiceOperation.UPDATE_TIMEZONE_OFFSET, {OperationParam.PLAYER_STATE_SERVICE_TIMEZONE_OFFSET: timezone_offset})

func reset_user() -> Dictionary:
	return await _send(ServiceOperation.DATA_RESET, {})

func delete_user() -> Dictionary:
	return await _send(ServiceOperation.FULL_RESET, {})

func set_user_status(status_name: String, duration_secs: int, details: Dictionary) -> Dictionary:
	var req := {
		OperationParam.PLAYER_STATE_SERVICE_STATUS_NAME: status_name,
		OperationParam.PLAYER_STATE_SERVICE_DURATION_SECS: duration_secs,
		OperationParam.PLAYER_STATE_SERVICE_DETAILS: details
	}
	return await _send(ServiceOperation.SET_USER_STATUS, req)

func get_user_status(status_name: String) -> Dictionary:
	return await _send(ServiceOperation.GET_USER_STATUS, {OperationParam.PLAYER_STATE_SERVICE_STATUS_NAME: status_name})

func clear_user_status(status_name: String) -> Dictionary:
	return await _send(ServiceOperation.CLEAR_USER_STATUS, {OperationParam.PLAYER_STATE_SERVICE_STATUS_NAME: status_name})

func extend_user_status(status_name: String, additional_secs: int, details: Dictionary) -> Dictionary:
	var req := {
		OperationParam.PLAYER_STATE_SERVICE_STATUS_NAME: status_name,
		OperationParam.PLAYER_STATE_SERVICE_ADDITIONAL_SECS: additional_secs,
		OperationParam.PLAYER_STATE_SERVICE_DETAILS: details
	}
	return await _send(ServiceOperation.EXTEND_USER_STATUS, req)

func update_status(status_name: String, duration_secs: int, data: Dictionary) -> Dictionary:
	return await set_user_status(status_name, duration_secs, data)

func set_experience_points(xp_value: int) -> Dictionary:
	return await _send(ServiceOperation.SET_EXPERIENCE_POINTS, {"xpPoints": xp_value})

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.PLAYER_STATE, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
