# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudPlayerState
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

## Reads the state of the currently logged in user.
## Returns entities, statistics, level, currency, and more.
## Apps will typically call this method after authenticating.
##
## Service Name - PlayerState[br]
## Service Operation - Read
func read_player_state() -> Dictionary:
	return await _send(ServiceOperation.READ, {})

## Completely deletes the user record and all data fully owned by the user.
## After calling this method, the user will need to re-authenticate.
##
## Service Name - PlayerState[br]
## Service Operation - FullReset
func delete_player() -> Dictionary:
	return await _send(ServiceOperation.FULL_RESET, {})

## Deletes most data for the currently logged in user.
## Data not deleted includes currency, credentials, and purchase transactions.
## The user record continues to exist, so no re-authentication is needed.
##
## Service Name - PlayerState[br]
## Service Operation - DataReset
func reset_player_state() -> Dictionary:
	return await _send(ServiceOperation.DATA_RESET, {})

## Logs the user out of the server.
##
## Service Name - PlayerState[br]
## Service Operation - Logout
func logout() -> Dictionary:
	return await _send(ServiceOperation.LOGOUT, {})

## Sets the user's name.
##
## Service Name - PlayerState[br]
## Service Operation - UPDATE_NAME
##
## @param player_name The name of the user
func update_name(player_name: String) -> Dictionary:
	return await _send(ServiceOperation.UPDATE_NAME, {OperationParam.PLAYER_STATE_SERVICE_UPDATE_NAME: player_name})

## Sets the user's name. Alias for update_name.
##
## Service Name - PlayerState[br]
## Service Operation - UPDATE_NAME
##
## @param player_name The name of the user
func update_player_name(player_name: String) -> Dictionary:
	return await update_name(player_name)

## Updates the "friend summary data" associated with the logged in user.
## This data is returned in social leaderboards and other summary operations.
##
## Service Name - PlayerState[br]
## Service Operation - UpdateSummary
##
## @param json_summary_data A Dictionary defining the summary data
func update_summary(json_summary_data: Dictionary) -> Dictionary:
	return await _send(ServiceOperation.UPDATE_SUMMARY, {OperationParam.PLAYER_STATE_SERVICE_SUMMARY: json_summary_data})

## Updates the friend summary data. Alias for update_summary.
##
## Service Name - PlayerState[br]
## Service Operation - UpdateSummary
##
## @param json_summary_data A Dictionary defining the summary data
func update_summary_friend_data(json_summary_data: Dictionary) -> Dictionary:
	return await update_summary(json_summary_data)

## Updates the user's picture URL.
##
## Service Name - PlayerState[br]
## Service Operation - UPDATE_PICTURE_URL
##
## @param picture_url URL to apply
func update_picture_url(picture_url: String) -> Dictionary:
	return await _send(ServiceOperation.UPDATE_PICTURE_URL, {OperationParam.PLAYER_STATE_SERVICE_PICTURE_URL: picture_url})

## Updates the user's contact email. Note this is unrelated to email authentication.
##
## Service Name - PlayerState[br]
## Service Operation - UPDATE_CONTACT_EMAIL
##
## @param contact_email Updated email address
func update_contact_email(contact_email: String) -> Dictionary:
	return await _send(ServiceOperation.UPDATE_CONTACT_EMAIL, {OperationParam.PLAYER_STATE_SERVICE_CONTACT_EMAIL: contact_email})

## Updates the user's display name.
##
## Service Name - PlayerState[br]
## Service Operation - UPDATE_USER_NAME
##
## @param user_name The new display name
func update_user_name(user_name: String) -> Dictionary:
	return await _send(ServiceOperation.UPDATE_USER_NAME, {OperationParam.PLAYER_STATE_SERVICE_NEW_NAME: user_name})

## Updates the user's attributes.
##
## Service Name - PlayerState[br]
## Service Operation - UpdateAttributes
##
## @param json_attributes Single layer Dictionary of key-value attribute pairs
## @param wipe_existing Whether to wipe existing attributes prior to update
func update_attributes(json_attributes: Dictionary, wipe_existing: bool) -> Dictionary:
	var data := {
		OperationParam.PLAYER_STATE_SERVICE_ATTRIBUTES: json_attributes,
		OperationParam.PLAYER_STATE_SERVICE_WIPE_EXISTING: wipe_existing
	}
	return await _send(ServiceOperation.UPDATE_ATTRIBUTES, data)

## Removes the user's attributes.
##
## Service Name - PlayerState[br]
## Service Operation - RemoveAttributes
##
## @param attribute_names Collection of attribute names to remove
func remove_attributes(attribute_names: Array) -> Dictionary:
	return await _send(ServiceOperation.REMOVE_ATTRIBUTES, {"attributes": attribute_names})

## Retrieves the user's attributes.
##
## Service Name - PlayerState[br]
## Service Operation - GetAttributes
func get_attributes() -> Dictionary:
	return await _send(ServiceOperation.READ_STATISTICS, {})

## Updates the user's language code.
##
## Service Name - PlayerState[br]
## Service Operation - UPDATE_LANGUAGE_CODE
##
## @param language_code The language code to set (e.g. "en")
func update_language_code(language_code: String) -> Dictionary:
	return await _send(ServiceOperation.UPDATE_LANGUAGE_CODE, {OperationParam.PLAYER_STATE_SERVICE_LANGUAGE_CODE: language_code})

## Updates the user's timezone offset.
##
## Service Name - PlayerState[br]
## Service Operation - UPDATE_TIMEZONE_OFFSET
##
## @param timezone_offset The timezone offset in hours
func update_timezone_offset(timezone_offset: float) -> Dictionary:
	return await _send(ServiceOperation.UPDATE_TIMEZONE_OFFSET, {OperationParam.PLAYER_STATE_SERVICE_TIMEZONE_OFFSET: timezone_offset})

## Deletes most data for the currently logged in user. Alias for reset_player_state.
##
## Service Name - PlayerState[br]
## Service Operation - DataReset
func reset_user() -> Dictionary:
	return await _send(ServiceOperation.DATA_RESET, {})

## Completely deletes the user record and all owned data. Alias for delete_player.
##
## Service Name - PlayerState[br]
## Service Operation - FullReset
func delete_user() -> Dictionary:
	return await _send(ServiceOperation.FULL_RESET, {})

## Sets a timed status for the user.
##
## Service Name - PlayerState[br]
## Service Operation - SET_USER_STATUS
##
## @param status_name The status name to set
## @param duration_secs Duration of the status in seconds
## @param details Optional details Dictionary for the status
func set_user_status(status_name: String, duration_secs: int, details: Dictionary) -> Dictionary:
	var req := {
		OperationParam.PLAYER_STATE_SERVICE_STATUS_NAME: status_name,
		OperationParam.PLAYER_STATE_SERVICE_DURATION_SECS: duration_secs,
		OperationParam.PLAYER_STATE_SERVICE_DETAILS: details
	}
	return await _send(ServiceOperation.SET_USER_STATUS, req)

## Gets the user's status.
##
## Service Name - PlayerState[br]
## Service Operation - GET_USER_STATUS
##
## @param status_name The status name to get
func get_user_status(status_name: String) -> Dictionary:
	return await _send(ServiceOperation.GET_USER_STATUS, {OperationParam.PLAYER_STATE_SERVICE_STATUS_NAME: status_name})

## Clears the specified user status.
##
## Service Name - PlayerState[br]
## Service Operation - CLEAR_USER_STATUS
##
## @param status_name The status name to clear
func clear_user_status(status_name: String) -> Dictionary:
	return await _send(ServiceOperation.CLEAR_USER_STATUS, {OperationParam.PLAYER_STATE_SERVICE_STATUS_NAME: status_name})

## Extends the user's status by additional seconds.
##
## Service Name - PlayerState[br]
## Service Operation - EXTEND_USER_STATUS
##
## @param status_name The status name to extend
## @param additional_secs Additional seconds to extend the status
## @param details Optional updated details Dictionary for the status
func extend_user_status(status_name: String, additional_secs: int, details: Dictionary) -> Dictionary:
	var req := {
		OperationParam.PLAYER_STATE_SERVICE_STATUS_NAME: status_name,
		OperationParam.PLAYER_STATE_SERVICE_ADDITIONAL_SECS: additional_secs,
		OperationParam.PLAYER_STATE_SERVICE_DETAILS: details
	}
	return await _send(ServiceOperation.EXTEND_USER_STATUS, req)

## Sets a timed status for the user. Alias for set_user_status.
##
## Service Name - PlayerState[br]
## Service Operation - SET_USER_STATUS
##
## @param status_name The status name to set
## @param duration_secs Duration of the status in seconds
## @param data Optional details Dictionary for the status
func update_status(status_name: String, duration_secs: int, data: Dictionary) -> Dictionary:
	return await set_user_status(status_name, duration_secs, data)

## Sets the user's experience points to an absolute value.
##
## Service Name - PlayerState[br]
## Service Operation - SetXpPoints
##
## @param xp_value The experience point value to set
func set_experience_points(xp_value: int) -> Dictionary:
	return await _send(ServiceOperation.SET_EXPERIENCE_POINTS, {"xpPoints": xp_value})

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.PLAYER_STATE, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
