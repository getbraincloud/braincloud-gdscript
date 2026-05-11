# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudChat
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

func channel_connect(channel_id: String, max_return: int) -> Dictionary:
	var data := {
		OperationParam.CHAT_CHANNEL_ID: channel_id,
		OperationParam.CHAT_MAX_RETURN: max_return
	}
	return await _send(ServiceOperation.CHANNEL_CONNECT, data)

func channel_disconnect(channel_id: String) -> Dictionary:
	var data := {
		OperationParam.CHAT_CHANNEL_ID: channel_id
	}
	return await _send(ServiceOperation.CHANNEL_DISCONNECT, data)

func delete_chat_message(channel_id: String, msg_id: String, version: int) -> Dictionary:
	var data := {
		OperationParam.CHAT_CHANNEL_ID: channel_id,
		OperationParam.CHAT_MSG_ID: msg_id,
		OperationParam.CHAT_VERSION: version
	}
	return await _send(ServiceOperation.DELETE_CHAT_MESSAGE, data)

func get_channel_id(channel_type: String, sub_id: String) -> Dictionary:
	var data := {
		"channelType": channel_type,
		"subId": sub_id
	}
	return await _send(ServiceOperation.GET_CHANNEL_ID, data)

func get_channel_info(channel_id: String) -> Dictionary:
	var data := {
		OperationParam.CHAT_CHANNEL_ID: channel_id
	}
	return await _send(ServiceOperation.GET_CHANNEL_INFO, data)

func get_chat_history(channel_id: String, date_from: int, date_to: int, max_return: int) -> Dictionary:
	var data := {
		OperationParam.CHAT_CHANNEL_ID: channel_id,
		"dateFrom": date_from,
		"dateTo": date_to,
		OperationParam.CHAT_MAX_RETURN: max_return
	}
	return await _send(ServiceOperation.GET_CHAT_HISTORY, data)

func get_recent_chat_messages(channel_id: String, max_return: int) -> Dictionary:
	var data := {
		OperationParam.CHAT_CHANNEL_ID: channel_id,
		OperationParam.CHAT_MAX_RETURN: max_return
	}
	return await _send(ServiceOperation.GET_RECENT_CHAT_MESSAGES, data)

func get_subscribed_channels(channel_type: String) -> Dictionary:
	var data := {
		"channelType": channel_type
	}
	return await _send("GET_SUBSCRIBED_CHANNELS", data)

func post_chat_message(channel_id: String, content_json: Dictionary, record_in_history: bool) -> Dictionary:
	var data := {
		OperationParam.CHAT_CHANNEL_ID: channel_id,
		OperationParam.CHAT_CONTENT: content_json,
		OperationParam.CHAT_RICH: record_in_history
	}
	return await _send(ServiceOperation.POST_CHAT_MESSAGE, data)

func post_chat_message_simple(channel_id: String, plain_text: String, record_in_history: bool) -> Dictionary:
	var data := {
		OperationParam.CHAT_CHANNEL_ID: channel_id,
		OperationParam.CHAT_PLAIN_TEXT: plain_text,
		OperationParam.CHAT_RICH: record_in_history
	}
	return await _send(ServiceOperation.POST_CHAT_MESSAGE_SIMPLE, data)

func update_chat_message(channel_id: String, msg_id: String, version: int, content_json: Dictionary) -> Dictionary:
	var data := {
		OperationParam.CHAT_CHANNEL_ID: channel_id,
		OperationParam.CHAT_MSG_ID: msg_id,
		OperationParam.CHAT_VERSION: version,
		OperationParam.CHAT_CONTENT: content_json
	}
	return await _send(ServiceOperation.UPDATE_CHAT_MESSAGE, data)

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.CHAT, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
