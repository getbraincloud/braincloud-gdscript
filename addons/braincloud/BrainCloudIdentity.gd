# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudIdentity
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

func attach_facebook_identity(fb_user_id: String, auth_token: String) -> Dictionary:
	return await _attach(fb_user_id, auth_token, AuthenticationType.FACEBOOK)

func detach_facebook_identity(fb_user_id: String, cont_as_anon: bool) -> Dictionary:
	return await _detach(fb_user_id, AuthenticationType.FACEBOOK, cont_as_anon)

func merge_facebook_identity(fb_user_id: String, auth_token: String) -> Dictionary:
	return await _merge(fb_user_id, auth_token, AuthenticationType.FACEBOOK)

func attach_email_identity(email: String, password: String) -> Dictionary:
	return await _attach(email, password, AuthenticationType.EMAIL)

func detach_email_identity(email: String, cont_as_anon: bool) -> Dictionary:
	return await _detach(email, AuthenticationType.EMAIL, cont_as_anon)

func merge_email_identity(email: String, password: String) -> Dictionary:
	return await _merge(email, password, AuthenticationType.EMAIL)

func attach_universal_identity(user_id: String, password: String) -> Dictionary:
	return await _attach(user_id, password, AuthenticationType.UNIVERSAL)

func detach_universal_identity(user_id: String, cont_as_anon: bool) -> Dictionary:
	return await _detach(user_id, AuthenticationType.UNIVERSAL, cont_as_anon)

func merge_universal_identity(user_id: String, password: String) -> Dictionary:
	return await _merge(user_id, password, AuthenticationType.UNIVERSAL)

func attach_steam_identity(steam_id: String, session_ticket: String) -> Dictionary:
	return await _attach(steam_id, session_ticket, AuthenticationType.STEAM)

func detach_steam_identity(steam_id: String, cont_as_anon: bool) -> Dictionary:
	return await _detach(steam_id, AuthenticationType.STEAM, cont_as_anon)

func merge_steam_identity(steam_id: String, session_ticket: String) -> Dictionary:
	return await _merge(steam_id, session_ticket, AuthenticationType.STEAM)

func attach_game_center_identity(game_center_id: String) -> Dictionary:
	return await _attach(game_center_id, "", AuthenticationType.GAME_CENTER)

func detach_game_center_identity(game_center_id: String, cont_as_anon: bool) -> Dictionary:
	return await _detach(game_center_id, AuthenticationType.GAME_CENTER, cont_as_anon)

func merge_game_center_identity(game_center_id: String) -> Dictionary:
	return await _merge(game_center_id, "", AuthenticationType.GAME_CENTER)

func attach_google_identity(google_user_id: String, server_auth_code: String) -> Dictionary:
	return await _attach(google_user_id, server_auth_code, AuthenticationType.GOOGLE)

func detach_google_identity(google_user_id: String, cont_as_anon: bool) -> Dictionary:
	return await _detach(google_user_id, AuthenticationType.GOOGLE, cont_as_anon)

func merge_google_identity(google_user_id: String, server_auth_code: String) -> Dictionary:
	return await _merge(google_user_id, server_auth_code, AuthenticationType.GOOGLE)

func attach_google_open_id_identity(google_user_account_email: String, id_token: String) -> Dictionary:
	return await _attach(google_user_account_email, id_token, AuthenticationType.GOOGLE_OPEN_ID)

func detach_google_open_id_identity(google_user_account_email: String, cont_as_anon: bool) -> Dictionary:
	return await _detach(google_user_account_email, AuthenticationType.GOOGLE_OPEN_ID, cont_as_anon)

func merge_google_open_id_identity(google_user_account_email: String, id_token: String) -> Dictionary:
	return await _merge(google_user_account_email, id_token, AuthenticationType.GOOGLE_OPEN_ID)

func attach_twitter_identity(twitter_id: String, auth_token: String, secret: String) -> Dictionary:
	return await _attach(twitter_id, auth_token + ":" + secret, AuthenticationType.TWITTER)

func detach_twitter_identity(twitter_id: String, cont_as_anon: bool) -> Dictionary:
	return await _detach(twitter_id, AuthenticationType.TWITTER, cont_as_anon)

func merge_twitter_identity(twitter_id: String, auth_token: String, secret: String) -> Dictionary:
	return await _merge(twitter_id, auth_token + ":" + secret, AuthenticationType.TWITTER)

func attach_parse_identity(parse_id: String, auth_token: String) -> Dictionary:
	return await _attach(parse_id, auth_token, AuthenticationType.PARSE)

func detach_parse_identity(parse_id: String, cont_as_anon: bool) -> Dictionary:
	return await _detach(parse_id, AuthenticationType.PARSE, cont_as_anon)

func merge_parse_identity(parse_id: String, auth_token: String) -> Dictionary:
	return await _merge(parse_id, auth_token, AuthenticationType.PARSE)

func attach_blockchain_identity(integration_id: String, public_key: String) -> Dictionary:
	var data := {
		OperationParam.BLOCK_CHAIN_INTEGRATION_ID: integration_id,
		OperationParam.PUBLIC_KEY: public_key
	}
	return await _send(ServiceOperation.ATTACH_BLOCKCHAIN_IDENTITY, data)

func detach_blockchain_identity(integration_id: String) -> Dictionary:
	var data := {
		OperationParam.BLOCK_CHAIN_INTEGRATION_ID: integration_id
	}
	return await _send(ServiceOperation.DETACH_BLOCKCHAIN_IDENTITY, data)

func attach_nonlogin_universal_id(external_id: String) -> Dictionary:
	var data := {
		OperationParam.IDENTITY_SERVICE_EXTERNAL_ID: external_id
	}
	return await _send(ServiceOperation.ATTACH_NONLOGIN_UNIVERSAL, data)

func update_universal_id_login(external_id: String) -> Dictionary:
	var data := {
		OperationParam.IDENTITY_SERVICE_EXTERNAL_ID: external_id
	}
	return await _send(ServiceOperation.UPDATE_UNIVERSAL_LOGIN, data)

func attach_parent_with_identity(external_id: String, auth_token: String, auth_type: String, external_auth_name: String, force_create: bool) -> Dictionary:
	var data := {
		OperationParam.IDENTITY_SERVICE_EXTERNAL_ID: external_id,
		OperationParam.IDENTITY_SERVICE_AUTHENTICATION_TOKEN: auth_token,
		OperationParam.IDENTITY_SERVICE_AUTHENTICATION_TYPE: auth_type,
		OperationParam.IDENTITY_SERVICE_EXTERNAL_AUTH_NAME: external_auth_name,
		OperationParam.IDENTITY_SERVICE_FORCE_CREATE: force_create
	}
	return await _send(ServiceOperation.ATTACH_PARENT_WITH_IDENTITY, data)

func detach_parent() -> Dictionary:
	return await _send(ServiceOperation.DETACH_PARENT, {})

func switch_to_child_profile(child_profile_id: String, child_app_id: String, force_create: bool) -> Dictionary:
	var data := {
		OperationParam.PROFILE_ID: child_profile_id,
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_GAME_ID: child_app_id,
		OperationParam.IDENTITY_SERVICE_FORCE_CREATE: force_create
	}
	return await _send(ServiceOperation.SWITCH_TO_CHILD_PROFILE, data)

func switch_to_singleton_child_profile(child_app_id: String, force_create: bool) -> Dictionary:
	var data := {
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_GAME_ID: child_app_id,
		OperationParam.IDENTITY_SERVICE_FORCE_CREATE: force_create
	}
	return await _send(ServiceOperation.SWITCH_TO_CHILD_PROFILE, data)

func change_email_identity(old_email: String, password: String, new_email: String, update_contact_email: bool) -> Dictionary:
	var data := {
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_EXTERNAL_ID: old_email,
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_AUTHENTICATION_TOKEN: password,
		"updateContactEmail": update_contact_email,
		"newEmailAddress": new_email
	}
	return await _send("CHANGE_EMAIL_IDENTITY", data)

func get_identity_status(auth_type: String, external_auth_name: String) -> Dictionary:
	var data := {
		OperationParam.IDENTITY_SERVICE_AUTHENTICATION_TYPE: auth_type,
		OperationParam.IDENTITY_SERVICE_EXTERNAL_AUTH_NAME: external_auth_name
	}
	return await _send("GET_IDENTITY_STATUS", data)

func switch_to_parent_profile(parent_level_name: String) -> Dictionary:
	var data := {
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_LEVEL_NAME: parent_level_name
	}
	return await _send(ServiceOperation.SWITCH_TO_PARENT_PROFILE, data)

func get_child_profiles(include_summary_data: bool) -> Dictionary:
	var data := {
		OperationParam.FRIEND_SERVICE_INCLUDE_SUMMARY_DATA: include_summary_data
	}
	return await _send(ServiceOperation.GET_CHILDREN_ENTITIES, data)

func get_identities() -> Dictionary:
	return await _send(ServiceOperation.GET_IDENTITIES, {})

func get_expired_identities() -> Dictionary:
	return await _send("GET_EXPIRED_IDENTITIES", {})

func refresh_identity(external_id: String, auth_token: String, auth_type: String) -> Dictionary:
	var data := {
		OperationParam.IDENTITY_SERVICE_EXTERNAL_ID: external_id,
		OperationParam.IDENTITY_SERVICE_AUTHENTICATION_TOKEN: auth_token,
		OperationParam.IDENTITY_SERVICE_AUTHENTICATION_TYPE: auth_type
	}
	return await _send("REFRESH_IDENTITY", data)

func attach_peer_profile(peer_code: String, external_id: String, auth_token: String, auth_type: String, external_auth_name: String, force_create: bool) -> Dictionary:
	var data := {
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_PEER_CODE: peer_code,
		OperationParam.IDENTITY_SERVICE_EXTERNAL_ID: external_id,
		OperationParam.IDENTITY_SERVICE_AUTHENTICATION_TOKEN: auth_token,
		OperationParam.IDENTITY_SERVICE_AUTHENTICATION_TYPE: auth_type,
		OperationParam.IDENTITY_SERVICE_EXTERNAL_AUTH_NAME: external_auth_name,
		OperationParam.IDENTITY_SERVICE_FORCE_CREATE: force_create
	}
	return await _send(ServiceOperation.ATTACH, data)

func detach_peer(peer_code: String) -> Dictionary:
	var data := {
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_PEER_CODE: peer_code
	}
	return await _send(ServiceOperation.DETACH, data)

func get_peer_profiles() -> Dictionary:
	return await _send(ServiceOperation.GET_PEER_PROFILES, {})

func _attach(external_id: String, auth_token: String, auth_type: String) -> Dictionary:
	var data := {
		OperationParam.IDENTITY_SERVICE_EXTERNAL_ID: external_id,
		OperationParam.IDENTITY_SERVICE_AUTHENTICATION_TOKEN: auth_token,
		OperationParam.IDENTITY_SERVICE_AUTHENTICATION_TYPE: auth_type
	}
	return await _send(ServiceOperation.ATTACH, data)

func _detach(external_id: String, auth_type: String, cont_as_anon: bool) -> Dictionary:
	var data := {
		OperationParam.IDENTITY_SERVICE_EXTERNAL_ID: external_id,
		OperationParam.IDENTITY_SERVICE_AUTHENTICATION_TYPE: auth_type,
		OperationParam.IDENTITY_SERVICE_CONFIRM_PROFILE_ID: cont_as_anon
	}
	return await _send(ServiceOperation.DETACH, data)

func _merge(external_id: String, auth_token: String, auth_type: String) -> Dictionary:
	var data := {
		OperationParam.IDENTITY_SERVICE_EXTERNAL_ID: external_id,
		OperationParam.IDENTITY_SERVICE_AUTHENTICATION_TOKEN: auth_token,
		OperationParam.IDENTITY_SERVICE_AUTHENTICATION_TYPE: auth_type
	}
	return await _send(ServiceOperation.MERGE, data)

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.IDENTITY, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
