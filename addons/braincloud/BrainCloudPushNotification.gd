# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudPushNotification
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

func deregister_all_push_notification_device_tokens() -> Dictionary:
	return await _send(ServiceOperation.DEREGISTER_ALL, {})

func deregister_push_notification_device_token(device_type: String, device_token: String) -> Dictionary:
	var data := {
		OperationParam.PUSH_NOTIFICATION_REGISTER_PARAM_DEVICE_TYPE: device_type,
		OperationParam.PUSH_NOTIFICATION_REGISTER_PARAM_DEVICE_TOKEN: device_token
	}
	return await _send(ServiceOperation.DEREGISTER, data)

func register_push_notification_device_token(device_type: String, device_token: String) -> Dictionary:
	var data := {
		OperationParam.PUSH_NOTIFICATION_REGISTER_PARAM_DEVICE_TYPE: device_type,
		OperationParam.PUSH_NOTIFICATION_REGISTER_PARAM_DEVICE_TOKEN: device_token
	}
	return await _send(ServiceOperation.REGISTER, data)

func send_simple_push_notification(to_profile_id: String, message: String) -> Dictionary:
	var data := {
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_TO_PLAYER_ID: to_profile_id,
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_MESSAGE: message
	}
	return await _send(ServiceOperation.SEND_SIMPLE, data)

func send_rich_push_notification(to_profile_id: String, notification_template_id: int) -> Dictionary:
	var data := {
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_TO_PLAYER_ID: to_profile_id,
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_NOTIFICATION_TEMPLATE_ID: notification_template_id
	}
	return await _send(ServiceOperation.SEND_RICH, data)

func send_raw_push_notification(to_profile_id: String, fcm_content: Dictionary, ios_content: Dictionary, facebook_content: Dictionary) -> Dictionary:
	var data := {
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_TO_PLAYER_ID: to_profile_id,
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_FCM_CONTENT: fcm_content,
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_IOS_CONTENT: ios_content,
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_FACEBOOK_CONTENT: facebook_content
	}
	return await _send(ServiceOperation.SEND_RAW, data)

func send_raw_push_notification_batch(profile_ids: Array, fcm_content: Dictionary, ios_content: Dictionary, facebook_content: Dictionary) -> Dictionary:
	var data := {
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_PROFILE_IDS: profile_ids,
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_FCM_CONTENT: fcm_content,
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_IOS_CONTENT: ios_content,
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_FACEBOOK_CONTENT: facebook_content
	}
	return await _send(ServiceOperation.SEND_RAW_BATCH, data)

func send_raw_push_notification_to_group(group_id: String, fcm_content: Dictionary, ios_content: Dictionary, facebook_content: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GROUP_ID: group_id,
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_FCM_CONTENT: fcm_content,
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_IOS_CONTENT: ios_content,
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_FACEBOOK_CONTENT: facebook_content
	}
	return await _send(ServiceOperation.SEND_RAW_TO_GROUP, data)

func send_templated_push_notification_to_group(group_id: String, notification_template_id: int, substitutions: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GROUP_ID: group_id,
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_NOTIFICATION_TEMPLATE_ID: notification_template_id,
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_SUBSTITUTIONS: substitutions
	}
	return await _send(ServiceOperation.SEND_TEMPLATED_TO_GROUP, data)

func send_normalized_push_notification(to_profile_id: String, alert_content: Dictionary, custom_data: Dictionary) -> Dictionary:
	var data := {
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_TO_PLAYER_ID: to_profile_id,
		OperationParam.ALERT_CONTENT: alert_content,
		OperationParam.CUSTOM_DATA: custom_data
	}
	return await _send(ServiceOperation.SEND_NORMALIZED, data)

func send_normalized_push_notification_batch(profile_ids: Array, alert_content: Dictionary, custom_data: Dictionary) -> Dictionary:
	var data := {
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_PROFILE_IDS: profile_ids,
		OperationParam.ALERT_CONTENT: alert_content,
		OperationParam.CUSTOM_DATA: custom_data
	}
	return await _send(ServiceOperation.SEND_NORMALIZED_BATCH, data)

func send_normalized_push_notification_to_group(group_id: String, alert_content: Dictionary, custom_data: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GROUP_ID: group_id,
		OperationParam.ALERT_CONTENT: alert_content,
		OperationParam.CUSTOM_DATA: custom_data
	}
	return await _send(ServiceOperation.SEND_NORMALIZED_TO_GROUP, data)

func schedule_raw_push_notification_utc(profile_id: String, fcm_content: Dictionary, ios_content: Dictionary, facebook_content: Dictionary, start_date_utc: int) -> Dictionary:
	var data := {
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_PROFILE_ID: profile_id,
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_FCM_CONTENT: fcm_content,
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_IOS_CONTENT: ios_content,
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_FACEBOOK_CONTENT: facebook_content,
		OperationParam.START_DATE_UTC: start_date_utc
	}
	return await _send(ServiceOperation.SCHEDULE_RAW_NOTIFICATION, data)

func schedule_raw_push_notification_minutes(profile_id: String, fcm_content: Dictionary, ios_content: Dictionary, facebook_content: Dictionary, minutes_from_now: int) -> Dictionary:
	var data := {
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_PROFILE_ID: profile_id,
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_FCM_CONTENT: fcm_content,
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_IOS_CONTENT: ios_content,
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_FACEBOOK_CONTENT: facebook_content,
		OperationParam.MINUTES_FROM_NOW: minutes_from_now
	}
	return await _send(ServiceOperation.SCHEDULE_RAW_NOTIFICATION, data)

func schedule_normalized_push_notification_utc(profile_id: String, alert_content: Dictionary, custom_data: Dictionary, start_date_utc: int) -> Dictionary:
	var data := {
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_PROFILE_ID: profile_id,
		OperationParam.ALERT_CONTENT: alert_content,
		OperationParam.CUSTOM_DATA: custom_data,
		OperationParam.START_DATE_UTC: start_date_utc
	}
	return await _send(ServiceOperation.SCHEDULE_NORMALIZED_NOTIFICATION, data)

func schedule_normalized_push_notification_minutes(profile_id: String, alert_content: Dictionary, custom_data: Dictionary, minutes_from_now: int) -> Dictionary:
	var data := {
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_PROFILE_ID: profile_id,
		OperationParam.ALERT_CONTENT: alert_content,
		OperationParam.CUSTOM_DATA: custom_data,
		OperationParam.MINUTES_FROM_NOW: minutes_from_now
	}
	return await _send(ServiceOperation.SCHEDULE_NORMALIZED_NOTIFICATION, data)

func schedule_rich_push_notification_utc(profile_id: String, notification_template_id: int, substitutions: Dictionary, start_date_utc: int) -> Dictionary:
	var data := {
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_PROFILE_ID: profile_id,
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_NOTIFICATION_TEMPLATE_ID: notification_template_id,
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_SUBSTITUTIONS: substitutions,
		OperationParam.START_DATE_UTC: start_date_utc
	}
	return await _send(ServiceOperation.SCHEDULE_RICH_NOTIFICATION, data)

func schedule_rich_push_notification_minutes(profile_id: String, notification_template_id: int, substitutions: Dictionary, minutes_from_now: int) -> Dictionary:
	var data := {
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_PROFILE_ID: profile_id,
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_NOTIFICATION_TEMPLATE_ID: notification_template_id,
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_SUBSTITUTIONS: substitutions,
		OperationParam.MINUTES_FROM_NOW: minutes_from_now
	}
	return await _send(ServiceOperation.SCHEDULE_RICH_NOTIFICATION, data)

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.PUSH_NOTIFICATION, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
