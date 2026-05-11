# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudAuthentication
extends RefCounted

var _client_ref: BrainCloudClient = null
var _anonymous_id: String = ""
var _profile_id: String = ""
var compress_response: bool = true

var profile_id: String:
	get: return _profile_id
	set(v): _profile_id = v

var anonymous_id: String:
	get: return _anonymous_id
	set(v): _anonymous_id = v

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

func generate_anonymous_id() -> String:
	return "%08x-%04x-4%03x-%04x-%012x" % [
		randi(), randi() % 0xFFFF,
		randi() % 0xFFF,
		(randi() % 0x3FFF) | 0x8000,
		(randi() % 0xFFFFFFFF) * 0x10000 + randi() % 0xFFFF
	]

func initialize(profile_id: String, anonymous_id: String) -> void:
	_profile_id = profile_id
	_anonymous_id = anonymous_id
	compress_response = true

func clear_saved_profile_id() -> void:
	_profile_id = ""

func authenticate_anonymous(force_create: bool = true) -> Dictionary:
	return await _authenticate(
		_anonymous_id, "", AuthenticationType.ANONYMOUS, force_create)

func authenticate_email_password(email: String, password: String, force_create: bool) -> Dictionary:
	return await _authenticate(email, password, AuthenticationType.EMAIL, force_create)

func authenticate_universal(user_id: String, password: String, force_create: bool) -> Dictionary:
	return await _authenticate(user_id, password, AuthenticationType.UNIVERSAL, force_create)

func authenticate_facebook(facebook_id: String, token: String, force_create: bool) -> Dictionary:
	return await _authenticate(facebook_id, token, AuthenticationType.FACEBOOK, force_create)

func authenticate_facebook_limited(facebook_id: String, token: String, force_create: bool) -> Dictionary:
	return await _authenticate(facebook_id, token, AuthenticationType.FACEBOOK_LIMITED, force_create)

func authenticate_game_center(game_center_id: String, force_create: bool) -> Dictionary:
	return await _authenticate(game_center_id, "", AuthenticationType.GAME_CENTER, force_create)

func authenticate_steam(steam_id: String, session_ticket: String, force_create: bool) -> Dictionary:
	return await _authenticate(steam_id, session_ticket, AuthenticationType.STEAM, force_create)

func authenticate_apple(apple_user_id: String, identity_token: String, force_create: bool) -> Dictionary:
	return await _authenticate(apple_user_id, identity_token, AuthenticationType.APPLE, force_create)

func authenticate_google(google_user_id: String, server_auth_code: String, force_create: bool) -> Dictionary:
	return await _authenticate(google_user_id, server_auth_code, AuthenticationType.GOOGLE, force_create)

func authenticate_google_open_id(google_user_account_email: String, id_token: String, force_create: bool) -> Dictionary:
	return await _authenticate(google_user_account_email, id_token, AuthenticationType.GOOGLE_OPEN_ID, force_create)

func authenticate_twitter(twitter_id: String, token: String, secret: String, force_create: bool) -> Dictionary:
	return await _authenticate(twitter_id, token + ":" + secret, AuthenticationType.TWITTER, force_create)

func authenticate_parse(parse_id: String, parse_token: String, force_create: bool) -> Dictionary:
	return await _authenticate(parse_id, parse_token, AuthenticationType.PARSE, force_create)

func authenticate_settop_handoff(handoff_code: String) -> Dictionary:
	return await _authenticate(handoff_code, "", AuthenticationType.SETTOP_HANDOFF, false)

func authenticate_handoff(handoff_id: String, security_token: String, force_create: bool) -> Dictionary:
	return await _authenticate(handoff_id, security_token, AuthenticationType.HANDOFF, force_create)

func authenticate_ultra(ultra_username: String, ultra_id_token: String, force_create: bool) -> Dictionary:
	return await _authenticate(ultra_username, ultra_id_token, AuthenticationType.ULTRA, force_create)

func authenticate_nintendo(nintendo_account_id: String, nintendo_auth_token: String, force_create: bool) -> Dictionary:
	return await _authenticate(nintendo_account_id, nintendo_auth_token, AuthenticationType.NINTENDO, force_create)

func authenticate_external(user_id: String, token: String, external_auth_name: String, force_create: bool) -> Dictionary:
	var data := _build_base_auth_data(user_id, token, AuthenticationType.UNKNOWN, force_create)
	data[OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_EXTERNAL_AUTH_NAME] = external_auth_name
	return await _send_auth_call(data)

func reset_email_password(email: String) -> Dictionary:
	var data := {
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_GAME_ID: _client_ref.get_app_id(),
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_EXTERNAL_ID: email
	}
	return await _send_call(ServiceOperation.RESET_EMAIL_PASSWORD, data)

func reset_email_password_advanced(email: String, service_params: Dictionary) -> Dictionary:
	var data := {
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_GAME_ID: _client_ref.get_app_id(),
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_EXTERNAL_ID: email,
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_SERVICE_PARAMS: service_params
	}
	return await _send_call(ServiceOperation.RESET_EMAIL_PASSWORD_ADVANCED, data)

func reset_email_password_with_expiry(email: String, token_ttl_in_minutes: int) -> Dictionary:
	var data := {
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_GAME_ID: _client_ref.get_app_id(),
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_EXTERNAL_ID: email,
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_TOKEN_TTL_IN_MINUTES: token_ttl_in_minutes
	}
	return await _send_call(ServiceOperation.RESET_EMAIL_PASSWORD_WITH_EXPIRY, data)

func reset_email_password_advanced_with_expiry(email: String, service_params: Dictionary, token_ttl_in_minutes: int) -> Dictionary:
	var data := {
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_GAME_ID: _client_ref.get_app_id(),
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_EXTERNAL_ID: email,
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_SERVICE_PARAMS: service_params,
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_TOKEN_TTL_IN_MINUTES: token_ttl_in_minutes
	}
	return await _send_call(ServiceOperation.RESET_EMAIL_PASSWORD_ADVANCED_WITH_EXPIRY, data)

func reset_universal_id_password(universal_id: String) -> Dictionary:
	var data := {
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_GAME_ID: _client_ref.get_app_id(),
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_UNIVERSAL_ID: universal_id
	}
	return await _send_call(ServiceOperation.RESET_UNIVERSAL_ID_PASSWORD, data)

func reset_universal_id_password_advanced(universal_id: String, service_params: Dictionary) -> Dictionary:
	var data := {
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_GAME_ID: _client_ref.get_app_id(),
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_UNIVERSAL_ID: universal_id,
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_SERVICE_PARAMS: service_params
	}
	return await _send_call(ServiceOperation.RESET_UNIVERSAL_ID_PASSWORD_ADVANCED, data)

func reset_universal_id_password_with_expiry(universal_id: String, token_ttl_in_minutes: int) -> Dictionary:
	var data := {
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_GAME_ID: _client_ref.get_app_id(),
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_UNIVERSAL_ID: universal_id,
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_TOKEN_TTL_IN_MINUTES: token_ttl_in_minutes
	}
	return await _send_call(ServiceOperation.RESET_UNIVERSAL_ID_PASSWORD_WITH_EXPIRY, data)

func reset_universal_id_password_advanced_with_expiry(universal_id: String, service_params: Dictionary, token_ttl_in_minutes: int) -> Dictionary:
	var data := {
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_GAME_ID: _client_ref.get_app_id(),
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_UNIVERSAL_ID: universal_id,
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_SERVICE_PARAMS: service_params,
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_TOKEN_TTL_IN_MINUTES: token_ttl_in_minutes
	}
	return await _send_call(ServiceOperation.RESET_UNIVERSAL_ID_PASSWORD_ADVANCED_WITH_EXPIRY, data)

func get_server_version() -> Dictionary:
	return await _send_call(ServiceOperation.GET_SERVER_VERSION, {})

func _authenticate(external_id: String, auth_token: String, auth_type: String, force_create: bool) -> Dictionary:
	var data := _build_base_auth_data(external_id, auth_token, auth_type, force_create)
	return await _send_auth_call(data)

func _build_base_auth_data(external_id: String, auth_token: String, auth_type: String, force_create: bool) -> Dictionary:
	return {
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_GAME_ID: _client_ref.get_app_id(),
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_EXTERNAL_ID: external_id,
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_AUTHENTICATION_TOKEN: auth_token,
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_AUTHENTICATION_TYPE: auth_type,
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_FORCE_CREATE: force_create,
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_GAME_VERSION: _client_ref.get_app_version(),
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_BRAINCLOUD_VERSION: _client_ref.get_braincloud_version(),
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_RELEASE_PLATFORM: _client_ref.get_release_platform(),
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_COUNTRY_CODE: _client_ref.get_country_code(),
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_LANGUAGE_CODE: _client_ref.get_language_code(),
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_TIME_ZONE_OFFSET: _get_timezone_offset(),
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_ANONYMOUS_ID: _anonymous_id,
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_PROFILE_ID: _profile_id,
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_COMPRESS_RESPONSE: compress_response
	}

func _send_auth_call(data: Dictionary) -> Dictionary:
	return await _send_call(ServiceOperation.AUTHENTICATE, data)

func _send_call(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.AUTHENTICATE, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received

func _get_timezone_offset() -> float:
	return float(Time.get_time_zone_from_system()["bias"]) / 60.0
