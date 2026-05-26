# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudWrapper
extends Node

const PREFS_PROFILE_ID := "brainCloud.profileId"
const PREFS_ANONYMOUS_ID := "brainCloud.anonymousId"
const PREFS_AUTHENTICATION_TYPE := "brainCloud.authenticationType"
const PREFS_EXTERNAL_ID := "brainCloud.externalId"
const PREFS_AUTH_TOKEN := "brainCloud.authToken"
const PREFS_LAST_PACKET_ID := "brainCloud.lastPacketId"
const _CREDS_PATH := "res://addons/braincloud/braincloud.cfg"

var _client: BrainCloudClient = null
var braincloud_client: BrainCloudClient:
	get: return _client

var _always_allow_profile_switch: bool = true
var always_allow_profile_switch: bool:
	get: return _always_allow_profile_switch
	set(v): _always_allow_profile_switch = v

var _last_url: String = ""
var _last_secret_key: String = ""
var _last_app_id: String = ""
var _last_app_version: String = ""
var wrapper_name: String = ""

# Expose services through wrapper
var authentication_service: BrainCloudAuthentication:
	get: return _client.authentication_service
var entity_service: BrainCloudEntity:
	get: return _client.entity_service
var global_entity_service: BrainCloudGlobalEntity:
	get: return _client.global_entity_service
var global_app_service: BrainCloudGlobalApp:
	get: return _client.global_app_service
var virtual_currency_service: BrainCloudVirtualCurrency:
	get: return _client.virtual_currency_service
var app_store_service: BrainCloudAppStore:
	get: return _client.app_store_service
var player_statistics_service: BrainCloudPlayerStatistics:
	get: return _client.player_statistics_service
var global_statistics_service: BrainCloudGlobalStatistics:
	get: return _client.global_statistics_service
var identity_service: BrainCloudIdentity:
	get: return _client.identity_service
var item_catalog_service: BrainCloudItemCatalog:
	get: return _client.item_catalog_service
var user_items_service: BrainCloudUserItems:
	get: return _client.user_items_service
var script_service: BrainCloudScript:
	get: return _client.script_service
var campaign_service: BrainCloudCampaign:
	get: return _client.campaign_service
var match_making_service: BrainCloudMatchMaking:
	get: return _client.match_making_service
var one_way_match_service: BrainCloudOneWayMatch:
	get: return _client.one_way_match_service
var playback_stream_service: BrainCloudPlaybackStream:
	get: return _client.playback_stream_service
var presence_service: BrainCloudPresence:
	get: return _client.presence_service
var gamification_service: BrainCloudGamification:
	get: return _client.gamification_service
var player_state_service: BrainCloudPlayerState:
	get: return _client.player_state_service
var friend_service: BrainCloudFriend:
	get: return _client.friend_service
var event_service: BrainCloudEvent:
	get: return _client.event_service
var social_leaderboard_service: BrainCloudSocialLeaderboard:
	get: return _client.leaderboard_service
var leaderboard_service: BrainCloudSocialLeaderboard:
	get: return _client.leaderboard_service
var async_match_service: BrainCloudAsyncMatch:
	get: return _client.async_match_service
var time_service: BrainCloudTime:
	get: return _client.time_service
var tournament_service: BrainCloudTournament:
	get: return _client.tournament_service
var global_file_service: BrainCloudGlobalFile:
	get: return _client.global_file_service
var custom_entity_service: BrainCloudCustomEntity:
	get: return _client.custom_entity_service
var push_notification_service: BrainCloudPushNotification:
	get: return _client.push_notification_service
var player_statistics_event_service: BrainCloudPlayerStatisticsEvent:
	get: return _client.player_statistics_event_service
var redemption_code_service: BrainCloudRedemptionCode:
	get: return _client.redemption_code_service
var data_stream_service: BrainCloudDataStream:
	get: return _client.data_stream_service
var profanity_service: BrainCloudProfanity:
	get: return _client.profanity_service
var file_service: BrainCloudFile:
	get: return _client.file_service
var group_service: BrainCloudGroup:
	get: return _client.group_service
var mail_service: BrainCloudMail:
	get: return _client.mail_service
var messaging_service: BrainCloudMessaging:
	get: return _client.messaging_service
var blockchain_service: BrainCloudBlockchain:
	get: return _client.blockchain_service
var group_file_service: BrainCloudGroupFile:
	get: return _client.group_file_service
var lobby_service: BrainCloudLobby:
	get: return _client.lobby_service
var chat_service: BrainCloudChat:
	get: return _client.chat_service
var rtt_service: BrainCloudRTT:
	get: return _client.rtt_service
var relay_service: BrainCloudRelay:
	get: return _client.relay_service

func _ready() -> void:
	_client = BrainCloudClient.new()
	add_child(_client)
	_auto_init_from_project_settings()


func _auto_init_from_project_settings() -> void:
	# Credentials come from the gitignored braincloud.cfg, with a fallback to
	# project.godot for projects that haven't migrated yet.
	var app_id     := ""
	var app_secret := ""
	var creds := ConfigFile.new()
	if creds.load(_CREDS_PATH) == OK:
		app_id     = str(creds.get_value("credentials", "app_id",     ""))
		app_secret = str(creds.get_value("credentials", "app_secret", ""))
	if app_id.is_empty():
		app_id = ProjectSettings.get_setting("braincloud/config/app_id", "")
	if app_secret.is_empty():
		app_secret = ProjectSettings.get_setting("braincloud/config/app_secret", "")
	if app_id.is_empty() or app_secret.is_empty():
		return
	var app_version: String = ProjectSettings.get_setting("braincloud/config/app_version", "1.0.0")
	var server_url: String  = ProjectSettings.get_setting("braincloud/config/server_url", BrainCloudClient.DEFAULT_SERVER_URL)
	var enable_logging: bool = ProjectSettings.get_setting("braincloud/debug/enable_logging", false)
	_client.enable_logging(enable_logging)
	init(app_secret, app_id, app_version, server_url)

func is_initialized() -> bool:
	return _client.is_initialized()

func init(secret_key: String, app_id: String, version: String, url: String = BrainCloudClient.DEFAULT_SERVER_URL) -> void:
	_last_url = url
	_last_secret_key = secret_key
	_last_app_id = app_id
	_last_app_version = version
	_client.initialize(secret_key, app_id, version, url)

func init_with_apps(app_id_secret_map: Dictionary, default_app_id: String, version: String, url: String = BrainCloudClient.DEFAULT_SERVER_URL) -> void:
	_last_url = url
	_last_app_id = default_app_id
	_last_app_version = version
	_client.initialize_with_apps(default_app_id, app_id_secret_map, version, url)

func get_stored_profile_id() -> String:
	return _load_pref(PREFS_PROFILE_ID)

func get_stored_anonymous_id() -> String:
	return _load_pref(PREFS_ANONYMOUS_ID)

func get_stored_authentication_type() -> String:
	return _load_pref(PREFS_AUTHENTICATION_TYPE)

func set_stored_profile_id(profile_id: String) -> void:
	_save_pref(PREFS_PROFILE_ID, profile_id)

func set_stored_anonymous_id(anonymous_id: String) -> void:
	_save_pref(PREFS_ANONYMOUS_ID, anonymous_id)

func set_stored_authentication_type(auth_type: String) -> void:
	_save_pref(PREFS_AUTHENTICATION_TYPE, auth_type)

func reset_stored_profile_id() -> void:
	_save_pref(PREFS_PROFILE_ID, "")

func reset_stored_anonymous_id() -> void:
	_save_pref(PREFS_ANONYMOUS_ID, "")

func _load_pref(key: String) -> String:
	var section := "brainCloud" + wrapper_name
	if not ProjectSettings.has_setting(section + "/" + key):
		return ""
	return str(ProjectSettings.get_setting(section + "/" + key, ""))

func _save_pref(key: String, value: String) -> void:
	var section := "brainCloud" + wrapper_name
	ProjectSettings.set_setting(section + "/" + key, value)

func authenticate_anonymous(force_create: bool = true) -> Dictionary:
	var anonymous_id := get_stored_anonymous_id()
	var profile_id := get_stored_profile_id()

	if anonymous_id.length() == 0:
		anonymous_id = _client.authentication_service.generate_anonymous_id()
		set_stored_anonymous_id(anonymous_id)

	_client.initialize_identity(profile_id, anonymous_id)
	set_stored_authentication_type(AuthenticationType.ANONYMOUS)

	var response := await _client.authentication_service.authenticate_anonymous(force_create)
	if response.get("status", 0) == StatusCodes.OK:
		_on_authenticated(response)
	return response

func authenticate_email_password(email: String, password: String, force_create: bool) -> Dictionary:
	_init_profile_for_authenticate()
	set_stored_authentication_type(AuthenticationType.EMAIL)
	_save_pref(PREFS_EXTERNAL_ID, email)
	_save_pref(PREFS_AUTH_TOKEN, password)
	var response := await _client.authentication_service.authenticate_email_password(email, password, force_create)
	if response.get("status", 0) == StatusCodes.OK:
		_on_authenticated(response)
	return response

func authenticate_universal(username: String, password: String, force_create: bool) -> Dictionary:
	_init_profile_for_authenticate()
	set_stored_authentication_type(AuthenticationType.UNIVERSAL)
	_save_pref(PREFS_EXTERNAL_ID, username)
	_save_pref(PREFS_AUTH_TOKEN, password)
	var response := await _client.authentication_service.authenticate_universal(username, password, force_create)
	if response.get("status", 0) == StatusCodes.OK:
		_on_authenticated(response)
	return response

func authenticate_google(google_user_id: String, server_auth_code: String, force_create: bool) -> Dictionary:
	_init_profile_for_authenticate()
	set_stored_authentication_type(AuthenticationType.GOOGLE)
	var response := await _client.authentication_service.authenticate_google(google_user_id, server_auth_code, force_create)
	if response.get("status", 0) == StatusCodes.OK:
		_on_authenticated(response)
	return response

func authenticate_apple(apple_user_id: String, identity_token: String, force_create: bool) -> Dictionary:
	_init_profile_for_authenticate()
	set_stored_authentication_type(AuthenticationType.APPLE)
	var response := await _client.authentication_service.authenticate_apple(apple_user_id, identity_token, force_create)
	if response.get("status", 0) == StatusCodes.OK:
		_on_authenticated(response)
	return response

func authenticate_facebook(facebook_id: String, token: String, force_create: bool) -> Dictionary:
	_init_profile_for_authenticate()
	set_stored_authentication_type(AuthenticationType.FACEBOOK)
	var response := await _client.authentication_service.authenticate_facebook(facebook_id, token, force_create)
	if response.get("status", 0) == StatusCodes.OK:
		_on_authenticated(response)
	return response

func authenticate_steam(steam_id: String, session_ticket: String, force_create: bool) -> Dictionary:
	_init_profile_for_authenticate()
	set_stored_authentication_type(AuthenticationType.STEAM)
	var response := await _client.authentication_service.authenticate_steam(steam_id, session_ticket, force_create)
	if response.get("status", 0) == StatusCodes.OK:
		_on_authenticated(response)
	return response

func reauthenticate() -> Dictionary:
	var auth_type := get_stored_authentication_type()
	if auth_type == AuthenticationType.ANONYMOUS or auth_type.is_empty():
		return await authenticate_anonymous(false)
	var ext_id := _load_pref(PREFS_EXTERNAL_ID)
	var auth_token := _load_pref(PREFS_AUTH_TOKEN)
	if auth_type == AuthenticationType.UNIVERSAL:
		return await authenticate_universal(ext_id, auth_token, false)
	if auth_type == AuthenticationType.EMAIL:
		return await authenticate_email_password(ext_id, auth_token, false)
	push_warning("BrainCloudWrapper.reauthenticate: unsupported auth type '%s'" % auth_type)
	return {"status": StatusCodes.CLIENT_NETWORK_ERROR}

func reconnect() -> Dictionary:
	return await reauthenticate()

func logout(forget_user: bool = false) -> Dictionary:
	var response := await _client.player_state_service.logout()
	if forget_user:
		reset_stored_profile_id()
		reset_stored_anonymous_id()
		set_stored_authentication_type("")
		_save_pref(PREFS_EXTERNAL_ID, "")
		_save_pref(PREFS_AUTH_TOKEN, "")
	return response

func reset_to_default_app() -> void:
	if not _last_app_id.is_empty():
		_client.initialize(_last_secret_key, _last_app_id, _last_app_version, _last_url)

func _on_authenticated(response: Dictionary) -> void:
	var data: Dictionary = response.get("data", {})
	var profile_id: String = data.get("profileId", "")
	if profile_id.length() > 0:
		set_stored_profile_id(profile_id)

func getCampaignService() -> BrainCloudCampaign:
	return campaign_service

func _init_profile_for_authenticate() -> void:
	if _always_allow_profile_switch:
		_client.authentication_service.profile_id = ""
	else:
		_client.authentication_service.profile_id = get_stored_profile_id()
	var anon_id := get_stored_anonymous_id()
	if anon_id.length() == 0:
		anon_id = _client.authentication_service.generate_anonymous_id()
		set_stored_anonymous_id(anon_id)
	_client.authentication_service.anonymous_id = anon_id
