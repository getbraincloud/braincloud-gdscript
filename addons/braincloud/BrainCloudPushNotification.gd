# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudPushNotification
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

## Deregisters all push notification device tokens for the current user.
##
## Service Name - PushNotification[br]
## Service Operation - DeregisterAll
func deregister_all_push_notification_device_tokens() -> Dictionary:
	return await _send(ServiceOperation.DEREGISTER_ALL, {})

## Deregisters a specific push notification device token for the current user.
##
## Service Name - PushNotification[br]
## Service Operation - Deregister
##
## @param device_type The device type (e.g. "IOS", "ANDROID")
## @param device_token The device push token to deregister
func deregister_push_notification_device_token(device_type: String, device_token: String) -> Dictionary:
	var data := {
		OperationParam.PUSH_NOTIFICATION_REGISTER_PARAM_DEVICE_TYPE: device_type,
		OperationParam.PUSH_NOTIFICATION_REGISTER_PARAM_DEVICE_TOKEN: device_token
	}
	return await _send(ServiceOperation.DEREGISTER, data)

## Registers a device token for push notifications for the current user.
##
## Service Name - PushNotification[br]
## Service Operation - Register
##
## @param device_type The device type (e.g. "IOS", "ANDROID")
## @param device_token The device push token to register
func register_push_notification_device_token(device_type: String, device_token: String) -> Dictionary:
	var data := {
		OperationParam.PUSH_NOTIFICATION_REGISTER_PARAM_DEVICE_TYPE: device_type,
		OperationParam.PUSH_NOTIFICATION_REGISTER_PARAM_DEVICE_TOKEN: device_token
	}
	return await _send(ServiceOperation.REGISTER, data)

## Sends a simple push notification message to a user.
##
## Service Name - PushNotification[br]
## Service Operation - SendSimple
##
## @param to_profile_id The profile id of the user to send the notification to
## @param message Text of the notification message
func send_simple_push_notification(to_profile_id: String, message: String) -> Dictionary:
	var data := {
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_TO_PLAYER_ID: to_profile_id,
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_MESSAGE: message
	}
	return await _send(ServiceOperation.SEND_SIMPLE, data)

## Sends a rich push notification message using a template to a user.
##
## Service Name - PushNotification[br]
## Service Operation - SendRich
##
## @param to_profile_id The profile id of the user to send the notification to
## @param notification_template_id The id of the notification template to use
func send_rich_push_notification(to_profile_id: String, notification_template_id: int) -> Dictionary:
	var data := {
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_TO_PLAYER_ID: to_profile_id,
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_NOTIFICATION_TEMPLATE_ID: notification_template_id
	}
	return await _send(ServiceOperation.SEND_RICH, data)

## Sends a raw push notification to a user. Allows sending directly to each platform.
##
## Service Name - PushNotification[br]
## Service Operation - SendRaw
##
## @param to_profile_id The profile id of the user to send the notification to
## @param fcm_content FCM content for Android devices
## @param ios_content APS content for iOS devices
## @param facebook_content Facebook content for Facebook devices
func send_raw_push_notification(to_profile_id: String, fcm_content: Dictionary, ios_content: Dictionary, facebook_content: Dictionary) -> Dictionary:
	var data := {
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_TO_PLAYER_ID: to_profile_id,
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_FCM_CONTENT: fcm_content,
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_IOS_CONTENT: ios_content,
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_FACEBOOK_CONTENT: facebook_content
	}
	return await _send(ServiceOperation.SEND_RAW, data)

## Sends a raw push notification to a list of users.
##
## Service Name - PushNotification[br]
## Service Operation - SendRawBatch
##
## @param profile_ids Collection of profile ids of the users to notify
## @param fcm_content FCM content for Android devices
## @param ios_content APS content for iOS devices
## @param facebook_content Facebook content for Facebook devices
func send_raw_push_notification_batch(profile_ids: Array, fcm_content: Dictionary, ios_content: Dictionary, facebook_content: Dictionary) -> Dictionary:
	var data := {
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_PROFILE_IDS: profile_ids,
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_FCM_CONTENT: fcm_content,
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_IOS_CONTENT: ios_content,
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_FACEBOOK_CONTENT: facebook_content
	}
	return await _send(ServiceOperation.SEND_RAW_BATCH, data)

## Sends a raw push notification to all members of a group.
##
## Service Name - PushNotification[br]
## Service Operation - SendRawToGroup
##
## @param group_id The id of the group to notify
## @param fcm_content FCM content for Android devices
## @param ios_content APS content for iOS devices
## @param facebook_content Facebook content for Facebook devices
func send_raw_push_notification_to_group(group_id: String, fcm_content: Dictionary, ios_content: Dictionary, facebook_content: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GROUP_ID: group_id,
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_FCM_CONTENT: fcm_content,
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_IOS_CONTENT: ios_content,
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_FACEBOOK_CONTENT: facebook_content
	}
	return await _send(ServiceOperation.SEND_RAW_TO_GROUP, data)

## Sends a templated push notification to all members of a group.
##
## Service Name - PushNotification[br]
## Service Operation - SendTemplatedToGroup
##
## @param group_id The id of the group to notify
## @param notification_template_id The id of the notification template to use
## @param substitutions Template substitutions as a Dictionary
func send_templated_push_notification_to_group(group_id: String, notification_template_id: int, substitutions: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GROUP_ID: group_id,
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_NOTIFICATION_TEMPLATE_ID: notification_template_id,
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_SUBSTITUTIONS: substitutions
	}
	return await _send(ServiceOperation.SEND_TEMPLATED_TO_GROUP, data)

## Sends a normalized push notification to a user.
##
## Service Name - PushNotification[br]
## Service Operation - SendNormalized
##
## @param to_profile_id The profile id of the user to send the notification to
## @param alert_content The alert content for the notification
## @param custom_data Custom data to include with the notification
func send_normalized_push_notification(to_profile_id: String, alert_content: Dictionary, custom_data: Dictionary) -> Dictionary:
	var data := {
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_TO_PLAYER_ID: to_profile_id,
		OperationParam.ALERT_CONTENT: alert_content,
		OperationParam.CUSTOM_DATA: custom_data
	}
	return await _send(ServiceOperation.SEND_NORMALIZED, data)

## Sends a normalized push notification to a list of users.
##
## Service Name - PushNotification[br]
## Service Operation - SendNormalizedBatch
##
## @param profile_ids Collection of profile ids of the users to notify
## @param alert_content The alert content for the notification
## @param custom_data Custom data to include with the notification
func send_normalized_push_notification_batch(profile_ids: Array, alert_content: Dictionary, custom_data: Dictionary) -> Dictionary:
	var data := {
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_PROFILE_IDS: profile_ids,
		OperationParam.ALERT_CONTENT: alert_content,
		OperationParam.CUSTOM_DATA: custom_data
	}
	return await _send(ServiceOperation.SEND_NORMALIZED_BATCH, data)

## Sends a normalized push notification to all members of a group.
##
## Service Name - PushNotification[br]
## Service Operation - SendNormalizedToGroup
##
## @param group_id The id of the group to notify
## @param alert_content The alert content for the notification
## @param custom_data Custom data to include with the notification
func send_normalized_push_notification_to_group(group_id: String, alert_content: Dictionary, custom_data: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GROUP_ID: group_id,
		OperationParam.ALERT_CONTENT: alert_content,
		OperationParam.CUSTOM_DATA: custom_data
	}
	return await _send(ServiceOperation.SEND_NORMALIZED_TO_GROUP, data)

## Schedules a raw push notification to a user at a UTC time.
##
## Service Name - PushNotification[br]
## Service Operation - ScheduleRawNotification
##
## @param profile_id The profile id of the user to notify
## @param fcm_content FCM content for Android devices
## @param ios_content APS content for iOS devices
## @param facebook_content Facebook content for Facebook devices
## @param start_date_utc The UTC time at which to send the notification (ms since epoch)
func schedule_raw_push_notification_utc(profile_id: String, fcm_content: Dictionary, ios_content: Dictionary, facebook_content: Dictionary, start_date_utc: int) -> Dictionary:
	var data := {
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_PROFILE_ID: profile_id,
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_FCM_CONTENT: fcm_content,
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_IOS_CONTENT: ios_content,
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_FACEBOOK_CONTENT: facebook_content,
		OperationParam.START_DATE_UTC: start_date_utc
	}
	return await _send(ServiceOperation.SCHEDULE_RAW_NOTIFICATION, data)

## Schedules a raw push notification to a user at a relative time.
##
## Service Name - PushNotification[br]
## Service Operation - ScheduleRawNotification
##
## @param profile_id The profile id of the user to notify
## @param fcm_content FCM content for Android devices
## @param ios_content APS content for iOS devices
## @param facebook_content Facebook content for Facebook devices
## @param minutes_from_now Number of minutes from now to send the notification
func schedule_raw_push_notification_minutes(profile_id: String, fcm_content: Dictionary, ios_content: Dictionary, facebook_content: Dictionary, minutes_from_now: int) -> Dictionary:
	var data := {
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_PROFILE_ID: profile_id,
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_FCM_CONTENT: fcm_content,
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_IOS_CONTENT: ios_content,
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_FACEBOOK_CONTENT: facebook_content,
		OperationParam.MINUTES_FROM_NOW: minutes_from_now
	}
	return await _send(ServiceOperation.SCHEDULE_RAW_NOTIFICATION, data)

## Schedules a normalized push notification to a user at a UTC time.
##
## Service Name - PushNotification[br]
## Service Operation - ScheduleNormalizedNotification
##
## @param profile_id The profile id of the user to notify
## @param alert_content The alert content for the notification
## @param custom_data Custom data to include with the notification
## @param start_date_utc The UTC time at which to send the notification (ms since epoch)
func schedule_normalized_push_notification_utc(profile_id: String, alert_content: Dictionary, custom_data: Dictionary, start_date_utc: int) -> Dictionary:
	var data := {
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_PROFILE_ID: profile_id,
		OperationParam.ALERT_CONTENT: alert_content,
		OperationParam.CUSTOM_DATA: custom_data,
		OperationParam.START_DATE_UTC: start_date_utc
	}
	return await _send(ServiceOperation.SCHEDULE_NORMALIZED_NOTIFICATION, data)

## Schedules a normalized push notification to a user at a relative time.
##
## Service Name - PushNotification[br]
## Service Operation - ScheduleNormalizedNotification
##
## @param profile_id The profile id of the user to notify
## @param alert_content The alert content for the notification
## @param custom_data Custom data to include with the notification
## @param minutes_from_now Number of minutes from now to send the notification
func schedule_normalized_push_notification_minutes(profile_id: String, alert_content: Dictionary, custom_data: Dictionary, minutes_from_now: int) -> Dictionary:
	var data := {
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_PROFILE_ID: profile_id,
		OperationParam.ALERT_CONTENT: alert_content,
		OperationParam.CUSTOM_DATA: custom_data,
		OperationParam.MINUTES_FROM_NOW: minutes_from_now
	}
	return await _send(ServiceOperation.SCHEDULE_NORMALIZED_NOTIFICATION, data)

## Schedules a rich push notification to a user at a UTC time.
##
## Service Name - PushNotification[br]
## Service Operation - ScheduleRichNotification
##
## @param profile_id The profile id of the user to notify
## @param notification_template_id The id of the notification template to use
## @param substitutions Template substitutions as a Dictionary
## @param start_date_utc The UTC time at which to send the notification (ms since epoch)
func schedule_rich_push_notification_utc(profile_id: String, notification_template_id: int, substitutions: Dictionary, start_date_utc: int) -> Dictionary:
	var data := {
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_PROFILE_ID: profile_id,
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_NOTIFICATION_TEMPLATE_ID: notification_template_id,
		OperationParam.PUSH_NOTIFICATION_SEND_PARAM_SUBSTITUTIONS: substitutions,
		OperationParam.START_DATE_UTC: start_date_utc
	}
	return await _send(ServiceOperation.SCHEDULE_RICH_NOTIFICATION, data)

## Schedules a rich push notification to a user at a relative time.
##
## Service Name - PushNotification[br]
## Service Operation - ScheduleRichNotification
##
## @param profile_id The profile id of the user to notify
## @param notification_template_id The id of the notification template to use
## @param substitutions Template substitutions as a Dictionary
## @param minutes_from_now Number of minutes from now to send the notification
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
