# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudClient
extends Node

const DEFAULT_SERVER_URL := "https://api.braincloudservers.com/dispatcherv2"
const BRAINCLOUD_VERSION := "5.9.0"

var _app_version: String = ""
var _language_code: String = "en"
var _country_code: String = "US"
var _initialized: bool = false
var _logging_enabled: bool = false
var logging_enabled: bool:
	get: return _logging_enabled

var _comms: BrainCloudComms = null
var comms: BrainCloudComms:
	get: return _comms

var _rtt_comms: BrainCloudRTTComms = null
var _relay_comms: BrainCloudRelayComms = null

# Services
var authentication_service: BrainCloudAuthentication = null
var entity_service: BrainCloudEntity = null
var global_entity_service: BrainCloudGlobalEntity = null
var global_app_service: BrainCloudGlobalApp = null
var presence_service: BrainCloudPresence = null
var virtual_currency_service: BrainCloudVirtualCurrency = null
var app_store_service: BrainCloudAppStore = null
var player_statistics_service: BrainCloudPlayerStatistics = null
var global_statistics_service: BrainCloudGlobalStatistics = null
var identity_service: BrainCloudIdentity = null
var item_catalog_service: BrainCloudItemCatalog = null
var user_items_service: BrainCloudUserItems = null
var script_service: BrainCloudScript = null
var campaign_service: BrainCloudCampaign = null
var match_making_service: BrainCloudMatchMaking = null
var one_way_match_service: BrainCloudOneWayMatch = null
var playback_stream_service: BrainCloudPlaybackStream = null
var gamification_service: BrainCloudGamification = null
var player_state_service: BrainCloudPlayerState = null
var friend_service: BrainCloudFriend = null
var event_service: BrainCloudEvent = null
var leaderboard_service: BrainCloudSocialLeaderboard = null
var social_leaderboard_service: BrainCloudSocialLeaderboard = null
var async_match_service: BrainCloudAsyncMatch = null
var time_service: BrainCloudTime = null
var tournament_service: BrainCloudTournament = null
var global_file_service: BrainCloudGlobalFile = null
var custom_entity_service: BrainCloudCustomEntity = null
var push_notification_service: BrainCloudPushNotification = null
var player_statistics_event_service: BrainCloudPlayerStatisticsEvent = null
var redemption_code_service: BrainCloudRedemptionCode = null
var data_stream_service: BrainCloudDataStream = null
var profanity_service: BrainCloudProfanity = null
var file_service: BrainCloudFile = null
var group_service: BrainCloudGroup = null
var mail_service: BrainCloudMail = null
var messaging_service: BrainCloudMessaging = null
var blockchain_service: BrainCloudBlockchain = null
var group_file_service: BrainCloudGroupFile = null
var lobby_service: BrainCloudLobby = null
var chat_service: BrainCloudChat = null
var rtt_service: BrainCloudRTT = null
var relay_service: BrainCloudRelay = null

func _ready() -> void:
	_init_services()

func _init_services() -> void:
	_comms = BrainCloudComms.new(self)
	add_child(_comms)

	_rtt_comms = BrainCloudRTTComms.new(self)
	add_child(_rtt_comms)

	_relay_comms = BrainCloudRelayComms.new(self)
	add_child(_relay_comms)

	authentication_service = BrainCloudAuthentication.new(self)
	entity_service = BrainCloudEntity.new(self)
	global_entity_service = BrainCloudGlobalEntity.new(self)
	global_app_service = BrainCloudGlobalApp.new(self)
	presence_service = BrainCloudPresence.new(self)
	virtual_currency_service = BrainCloudVirtualCurrency.new(self)
	app_store_service = BrainCloudAppStore.new(self)
	player_statistics_service = BrainCloudPlayerStatistics.new(self)
	global_statistics_service = BrainCloudGlobalStatistics.new(self)
	identity_service = BrainCloudIdentity.new(self)
	item_catalog_service = BrainCloudItemCatalog.new(self)
	user_items_service = BrainCloudUserItems.new(self)
	script_service = BrainCloudScript.new(self)
	campaign_service = BrainCloudCampaign.new(self)
	match_making_service = BrainCloudMatchMaking.new(self)
	one_way_match_service = BrainCloudOneWayMatch.new(self)
	playback_stream_service = BrainCloudPlaybackStream.new(self)
	gamification_service = BrainCloudGamification.new(self)
	player_state_service = BrainCloudPlayerState.new(self)
	friend_service = BrainCloudFriend.new(self)
	event_service = BrainCloudEvent.new(self)
	leaderboard_service = BrainCloudSocialLeaderboard.new(self)
	social_leaderboard_service = leaderboard_service
	async_match_service = BrainCloudAsyncMatch.new(self)
	time_service = BrainCloudTime.new(self)
	tournament_service = BrainCloudTournament.new(self)
	global_file_service = BrainCloudGlobalFile.new(self)
	custom_entity_service = BrainCloudCustomEntity.new(self)
	push_notification_service = BrainCloudPushNotification.new(self)
	player_statistics_event_service = BrainCloudPlayerStatisticsEvent.new(self)
	redemption_code_service = BrainCloudRedemptionCode.new(self)
	data_stream_service = BrainCloudDataStream.new(self)
	profanity_service = BrainCloudProfanity.new(self)
	file_service = BrainCloudFile.new(self)
	group_service = BrainCloudGroup.new(self)
	mail_service = BrainCloudMail.new(self)
	messaging_service = BrainCloudMessaging.new(self)
	blockchain_service = BrainCloudBlockchain.new(self)
	group_file_service = BrainCloudGroupFile.new(self)
	lobby_service = BrainCloudLobby.new(self)
	chat_service = BrainCloudChat.new(self)
	rtt_service = BrainCloudRTT.new(self, _rtt_comms)
	relay_service = BrainCloudRelay.new(self, _relay_comms)

func initialize(secret_key: String, app_id: String, app_version: String, server_url: String = DEFAULT_SERVER_URL) -> void:
	var error := _initialize_helper(server_url, secret_key, app_id, app_version)
	if error.length() > 0:
		push_error("BrainCloud initialize error: " + error)
		return
	_comms.initialize(server_url, app_id, secret_key)
	_initialized = true

func initialize_with_apps(default_app_id: String, app_id_secret_map: Dictionary, app_version: String, server_url: String = DEFAULT_SERVER_URL) -> void:
	var error := _initialize_helper(server_url, app_id_secret_map.get(default_app_id, ""), default_app_id, app_version)
	if error.length() > 0:
		push_error("BrainCloud initialize error: " + error)
		return
	_comms.initialize_with_apps(server_url, default_app_id, app_id_secret_map)
	_initialized = true

func initialize_identity(profile_id: String, anonymous_id: String) -> void:
	authentication_service.initialize(profile_id, anonymous_id)

func _initialize_helper(server_url: String, secret_key: String, app_id: String, app_version: String) -> String:
	if server_url.length() == 0:
		return "serverURL was empty"
	if secret_key.length() == 0:
		return "secretKey was empty"
	if app_id.length() == 0:
		return "appId was empty"
	if app_version.length() == 0:
		return "appVersion was empty"
	_app_version = app_version
	_language_code = OS.get_locale_language()
	_country_code = OS.get_locale().split("_")[-1] if "_" in OS.get_locale() else "US"
	return ""

func is_initialized() -> bool:
	return _initialized

func is_authenticated() -> bool:
	return _comms.get_is_authenticated()

func get_authenticated() -> bool:
	return _comms.get_is_authenticated()

func get_session_id() -> String:
	return _comms.get_session_id()

func get_app_id() -> String:
	return _comms.get_app_id()

func get_profile_id() -> String:
	return authentication_service.profile_id

func get_app_version() -> String:
	return _app_version

func get_braincloud_version() -> String:
	return BRAINCLOUD_VERSION

func get_release_platform() -> String:
	return Platform.get_platform_name()

func get_language_code() -> String:
	return _language_code

func set_language_code(code: String) -> void:
	_language_code = code

func get_country_code() -> String:
	return _country_code

func set_country_code(code: String) -> void:
	_country_code = code

func enable_logging(enable: bool) -> void:
	_logging_enabled = enable

func log(message: String) -> void:
	if _logging_enabled:
		var time_str := Time.get_time_string_from_system()
		print("[%s] #BCC %s" % [time_str, message.substr(0, min(message.length(), 14000))])

func enable_communications(value: bool) -> void:
	_comms.enable_comms(value)

func reset_communication() -> void:
	_comms.reset_communication()
	authentication_service.clear_saved_profile_id()

func shut_down() -> void:
	_comms.shut_down()

func send_request(server_call: ServerCall) -> void:
	_comms.add_to_queue(server_call)

func set_packet_timeouts(timeouts: Array[int]) -> void:
	_comms.packet_timeouts = timeouts

func set_packet_timeouts_to_default() -> void:
	_comms.set_packet_timeouts_to_default()

func get_packet_timeouts() -> Array[int]:
	return _comms.packet_timeouts

func set_authentication_packet_timeout(timeout_secs: int) -> void:
	_comms._authentication_packet_timeout_secs = float(timeout_secs)

func get_authentication_packet_timeout() -> int:
	return int(_comms._authentication_packet_timeout_secs)

func enable_network_error_message_caching(enabled: bool) -> void:
	_comms.enable_network_error_message_caching(enabled)

func retry_cached_messages() -> void:
	_comms.retry_cached_messages()

func flush_cached_messages(send_api_error_callbacks: bool) -> void:
	_comms.flush_cached_messages(send_api_error_callbacks)

func insert_end_of_message_bundle_marker() -> void:
	_comms.insert_end_of_bundle_marker()

func override_country_code(country_code: String) -> void:
	_country_code = country_code

func override_language_code(language_code: String) -> void:
	_language_code = language_code

func register_event_callback(cb: Callable) -> void:
	_comms.register_event_callback(cb)

func deregister_event_callback() -> void:
	_comms.deregister_event_callback()

func register_reward_callback(cb: Callable) -> void:
	_comms.register_reward_callback(cb)

func deregister_reward_callback() -> void:
	_comms.deregister_reward_callback()

func register_global_error_callback(cb: Callable) -> void:
	_comms.register_global_error_callback(cb)

func deregister_global_error_callback() -> void:
	_comms.deregister_global_error_callback()

func register_network_error_callback(cb: Callable) -> void:
	_comms.register_network_error_callback(cb)

func deregister_network_error_callback() -> void:
	_comms.deregister_network_error_callback()

func register_auto_reconnect_callback(cb: Callable) -> void:
	_comms.register_auto_reconnect_callback(cb)

func deregister_auto_reconnect_callback() -> void:
	_comms.deregister_auto_reconnect_callback()

func get_received_packet_id() -> int:
	return _comms.get_received_packet_id()

func get_url() -> String:
	return _comms.get_server_url()

func send_heartbeat() -> Dictionary:
	var sc := ServerCall.new(ServiceName.HEART_BEAT, ServiceOperation.READ, {})
	_comms.add_to_queue(sc)
	var response: Dictionary = await sc.response_received
	return response
