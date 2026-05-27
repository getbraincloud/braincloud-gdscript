# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudChat
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

## Registers a listener for incoming events from the given channel.
## Also returns a list of recent messages from history.
##
## Service Name - Chat[br]
## Service Operation - ChannelConnect
##
## @param channel_id The id of the chat channel to connect to
## @param max_return Maximum number of recent messages to return
func channel_connect(channel_id: String, max_return: int) -> Dictionary:
	var data := {
		OperationParam.CHAT_CHANNEL_ID: channel_id,
		OperationParam.CHAT_MAX_RETURN: max_return
	}
	return await _send(ServiceOperation.CHANNEL_CONNECT, data)

## Unregisters a listener for incoming events from the given channel.
##
## Service Name - Chat[br]
## Service Operation - ChannelDisconnect
##
## @param channel_id The id of the chat channel to disconnect from
func channel_disconnect(channel_id: String) -> Dictionary:
	var data := {
		OperationParam.CHAT_CHANNEL_ID: channel_id
	}
	return await _send(ServiceOperation.CHANNEL_DISCONNECT, data)

## Deletes a chat message. Version must match the latest or pass -1 to bypass version check.
##
## Service Name - Chat[br]
## Service Operation - DeleteChatMessage
##
## @param channel_id The id of the channel that contains the message
## @param msg_id The message id to delete
## @param version Version of the message. Must match latest or pass -1 to bypass version check
func delete_chat_message(channel_id: String, msg_id: String, version: int) -> Dictionary:
	var data := {
		OperationParam.CHAT_CHANNEL_ID: channel_id,
		OperationParam.CHAT_MSG_ID: msg_id,
		OperationParam.CHAT_VERSION: version
	}
	return await _send(ServiceOperation.DELETE_CHAT_MESSAGE, data)

## Gets the channelId for the given channel type and sub id.
## Channel type must be one of "gl" or "gr" (global or group).
##
## Service Name - Chat[br]
## Service Operation - GetChannelId
##
## @param channel_type Channel type: "gl" for global or "gr" for group
## @param sub_id The sub id of the channel
func get_channel_id(channel_type: String, sub_id: String) -> Dictionary:
	var data := {
		"channelType": channel_type,
		"subId": sub_id
	}
	return await _send(ServiceOperation.GET_CHANNEL_ID, data)

## Gets description info and activity stats for the given channel.
## Only callable for channels the user is a member of.
##
## Service Name - Chat[br]
## Service Operation - GetChannelInfo
##
## @param channel_id The id of the channel to get info for
func get_channel_info(channel_id: String) -> Dictionary:
	var data := {
		OperationParam.CHAT_CHANNEL_ID: channel_id
	}
	return await _send(ServiceOperation.GET_CHANNEL_INFO, data)

## Gets a list of messages from history of the given channel.
##
## Service Name - Chat[br]
## Service Operation - GetChatHistory
##
## @param channel_id The id of the channel to get history from
## @param date_from Start date filter in UTC milliseconds
## @param date_to End date filter in UTC milliseconds
## @param max_return Maximum number of messages to return
func get_chat_history(channel_id: String, date_from: int, date_to: int, max_return: int) -> Dictionary:
	var data := {
		OperationParam.CHAT_CHANNEL_ID: channel_id,
		"dateFrom": date_from,
		"dateTo": date_to,
		OperationParam.CHAT_MAX_RETURN: max_return
	}
	return await _send(ServiceOperation.GET_CHAT_HISTORY, data)

## Gets a list of recent messages from history of the given channel.
##
## Service Name - Chat[br]
## Service Operation - GetRecentChatMessages
##
## @param channel_id The id of the channel to get recent messages from
## @param max_return Maximum message count to return
func get_recent_chat_messages(channel_id: String, max_return: int) -> Dictionary:
	var data := {
		OperationParam.CHAT_CHANNEL_ID: channel_id,
		OperationParam.CHAT_MAX_RETURN: max_return
	}
	return await _send(ServiceOperation.GET_RECENT_CHAT_MESSAGES, data)

## Gets a list of the channels of the given type that the user has access to.
## Channel type must be one of "gl", "gr" or "all".
##
## Service Name - Chat[br]
## Service Operation - GetSubscribedChannels
##
## @param channel_type Type of channels: "gl" for global, "gr" for group, or "all"
func get_subscribed_channels(channel_type: String) -> Dictionary:
	var data := {
		"channelType": channel_type
	}
	return await _send("GET_SUBSCRIBED_CHANNELS", data)

## Sends a potentially rich chat message. Content must contain at least a "text" field.
##
## Service Name - Chat[br]
## Service Operation - PostChatMessage
##
## @param channel_id Channel id to post message to
## @param content_json Content Dictionary containing at least a "text" field
## @param record_in_history Whether to record this message in history
func post_chat_message(channel_id: String, content_json: Dictionary, record_in_history: bool) -> Dictionary:
	var data := {
		OperationParam.CHAT_CHANNEL_ID: channel_id,
		OperationParam.CHAT_CONTENT: content_json,
		OperationParam.CHAT_RICH: record_in_history
	}
	return await _send(ServiceOperation.POST_CHAT_MESSAGE, data)

## Sends a simple text-only chat message.
##
## Service Name - Chat[br]
## Service Operation - PostChatMessageSimple
##
## @param channel_id Channel id to post message to
## @param plain_text The text message to send
## @param record_in_history Whether to record this message in history
func post_chat_message_simple(channel_id: String, plain_text: String, record_in_history: bool) -> Dictionary:
	var data := {
		OperationParam.CHAT_CHANNEL_ID: channel_id,
		OperationParam.CHAT_PLAIN_TEXT: plain_text,
		OperationParam.CHAT_RICH: record_in_history
	}
	return await _send(ServiceOperation.POST_CHAT_MESSAGE_SIMPLE, data)

## Updates a chat message. Version must match the latest or pass -1 to bypass version check.
##
## Service Name - Chat[br]
## Service Operation - UpdateChatMessage
##
## @param channel_id Channel id where the message to update is
## @param msg_id The message id to update
## @param version Version of the message. Must match latest or pass -1 to bypass version check
## @param content_json Updated content Dictionary containing at least a "text" field
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
