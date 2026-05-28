# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudLobby
extends RefCounted

var _client_ref: BrainCloudClient
var _ping_data: Dictionary = {}

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

func set_ping_data(ping_data: Dictionary) -> void:
	_ping_data = ping_data

## Finds a lobby matching the specified parameters. Asynchronous - listen to RTT lobby events for updates.
##
## Service Name - Lobby[br]
## Service Operation - FindLobby
##
## @param lobby_type The type of lobby to look for
## @param rating The skill rating to use for finding the lobby
## @param max_steps The maximum number of steps to wait when looking for an applicable lobby
## @param algo The algorithm to use for lobby finding
## @param filter_json Additional filter criteria
## @param is_ready Whether this player is ready to start
## @param extra_json Extra data to store with this player
## @param team_code The preferred team code for this player
## @param other_user_cx_ids Array of other player connection ids to add to the lobby
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

## Like find_lobby, but will create a lobby if none are found. Asynchronous - listen to RTT lobby events for updates.
##
## Service Name - Lobby[br]
## Service Operation - FindOrCreateLobby
##
## @param lobby_type The type of lobby to look for
## @param rating The skill rating to use for finding the lobby
## @param max_steps The maximum number of steps to wait when looking for an applicable lobby
## @param algo The algorithm to use for lobby finding
## @param filter_json Additional filter criteria
## @param settings Initial settings for the lobby if one is created
## @param is_ready Whether this player is ready to start
## @param extra_json Extra data to store with this player
## @param team_code The preferred team code for this player
## @param other_user_cx_ids Array of other player connection ids to add to the lobby
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

## Like find_or_create_lobby, but ping data will be used in the search to best match the user.
##
## Service Name - Lobby[br]
## Service Operation - FindOrCreateLobby
##
## @param lobby_type The type of lobby to look for
## @param rating The skill rating to use for finding the lobby
## @param max_steps The maximum number of steps to wait when looking for an applicable lobby
## @param algo The algorithm to use for lobby finding
## @param filter_json Additional filter criteria
## @param settings Initial settings for the lobby if one is created
## @param is_ready Whether this player is ready to start
## @param extra_json Extra data to store with this player
## @param team_code The preferred team code for this player
## @param other_user_cx_ids Array of other player connection ids to add to the lobby
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
		OperationParam.LOBBY_PING_DATA: _ping_data
	}
	return await _send(ServiceOperation.LOBBY_FIND_OR_CREATE, data)

## Creates a lobby. Asynchronous - listen to RTT lobby events for updates.
##
## Service Name - Lobby[br]
## Service Operation - CreateLobby
##
## @param lobby_type The type of lobby to create
## @param rating The skill rating to use for the lobby
## @param is_ready Whether this player is ready to start
## @param extra_json Extra data to store with this player
## @param team_code The preferred team code for this player
## @param settings Initial settings for the lobby
## @param other_user_cx_ids Array of other player connection ids to add to the lobby
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

## Creates a lobby with the specified configuration overrides. Asynchronous - listen to RTT lobby events for updates.
##
## Service Name - Lobby[br]
## Service Operation - CreateLobbyWithConfig
##
## @param lobby_type The type of lobby to create
## @param rating The skill rating to use for the lobby
## @param is_ready Whether this player is ready to start
## @param extra_json Extra data to store with this player
## @param team_code The preferred team code for this player
## @param settings Initial settings for the lobby
## @param config_overrides Configuration overrides for the lobby
## @param other_user_cx_ids Array of other player connection ids to add to the lobby
func create_lobby_with_config(lobby_type: String, rating: int, is_ready: bool, extra_json: Dictionary, team_code: String, settings: Dictionary, config_overrides: Dictionary, other_user_cx_ids: Array = []) -> Dictionary:
	var data := {
		OperationParam.LOBBY_TYPE: lobby_type,
		OperationParam.LOBBY_RATING: rating,
		OperationParam.LOBBY_SETTINGS: settings,
		OperationParam.LOBBY_IS_READY: is_ready,
		OperationParam.LOBBY_EXTRA_JSON: extra_json,
		OperationParam.LOBBY_TEAM: team_code,
		OperationParam.LOBBY_CONFIG_OVERRIDES: config_overrides,
		OperationParam.LOBBY_OTHER_USER_CX_IDS: other_user_cx_ids,
	}
	return await _send(ServiceOperation.LOBBY_CREATE_WITH_CONFIG, data)

## Creates a lobby with the specified configuration overrides and ping data. Asynchronous - listen to RTT lobby events for updates.
##
## Service Name - Lobby[br]
## Service Operation - CreateLobbyWithConfigAndPingData
##
## @param lobby_type The type of lobby to create
## @param rating The skill rating to use for the lobby
## @param is_ready Whether this player is ready to start
## @param extra_json Extra data to store with this player
## @param team_code The preferred team code for this player
## @param settings Initial settings for the lobby
## @param config_overrides Configuration overrides for the lobby
## @param ping_data Ping data to use for matching
## @param other_user_cx_ids Array of other player connection ids to add to the lobby
func create_lobby_with_config_and_ping_data(lobby_type: String, rating: int, is_ready: bool, extra_json: Dictionary, team_code: String, settings: Dictionary, config_overrides: Dictionary, ping_data: Dictionary, other_user_cx_ids: Array = []) -> Dictionary:
	var data := {
		OperationParam.LOBBY_TYPE: lobby_type,
		OperationParam.LOBBY_RATING: rating,
		OperationParam.LOBBY_SETTINGS: settings,
		OperationParam.LOBBY_IS_READY: is_ready,
		OperationParam.LOBBY_EXTRA_JSON: extra_json,
		OperationParam.LOBBY_TEAM: team_code,
		OperationParam.LOBBY_CONFIG_OVERRIDES: config_overrides,
		OperationParam.LOBBY_PING_DATA: ping_data,
		OperationParam.LOBBY_OTHER_USER_CX_IDS: other_user_cx_ids,
	}
	return await _send(ServiceOperation.LOBBY_CREATE_WITH_CONFIG_AND_PING_DATA, data)

## Adds the caller to the specified lobby. Asynchronous - listen to RTT lobby events for updates.
##
## Service Name - Lobby[br]
## Service Operation - JoinLobby
##
## @param lobby_id The lobby id to join
## @param is_ready Whether this player is ready to start
## @param extra_json Extra data to store with this player
## @param team_code The preferred team code for this player
## @param other_user_cx_ids Array of other player connection ids to add to the lobby
func join_lobby(lobby_id: String, is_ready: bool, extra_json: Dictionary, team_code: String, other_user_cx_ids: Array) -> Dictionary:
	var data := {
		OperationParam.LOBBY_ID: lobby_id,
		OperationParam.LOBBY_IS_READY: is_ready,
		OperationParam.LOBBY_EXTRA_JSON: extra_json,
		OperationParam.LOBBY_TEAM: team_code,
		OperationParam.LOBBY_OTHER_USER_CX_IDS: other_user_cx_ids
	}
	return await _send(ServiceOperation.LOBBY_JOIN, data)

## Removes the caller from the specified lobby. If the lobby is empty afterwards, it will be deleted.
##
## Service Name - Lobby[br]
## Service Operation - LeaveLobby
##
## @param lobby_id The lobby id to leave
func leave_lobby(lobby_id: String) -> Dictionary:
	var data := {
		OperationParam.LOBBY_ID: lobby_id
	}
	return await _send(ServiceOperation.LOBBY_LEAVE, data)

## Removes the specified member from the lobby.
##
## Service Name - Lobby[br]
## Service Operation - RemoveMember
##
## @param lobby_id The lobby id
## @param connection_id The connection id of the member to remove
func remove_member(lobby_id: String, connection_id: String) -> Dictionary:
	var data := {
		OperationParam.LOBBY_ID: lobby_id,
		OperationParam.LOBBY_CONNECTION_ID: connection_id
	}
	return await _send(ServiceOperation.LOBBY_REMOVE_MEMBER, data)

## Cancels the find request associated with the specified entryId.
##
## Service Name - Lobby[br]
## Service Operation - CancelFindRequest
##
## @param lobby_type The lobby type of the find request to cancel
## @param entry_id The entry id of the find request to cancel
func cancel_find_request(lobby_type: String, entry_id: String) -> Dictionary:
	var data := {
		OperationParam.LOBBY_TYPE: lobby_type,
		OperationParam.LOBBY_CONNECTION_ID: "",
		OperationParam.LOBBY_ENTRY_ID: entry_id
	}
	return await _send(ServiceOperation.LOBBY_CANCEL_FIND, data)

## Returns the data for the specified lobby.
##
## Service Name - Lobby[br]
## Service Operation - GetLobbyData
##
## @param lobby_id The lobby id
func get_lobby_data(lobby_id: String) -> Dictionary:
	var data := {
		OperationParam.LOBBY_ID: lobby_id
	}
	return await _send(ServiceOperation.LOBBY_GET, data)

## Destroys the lobby associated with the specified lobbyId.
##
## Service Name - Lobby[br]
## Service Operation - DestroyLobby
##
## @param lobby_id The lobby id to destroy
func destroy_lobby(lobby_id: String) -> Dictionary:
	var data := {
		OperationParam.LOBBY_ID: lobby_id
	}
	return await _send(ServiceOperation.LOBBY_DESTROY, data)

## Sends a signal to all lobby members.
##
## Service Name - Lobby[br]
## Service Operation - SendSignal
##
## @param lobby_id The lobby id
## @param signal_data The signal data to send to all lobby members
func send_signal(lobby_id: String, signal_data: Dictionary) -> Dictionary:
	var data := {
		OperationParam.LOBBY_ID: lobby_id,
		OperationParam.LOBBY_SIGNAL_DATA: signal_data
	}
	return await _send(ServiceOperation.LOBBY_SEND_SIGNAL, data)

## Switches the caller to the specified team.
##
## Service Name - Lobby[br]
## Service Operation - SwitchTeam
##
## @param lobby_id The lobby id
## @param to_team_code The team code to switch to
func switch_team(lobby_id: String, to_team_code: String) -> Dictionary:
	var data := {
		OperationParam.LOBBY_ID: lobby_id,
		OperationParam.LOBBY_TO_TEAM_CODE: to_team_code
	}
	return await _send(ServiceOperation.LOBBY_SWITCH_TEAM, data)

## Updates the caller's ready status and extra data.
##
## Service Name - Lobby[br]
## Service Operation - UpdateReady
##
## @param lobby_id The lobby id
## @param is_ready Whether this player is ready to start
## @param extra_json Extra data to store with this player
func update_ready(lobby_id: String, is_ready: bool, extra_json: Dictionary) -> Dictionary:
	var data := {
		OperationParam.LOBBY_ID: lobby_id,
		OperationParam.LOBBY_IS_READY: is_ready,
		OperationParam.LOBBY_EXTRA_JSON: extra_json
	}
	return await _send(ServiceOperation.LOBBY_UPDATE_READY, data)

## Updates the lobby settings.
##
## Service Name - Lobby[br]
## Service Operation - UpdateSettings
##
## @param lobby_id The lobby id
## @param settings The updated settings for the lobby
func update_settings(lobby_id: String, settings: Dictionary) -> Dictionary:
	var data := {
		OperationParam.LOBBY_ID: lobby_id,
		OperationParam.LOBBY_SETTINGS: settings
	}
	return await _send(ServiceOperation.LOBBY_UPDATE_SETTINGS, data)

## Gets a list of regions for the specified lobby types.
##
## Service Name - Lobby[br]
## Service Operation - GetRegionsForLobbies
##
## @param lobby_types Array of lobby type names to get regions for
func get_regions_for_lobbies(lobby_types: Array) -> Dictionary:
	var data := {
		OperationParam.LOBBY_TYPES: lobby_types
	}
	return await _send(ServiceOperation.LOBBY_GET_REGIONS, data)

## Gets a list of pending lobbies filtered by lobby type and criteria.
##
## Service Name - Lobby[br]
## Service Operation - GetLobbyInstances
##
## @param lobby_type The lobby type to search
## @param criteria_json Additional filter criteria
func get_lobby_instances(lobby_type: String, criteria_json: Dictionary) -> Dictionary:
	var data := {
		OperationParam.LOBBY_TYPE: lobby_type,
		OperationParam.LOBBY_CRITERIA: criteria_json
	}
	return await _send(ServiceOperation.LOBBY_GET_INSTANCES, data)

## Like get_lobby_instances but results are filtered by ping data for best match.
##
## Service Name - Lobby[br]
## Service Operation - GetLobbyInstancesWithPingData
##
## @param lobby_type The lobby type to search
## @param criteria_json Additional filter criteria
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
