# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudIdentity
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

## Attaches Facebook credentials to the current profile.
##
## Service Name - Identity[br]
## Service Operation - Attach
##
## @param fb_user_id The Facebook id of the user
## @param auth_token The validated token from the Facebook SDK
func attach_facebook_identity(fb_user_id: String, auth_token: String) -> Dictionary:
	return await _attach(fb_user_id, auth_token, AuthenticationType.FACEBOOK)

## Detaches the Facebook identity from the current profile.
##
## Service Name - Identity[br]
## Service Operation - Detach
##
## @param fb_user_id The Facebook id of the user
## @param cont_as_anon Proceed even if the profile will revert to anonymous?
func detach_facebook_identity(fb_user_id: String, cont_as_anon: bool) -> Dictionary:
	return await _detach(fb_user_id, AuthenticationType.FACEBOOK, cont_as_anon)

## Merges the profile associated with the provided Facebook credentials with the current profile.
##
## Service Name - Identity[br]
## Service Operation - Merge
##
## @param fb_user_id The Facebook id of the user
## @param auth_token The validated token from the Facebook SDK
func merge_facebook_identity(fb_user_id: String, auth_token: String) -> Dictionary:
	return await _merge(fb_user_id, auth_token, AuthenticationType.FACEBOOK)

## Attaches an email and password identity to the current profile.
##
## Service Name - Identity[br]
## Service Operation - Attach
##
## @param email The user's e-mail address
## @param password The user's password
func attach_email_identity(email: String, password: String) -> Dictionary:
	return await _attach(email, password, AuthenticationType.EMAIL)

## Detaches the email identity from the current profile.
##
## Service Name - Identity[br]
## Service Operation - Detach
##
## @param email The user's e-mail address
## @param cont_as_anon Proceed even if the profile will revert to anonymous?
func detach_email_identity(email: String, cont_as_anon: bool) -> Dictionary:
	return await _detach(email, AuthenticationType.EMAIL, cont_as_anon)

## Merges the profile associated with the provided email credentials with the current profile.
##
## Service Name - Identity[br]
## Service Operation - Merge
##
## @param email The user's e-mail address
## @param password The user's password
func merge_email_identity(email: String, password: String) -> Dictionary:
	return await _merge(email, password, AuthenticationType.EMAIL)

## Attaches a Universal (userid + password) identity to the current profile.
##
## Service Name - Identity[br]
## Service Operation - Attach
##
## @param user_id The user's userid
## @param password The user's password
func attach_universal_identity(user_id: String, password: String) -> Dictionary:
	return await _attach(user_id, password, AuthenticationType.UNIVERSAL)

## Detaches the universal identity from the current profile.
##
## Service Name - Identity[br]
## Service Operation - Detach
##
## @param user_id The user's userid
## @param cont_as_anon Proceed even if the profile will revert to anonymous?
func detach_universal_identity(user_id: String, cont_as_anon: bool) -> Dictionary:
	return await _detach(user_id, AuthenticationType.UNIVERSAL, cont_as_anon)

## Merges the profile associated with the provided Universal credentials with the current profile.
##
## Service Name - Identity[br]
## Service Operation - Merge
##
## @param user_id The user's userid
## @param password The user's password
func merge_universal_identity(user_id: String, password: String) -> Dictionary:
	return await _merge(user_id, password, AuthenticationType.UNIVERSAL)

## Attaches a Steam identity to the current profile.
##
## Service Name - Identity[br]
## Service Operation - Attach
##
## @param steam_id String representation of 64 bit Steam id
## @param session_ticket The user's session ticket (hex encoded)
func attach_steam_identity(steam_id: String, session_ticket: String) -> Dictionary:
	return await _attach(steam_id, session_ticket, AuthenticationType.STEAM)

## Detaches the Steam identity from the current profile.
##
## Service Name - Identity[br]
## Service Operation - Detach
##
## @param steam_id String representation of 64 bit Steam id
## @param cont_as_anon Proceed even if the profile will revert to anonymous?
func detach_steam_identity(steam_id: String, cont_as_anon: bool) -> Dictionary:
	return await _detach(steam_id, AuthenticationType.STEAM, cont_as_anon)

## Merges the profile associated with the provided Steam credentials with the current profile.
##
## Service Name - Identity[br]
## Service Operation - Merge
##
## @param steam_id String representation of 64 bit Steam id
## @param session_ticket The user's session ticket (hex encoded)
func merge_steam_identity(steam_id: String, session_ticket: String) -> Dictionary:
	return await _merge(steam_id, session_ticket, AuthenticationType.STEAM)

## Attaches a Game Center identity to the current profile.
##
## Service Name - Identity[br]
## Service Operation - Attach
##
## @param game_center_id The player's Game Center id
func attach_game_center_identity(game_center_id: String) -> Dictionary:
	return await _attach(game_center_id, "", AuthenticationType.GAME_CENTER)

## Detaches the Game Center identity from the current profile.
##
## Service Name - Identity[br]
## Service Operation - Detach
##
## @param game_center_id The player's Game Center id
## @param cont_as_anon Proceed even if the profile will revert to anonymous?
func detach_game_center_identity(game_center_id: String, cont_as_anon: bool) -> Dictionary:
	return await _detach(game_center_id, AuthenticationType.GAME_CENTER, cont_as_anon)

## Merges the profile associated with the provided Game Center credentials with the current profile.
##
## Service Name - Identity[br]
## Service Operation - Merge
##
## @param game_center_id The player's Game Center id
func merge_game_center_identity(game_center_id: String) -> Dictionary:
	return await _merge(game_center_id, "", AuthenticationType.GAME_CENTER)

## Attaches Google credentials to the current profile.
##
## Service Name - Identity[br]
## Service Operation - Attach
##
## @param google_user_id The Google id of the user
## @param server_auth_code The validated token from the Google SDK
func attach_google_identity(google_user_id: String, server_auth_code: String) -> Dictionary:
	return await _attach(google_user_id, server_auth_code, AuthenticationType.GOOGLE)

## Detaches the Google identity from the current profile.
##
## Service Name - Identity[br]
## Service Operation - Detach
##
## @param google_user_id The Google id of the user
## @param cont_as_anon Proceed even if the profile will revert to anonymous?
func detach_google_identity(google_user_id: String, cont_as_anon: bool) -> Dictionary:
	return await _detach(google_user_id, AuthenticationType.GOOGLE, cont_as_anon)

## Merges the profile associated with the provided Google credentials with the current profile.
##
## Service Name - Identity[br]
## Service Operation - Merge
##
## @param google_user_id The Google id of the user
## @param server_auth_code The validated token from the Google SDK
func merge_google_identity(google_user_id: String, server_auth_code: String) -> Dictionary:
	return await _merge(google_user_id, server_auth_code, AuthenticationType.GOOGLE)

## Attaches Google Open ID credentials to the current profile.
##
## Service Name - Identity[br]
## Service Operation - Attach
##
## @param google_user_account_email The Google user account email
## @param id_token The authentication token derived via the Google APIs
func attach_google_open_id_identity(google_user_account_email: String, id_token: String) -> Dictionary:
	return await _attach(google_user_account_email, id_token, AuthenticationType.GOOGLE_OPEN_ID)

## Detaches the Google Open ID identity from the current profile.
##
## Service Name - Identity[br]
## Service Operation - Detach
##
## @param google_user_account_email The Google user account email
## @param cont_as_anon Proceed even if the profile will revert to anonymous?
func detach_google_open_id_identity(google_user_account_email: String, cont_as_anon: bool) -> Dictionary:
	return await _detach(google_user_account_email, AuthenticationType.GOOGLE_OPEN_ID, cont_as_anon)

## Merges the profile associated with the provided Google Open ID credentials with the current profile.
##
## Service Name - Identity[br]
## Service Operation - Merge
##
## @param google_user_account_email The Google user account email
## @param id_token The authentication token derived via the Google APIs
func merge_google_open_id_identity(google_user_account_email: String, id_token: String) -> Dictionary:
	return await _merge(google_user_account_email, id_token, AuthenticationType.GOOGLE_OPEN_ID)

## Attaches Twitter credentials to the current profile.
##
## Service Name - Identity[br]
## Service Operation - Attach
##
## @param twitter_id The Twitter id of the user
## @param auth_token The authentication token derived from the Twitter APIs
## @param secret The secret given when attempting to link with Twitter
func attach_twitter_identity(twitter_id: String, auth_token: String, secret: String) -> Dictionary:
	return await _attach(twitter_id, auth_token + ":" + secret, AuthenticationType.TWITTER)

## Detaches the Twitter identity from the current profile.
##
## Service Name - Identity[br]
## Service Operation - Detach
##
## @param twitter_id The Twitter id of the user
## @param cont_as_anon Proceed even if the profile will revert to anonymous?
func detach_twitter_identity(twitter_id: String, cont_as_anon: bool) -> Dictionary:
	return await _detach(twitter_id, AuthenticationType.TWITTER, cont_as_anon)

## Merges the profile associated with the provided Twitter credentials with the current profile.
##
## Service Name - Identity[br]
## Service Operation - Merge
##
## @param twitter_id The Twitter id of the user
## @param auth_token The authentication token derived from the Twitter APIs
## @param secret The secret given when attempting to link with Twitter
func merge_twitter_identity(twitter_id: String, auth_token: String, secret: String) -> Dictionary:
	return await _merge(twitter_id, auth_token + ":" + secret, AuthenticationType.TWITTER)

## Attaches a Parse identity to the current profile.
##
## Service Name - Identity[br]
## Service Operation - Attach
##
## @param parse_id The Parse id of the user
## @param auth_token The validated token from Parse
func attach_parse_identity(parse_id: String, auth_token: String) -> Dictionary:
	return await _attach(parse_id, auth_token, AuthenticationType.PARSE)

## Detaches the Parse identity from the current profile.
##
## Service Name - Identity[br]
## Service Operation - Detach
##
## @param parse_id The Parse id of the user
## @param cont_as_anon Proceed even if the profile will revert to anonymous?
func detach_parse_identity(parse_id: String, cont_as_anon: bool) -> Dictionary:
	return await _detach(parse_id, AuthenticationType.PARSE, cont_as_anon)

## Merges the profile associated with the provided Parse credentials with the current profile.
##
## Service Name - Identity[br]
## Service Operation - Merge
##
## @param parse_id The Parse id of the user
## @param auth_token The validated token from Parse
func merge_parse_identity(parse_id: String, auth_token: String) -> Dictionary:
	return await _merge(parse_id, auth_token, AuthenticationType.PARSE)

## Attaches the given blockchain public key identity to the current profile.
##
## Service Name - Identity[br]
## Service Operation - AttachBlockchainIdentity
##
## @param integration_id The blockchain integration configuration id
## @param public_key The blockchain public key
func attach_blockchain_identity(integration_id: String, public_key: String) -> Dictionary:
	var data := {
		OperationParam.BLOCK_CHAIN_INTEGRATION_ID: integration_id,
		OperationParam.PUBLIC_KEY: public_key
	}
	return await _send(ServiceOperation.ATTACH_BLOCKCHAIN_IDENTITY, data)

## Detaches the blockchain identity from the current profile.
##
## Service Name - Identity[br]
## Service Operation - DetachBlockchainIdentity
##
## @param integration_id The blockchain integration configuration id
func detach_blockchain_identity(integration_id: String) -> Dictionary:
	var data := {
		OperationParam.BLOCK_CHAIN_INTEGRATION_ID: integration_id
	}
	return await _send(ServiceOperation.DETACH_BLOCKCHAIN_IDENTITY, data)

## Attaches a Universal ID to the current profile with no login capability.
##
## Service Name - Identity[br]
## Service Operation - AttachNonLoginUniversalId
##
## @param external_id The Universal ID to attach
func attach_nonlogin_universal_id(external_id: String) -> Dictionary:
	var data := {
		OperationParam.IDENTITY_SERVICE_EXTERNAL_ID: external_id
	}
	return await _send(ServiceOperation.ATTACH_NONLOGIN_UNIVERSAL, data)

## Updates the Universal ID login of the current profile.
##
## Service Name - Identity[br]
## Service Operation - UpdateUniversalIdLogin
##
## @param external_id The new Universal ID to use for login
func update_universal_id_login(external_id: String) -> Dictionary:
	var data := {
		OperationParam.IDENTITY_SERVICE_EXTERNAL_ID: external_id
	}
	return await _send(ServiceOperation.UPDATE_UNIVERSAL_LOGIN, data)

## Attaches a new identity to a parent app.
##
## Service Name - Identity[br]
## Service Operation - AttachParentWithIdentity
##
## @param external_id The user's id for the new credentials
## @param auth_token The password or token
## @param auth_type The type of identity
## @param external_auth_name Optional - if attaching an external identity
## @param force_create Should a new profile be created if it does not exist?
func attach_parent_with_identity(external_id: String, auth_token: String, auth_type: String, external_auth_name: String, force_create: bool) -> Dictionary:
	var data := {
		OperationParam.IDENTITY_SERVICE_EXTERNAL_ID: external_id,
		OperationParam.IDENTITY_SERVICE_AUTHENTICATION_TOKEN: auth_token,
		OperationParam.IDENTITY_SERVICE_AUTHENTICATION_TYPE: auth_type,
		OperationParam.IDENTITY_SERVICE_EXTERNAL_AUTH_NAME: external_auth_name,
		OperationParam.IDENTITY_SERVICE_FORCE_CREATE: force_create
	}
	return await _send(ServiceOperation.ATTACH_PARENT_WITH_IDENTITY, data)

## Detaches the parent from this user's profile.
##
## Service Name - Identity[br]
## Service Operation - DetachParent
func detach_parent() -> Dictionary:
	return await _send(ServiceOperation.DETACH_PARENT, {})

## Switches to a child profile.
##
## Service Name - Identity[br]
## Service Operation - SwitchToChildProfile
##
## @param child_profile_id The profileId of the child profile to switch to
## @param child_app_id The appId of the child app to switch to
## @param force_create Should a new profile be created if it does not exist?
func switch_to_child_profile(child_profile_id: String, child_app_id: String, force_create: bool) -> Dictionary:
	var data := {
		OperationParam.PROFILE_ID: child_profile_id,
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_GAME_ID: child_app_id,
		OperationParam.IDENTITY_SERVICE_FORCE_CREATE: force_create
	}
	return await _send(ServiceOperation.SWITCH_TO_CHILD_PROFILE, data)

## Switches to a child profile of an app when only one profile exists.
## Returns an error if multiple profiles exist.
##
## Service Name - Identity[br]
## Service Operation - SwitchToChildProfile
##
## @param child_app_id The App ID of the child app to switch to
## @param force_create Should a new profile be created if it does not exist?
func switch_to_singleton_child_profile(child_app_id: String, force_create: bool) -> Dictionary:
	var data := {
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_GAME_ID: child_app_id,
		OperationParam.IDENTITY_SERVICE_FORCE_CREATE: force_create
	}
	return await _send(ServiceOperation.SWITCH_TO_CHILD_PROFILE, data)

## Allows the email identity email address to be changed.
##
## Service Name - Identity[br]
## Service Operation - ChangeEmailIdentity
##
## @param old_email The old email address
## @param password The password for the identity
## @param new_email The new email address
## @param update_contact_email Whether to update the contact email in the profile
func change_email_identity(old_email: String, password: String, new_email: String, update_contact_email: bool) -> Dictionary:
	var data := {
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_EXTERNAL_ID: old_email,
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_AUTHENTICATION_TOKEN: password,
		"updateContactEmail": update_contact_email,
		"newEmailAddress": new_email
	}
	return await _send("CHANGE_EMAIL_IDENTITY", data)

## Retrieves identity status for the given identity type for this profile.
##
## Service Name - Identity[br]
## Service Operation - GetIdentityStatus
##
## @param auth_type The authentication type
## @param external_auth_name Optional external auth name for external identity types
func get_identity_status(auth_type: String, external_auth_name: String) -> Dictionary:
	var data := {
		OperationParam.IDENTITY_SERVICE_AUTHENTICATION_TYPE: auth_type,
		OperationParam.IDENTITY_SERVICE_EXTERNAL_AUTH_NAME: external_auth_name
	}
	return await _send("GET_IDENTITY_STATUS", data)

## Switches to a parent profile.
##
## Service Name - Identity[br]
## Service Operation - SwitchToParentProfile
##
## @param parent_level_name The level of the parent to switch to
func switch_to_parent_profile(parent_level_name: String) -> Dictionary:
	var data := {
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_LEVEL_NAME: parent_level_name
	}
	return await _send(ServiceOperation.SWITCH_TO_PARENT_PROFILE, data)

## Returns a list of all child profiles in child apps.
##
## Service Name - Identity[br]
## Service Operation - GetChildProfiles
##
## @param include_summary_data Whether to return summary friend data along with this call
func get_child_profiles(include_summary_data: bool) -> Dictionary:
	var data := {
		OperationParam.FRIEND_SERVICE_INCLUDE_SUMMARY_DATA: include_summary_data
	}
	return await _send(ServiceOperation.GET_CHILDREN_ENTITIES, data)

## Retrieves a list of all identities attached to the current profile.
##
## Service Name - Identity[br]
## Service Operation - GetIdentities
func get_identities() -> Dictionary:
	return await _send(ServiceOperation.GET_IDENTITIES, {})

## Retrieves a list of expired identities for this profile.
##
## Service Name - Identity[br]
## Service Operation - GetExpiredIdentities
func get_expired_identities() -> Dictionary:
	return await _send("GET_EXPIRED_IDENTITIES", {})

## Refreshes an identity for this user.
##
## Service Name - Identity[br]
## Service Operation - RefreshIdentity
##
## @param external_id The user ID for the identity
## @param auth_token The password or client side token
## @param auth_type The type of authentication
func refresh_identity(external_id: String, auth_token: String, auth_type: String) -> Dictionary:
	var data := {
		OperationParam.IDENTITY_SERVICE_EXTERNAL_ID: external_id,
		OperationParam.IDENTITY_SERVICE_AUTHENTICATION_TOKEN: auth_token,
		OperationParam.IDENTITY_SERVICE_AUTHENTICATION_TYPE: auth_type
	}
	return await _send("REFRESH_IDENTITY", data)

## Attaches a peer identity to this user's profile.
##
## Service Name - Identity[br]
## Service Operation - AttachPeerProfile
##
## @param peer_code The name of the peer to connect to
## @param external_id The user's id for the new credentials
## @param auth_token The password or token
## @param auth_type The type of identity
## @param external_auth_name Optional - if attaching an external identity
## @param force_create Should a new profile be created if it does not exist?
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

## Detaches a peer identity from this user's profile.
##
## Service Name - Identity[br]
## Service Operation - DetachPeer
##
## @param peer_code The name of the peer to disconnect from
func detach_peer(peer_code: String) -> Dictionary:
	var data := {
		OperationParam.AUTHENTICATE_SERVICE_AUTHENTICATE_PEER_CODE: peer_code
	}
	return await _send(ServiceOperation.DETACH, data)

## Returns a list of peer profiles attached to this user.
##
## Service Name - Identity[br]
## Service Operation - GetPeerProfiles
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
