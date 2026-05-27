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

## Used to create the anonymous installation id for the brainCloud profile.
##
## @returns A unique anonymous ID string
func generate_anonymous_id() -> String:
	return "%08x-%04x-4%03x-%04x-%012x" % [
		randi(), randi() % 0xFFFF,
		randi() % 0xFFF,
		(randi() % 0x3FFF) | 0x8000,
		(randi() % 0xFFFFFFFF) * 0x10000 + randi() % 0xFFFF
	]

## Initializes the identity service with a saved anonymous installation id and most recently used profile id.
##
## @param profile_id The id of the profile that was most recently used by the app on this device
## @param anonymous_id The anonymous installation id that was generated for this device
func initialize(profile_id: String, anonymous_id: String) -> void:
	_profile_id = profile_id
	_anonymous_id = anonymous_id
	compress_response = true

## Used to clear the saved profile id - use in cases when the user is attempting to switch to a different game profile.
func clear_saved_profile_id() -> void:
	_profile_id = ""

## Authenticates a user anonymously with brainCloud - used for apps that don't want to bother the user to login,
## or for users who are sensitive to their privacy.
##
## Service Name - Authenticate[br]
## Service Operation - Authenticate
##
## @param force_create Should a new profile be created if it does not exist?
func authenticate_anonymous(force_create: bool = true) -> Dictionary:
	return await _authenticate(
		_anonymous_id, "", AuthenticationType.ANONYMOUS, force_create)

## Authenticates the user with a custom Email and Password.
##
## Service Name - Authenticate[br]
## Service Operation - Authenticate
##
## @param email The e-mail address of the user
## @param password The password of the user
## @param force_create Should a new profile be created for this user if the account does not exist?
func authenticate_email_password(email: String, password: String, force_create: bool) -> Dictionary:
	return await _authenticate(email, password, AuthenticationType.EMAIL, force_create)

## Authenticates the user using a userid and password (without any validation on the userid).
##
## Service Name - Authenticate[br]
## Service Operation - Authenticate
##
## @param user_id The user id
## @param password The user's password
## @param force_create Should a new profile be created for this user if the account does not exist?
func authenticate_universal(user_id: String, password: String, force_create: bool) -> Dictionary:
	return await _authenticate(user_id, password, AuthenticationType.UNIVERSAL, force_create)

## Authenticates the user with brainCloud using their Facebook Credentials.
##
## Service Name - Authenticate[br]
## Service Operation - Authenticate
##
## @param facebook_id The Facebook id of the user
## @param token The validated token from the Facebook SDK
## @param force_create Should a new profile be created for this user if the account does not exist?
func authenticate_facebook(facebook_id: String, token: String, force_create: bool) -> Dictionary:
	return await _authenticate(facebook_id, token, AuthenticationType.FACEBOOK, force_create)

## Authenticates the user with brainCloud using their Facebook Limited Credentials.
##
## Service Name - Authenticate[br]
## Service Operation - Authenticate
##
## @param facebook_id The Facebook Limited id of the user
## @param token The validated token from the Facebook Limited SDK
## @param force_create Should a new profile be created for this user if the account does not exist?
func authenticate_facebook_limited(facebook_id: String, token: String, force_create: bool) -> Dictionary:
	return await _authenticate(facebook_id, token, AuthenticationType.FACEBOOK_LIMITED, force_create)

## Authenticates the user using their Game Center id.
##
## Service Name - Authenticate[br]
## Service Operation - Authenticate
##
## @param game_center_id The player's Game Center id
## @param force_create Should a new profile be created for this user if the account does not exist?
func authenticate_game_center(game_center_id: String, force_create: bool) -> Dictionary:
	return await _authenticate(game_center_id, "", AuthenticationType.GAME_CENTER, force_create)

## Authenticates the user using a Steam userid and session ticket.
##
## Service Name - Authenticate[br]
## Service Operation - Authenticate
##
## @param steam_id String representation of 64 bit Steam id
## @param session_ticket The session ticket of the user (hex encoded)
## @param force_create Should a new profile be created for this user if the account does not exist?
func authenticate_steam(steam_id: String, session_ticket: String, force_create: bool) -> Dictionary:
	return await _authenticate(steam_id, session_ticket, AuthenticationType.STEAM, force_create)

## Authenticates the user using an Apple user id and identity token.
##
## Service Name - Authenticate[br]
## Service Operation - Authenticate
##
## @param apple_user_id The Apple accounts user id or email
## @param identity_token The authentication token confirming the user's identity
## @param force_create Should a new profile be created for this user if the account does not exist?
func authenticate_apple(apple_user_id: String, identity_token: String, force_create: bool) -> Dictionary:
	return await _authenticate(apple_user_id, identity_token, AuthenticationType.APPLE, force_create)

## Authenticates the user using a Google userid and server auth code.
##
## Service Name - Authenticate[br]
## Service Operation - Authenticate
##
## @param google_user_id String representation of Google userid (email)
## @param server_auth_code The authentication token derived via the Google APIs
## @param force_create Should a new profile be created for this user if the account does not exist?
func authenticate_google(google_user_id: String, server_auth_code: String, force_create: bool) -> Dictionary:
	return await _authenticate(google_user_id, server_auth_code, AuthenticationType.GOOGLE, force_create)

## Authenticates the user using a Google user account email and Open ID token.
##
## Service Name - Authenticate[br]
## Service Operation - Authenticate
##
## @param google_user_account_email String representation of Google userid (email)
## @param id_token The authentication token derived via the Google APIs
## @param force_create Should a new profile be created for this user if the account does not exist?
func authenticate_google_open_id(google_user_account_email: String, id_token: String, force_create: bool) -> Dictionary:
	return await _authenticate(google_user_account_email, id_token, AuthenticationType.GOOGLE_OPEN_ID, force_create)

## Authenticates the user using a Twitter userid, authentication token, and secret.
##
## Service Name - Authenticate[br]
## Service Operation - Authenticate
##
## @param twitter_id String representation of Twitter userid
## @param token The authentication token derived via the Twitter APIs
## @param secret The secret given when attempting to link with Twitter
## @param force_create Should a new profile be created for this user if the account does not exist?
func authenticate_twitter(twitter_id: String, token: String, secret: String, force_create: bool) -> Dictionary:
	return await _authenticate(twitter_id, token + ":" + secret, AuthenticationType.TWITTER, force_create)

## Authenticates the user using a Parse userid and authentication token.
##
## Service Name - Authenticate[br]
## Service Operation - Authenticate
##
## @param parse_id String representation of Parse userid
## @param parse_token The authentication token
## @param force_create Should a new profile be created for this user if the account does not exist?
func authenticate_parse(parse_id: String, parse_token: String, force_create: bool) -> Dictionary:
	return await _authenticate(parse_id, parse_token, AuthenticationType.PARSE, force_create)

## Authenticates the user using a settop handoff code generated from a cloud script.
##
## Service Name - Authenticate[br]
## Service Operation - Authenticate
##
## @param handoff_code The handoff code generated in cloud code
func authenticate_settop_handoff(handoff_code: String) -> Dictionary:
	return await _authenticate(handoff_code, "", AuthenticationType.SETTOP_HANDOFF, false)

## Authenticates the user using a handoff id and security token.
##
## Service Name - Authenticate[br]
## Service Operation - Authenticate
##
## @param handoff_id The brainCloud handoff id generated from a cloud script
## @param security_token The authentication token
## @param force_create Should a new profile be created for this user if the account does not exist?
func authenticate_handoff(handoff_id: String, security_token: String, force_create: bool) -> Dictionary:
	return await _authenticate(handoff_id, security_token, AuthenticationType.HANDOFF, force_create)

## Authenticates the user for Ultra.
##
## Service Name - Authenticate[br]
## Service Operation - Authenticate
##
## @param ultra_username The username used to log into the Ultra endpoint
## @param ultra_id_token The id_token taken from Ultra's JWT
## @param force_create Should a new profile be created for this user if the account does not exist?
func authenticate_ultra(ultra_username: String, ultra_id_token: String, force_create: bool) -> Dictionary:
	return await _authenticate(ultra_username, ultra_id_token, AuthenticationType.ULTRA, force_create)

## Authenticates the user using Nintendo credentials.
##
## Service Name - Authenticate[br]
## Service Operation - Authenticate
##
## @param nintendo_account_id The Nintendo account id of the user
## @param nintendo_auth_token The Nintendo authentication token
## @param force_create Should a new profile be created for this user if the account does not exist?
func authenticate_nintendo(nintendo_account_id: String, nintendo_auth_token: String, force_create: bool) -> Dictionary:
	return await _authenticate(nintendo_account_id, nintendo_auth_token, AuthenticationType.NINTENDO, force_create)

## Authenticates the user via cloud code (which validates the supplied credentials against an external system).
## Allows brainCloud authentication to be extended to support other backend authentication systems.
##
## Service Name - Authenticate[br]
## Service Operation - Authenticate
##
## @param user_id The user id
## @param token The user token (password etc)
## @param external_auth_name The name of the cloud script to call for external authentication
## @param force_create Should a new profile be created for this user if the account does not exist?
func authenticate_external(user_id: String, token: String, external_auth_name: String, force_create: bool) -> Dictionary:
	var data := _build_base_auth_data(user_id, token, AuthenticationType.UNKNOWN, force_create)
	data[OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_EXTERNAL_AUTH_NAME] = external_auth_name
	return await _send_auth_call(data)

## Sends a password reset email to the specified address.
##
## Service Name - Authenticate[br]
## Service Operation - ResetEmailPassword
##
## @param email The email address to send the reset email to
func reset_email_password(email: String) -> Dictionary:
	var data := {
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_GAME_ID: _client_ref.get_app_id(),
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_EXTERNAL_ID: email
	}
	return await _send_call(ServiceOperation.RESET_EMAIL_PASSWORD, data)

## Sends a password reset email to the specified address, with additional service parameters.
##
## Service Name - Authenticate[br]
## Service Operation - ResetEmailPasswordAdvanced
##
## @param email The email address to send the reset email to
## @param service_params Parameters to send to the email service
func reset_email_password_advanced(email: String, service_params: Dictionary) -> Dictionary:
	var data := {
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_GAME_ID: _client_ref.get_app_id(),
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_EXTERNAL_ID: email,
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_SERVICE_PARAMS: service_params
	}
	return await _send_call(ServiceOperation.RESET_EMAIL_PASSWORD_ADVANCED, data)

## Sends a password reset email to the specified address with a token expiry time.
##
## Service Name - Authenticate[br]
## Service Operation - ResetEmailPasswordWithExpiry
##
## @param email The email address to send the reset email to
## @param token_ttl_in_minutes The time-to-live of the reset token in minutes
func reset_email_password_with_expiry(email: String, token_ttl_in_minutes: int) -> Dictionary:
	var data := {
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_GAME_ID: _client_ref.get_app_id(),
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_EXTERNAL_ID: email,
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_TOKEN_TTL_IN_MINUTES: token_ttl_in_minutes
	}
	return await _send_call(ServiceOperation.RESET_EMAIL_PASSWORD_WITH_EXPIRY, data)

## Sends a password reset email with service parameters and a token expiry time.
##
## Service Name - Authenticate[br]
## Service Operation - ResetEmailPasswordAdvancedWithExpiry
##
## @param email The email address to send the reset email to
## @param service_params Parameters to send to the email service
## @param token_ttl_in_minutes The time-to-live of the reset token in minutes
func reset_email_password_advanced_with_expiry(email: String, service_params: Dictionary, token_ttl_in_minutes: int) -> Dictionary:
	var data := {
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_GAME_ID: _client_ref.get_app_id(),
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_EXTERNAL_ID: email,
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_SERVICE_PARAMS: service_params,
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_TOKEN_TTL_IN_MINUTES: token_ttl_in_minutes
	}
	return await _send_call(ServiceOperation.RESET_EMAIL_PASSWORD_ADVANCED_WITH_EXPIRY, data)

## Resets the password for the specified Universal ID.
##
## Service Name - Authenticate[br]
## Service Operation - ResetUniversalIdPassword
##
## @param universal_id The Universal ID whose password to reset
func reset_universal_id_password(universal_id: String) -> Dictionary:
	var data := {
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_GAME_ID: _client_ref.get_app_id(),
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_UNIVERSAL_ID: universal_id
	}
	return await _send_call(ServiceOperation.RESET_UNIVERSAL_ID_PASSWORD, data)

## Resets the Universal ID password using a template with additional service parameters.
##
## Service Name - Authenticate[br]
## Service Operation - ResetUniversalIdPasswordAdvanced
##
## @param universal_id The Universal ID whose password to reset
## @param service_params Parameters to send to the email service
func reset_universal_id_password_advanced(universal_id: String, service_params: Dictionary) -> Dictionary:
	var data := {
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_GAME_ID: _client_ref.get_app_id(),
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_UNIVERSAL_ID: universal_id,
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_SERVICE_PARAMS: service_params
	}
	return await _send_call(ServiceOperation.RESET_UNIVERSAL_ID_PASSWORD_ADVANCED, data)

## Resets the Universal ID password with a token expiry time.
##
## Service Name - Authenticate[br]
## Service Operation - ResetUniversalIdPasswordWithExpiry
##
## @param universal_id The Universal ID whose password to reset
## @param token_ttl_in_minutes The time-to-live of the reset token in minutes
func reset_universal_id_password_with_expiry(universal_id: String, token_ttl_in_minutes: int) -> Dictionary:
	var data := {
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_GAME_ID: _client_ref.get_app_id(),
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_UNIVERSAL_ID: universal_id,
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_TOKEN_TTL_IN_MINUTES: token_ttl_in_minutes
	}
	return await _send_call(ServiceOperation.RESET_UNIVERSAL_ID_PASSWORD_WITH_EXPIRY, data)

## Resets the Universal ID password using a template with service parameters and a token expiry time.
##
## Service Name - Authenticate[br]
## Service Operation - ResetUniversalIdPasswordAdvancedWithExpiry
##
## @param universal_id The Universal ID whose password to reset
## @param service_params Parameters to send to the email service
## @param token_ttl_in_minutes The time-to-live of the reset token in minutes
func reset_universal_id_password_advanced_with_expiry(universal_id: String, service_params: Dictionary, token_ttl_in_minutes: int) -> Dictionary:
	var data := {
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_GAME_ID: _client_ref.get_app_id(),
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_UNIVERSAL_ID: universal_id,
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_SERVICE_PARAMS: service_params,
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_TOKEN_TTL_IN_MINUTES: token_ttl_in_minutes
	}
	return await _send_call(ServiceOperation.RESET_UNIVERSAL_ID_PASSWORD_ADVANCED_WITH_EXPIRY, data)

## Gets the current server version.
##
## Service Name - Authenticate[br]
## Service Operation - GetServerVersion
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
