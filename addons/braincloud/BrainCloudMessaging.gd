# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudMessaging
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

## Retrieves user's message boxes, including 'inbox', 'sent', etc.
##
## Service Name - Messaging[br]
## Service Operation - GetMessageboxes
func get_message_boxes() -> Dictionary:
	return await _send(ServiceOperation.MSG_BOX_GET_MESSAGE_BOXES, {})

## Retrieves unread message counts for the user's message boxes.
##
## Service Name - Messaging[br]
## Service Operation - GetMessageCounts
func get_message_counts() -> Dictionary:
	return await _send(ServiceOperation.MSG_BOX_GET_MESSAGE_COUNTS, {})

## Deletes specified user messages on the server.
##
## Service Name - Messaging[br]
## Service Operation - DeleteMessages
##
## @param msg_box The message box identifier (e.g. "inbox")
## @param msg_ids Array of message ids to delete
func delete_messages(msg_box: String, msg_ids: Array) -> Dictionary:
	var data := {
		OperationParam.MESSAGING_MESSAGE_BOX: msg_box,
		OperationParam.MESSAGING_MSG_IDS: msg_ids
	}
	return await _send(ServiceOperation.MSG_BOX_DELETE_MESSAGES, data)

## Retrieves a page of messages.
##
## Service Name - Messaging[br]
## Service Operation - GetMessagesPage
##
## @param context The pagination context Dictionary
func get_message_page(context: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GROUP_CONTEXT: context
	}
	return await _send(ServiceOperation.MSG_BOX_GET_MESSAGE_PAGE, data)

## Gets the page of messages based on the encoded context and specified page offset.
##
## Service Name - Messaging[br]
## Service Operation - GetMessagesPageOffset
##
## @param context The encoded context string from a previous page request
## @param page_offset The number of pages to offset
func get_message_page_offset(context: String, page_offset: int) -> Dictionary:
	var data := {
		OperationParam.GROUP_CONTEXT: context,
		OperationParam.MESSAGING_PAGE_OFFSET: page_offset
	}
	return await _send(ServiceOperation.MSG_BOX_GET_MESSAGE_PAGE_OFFSET, data)

## Retrieves list of specified messages.
##
## Service Name - Messaging[br]
## Service Operation - GetMessages
##
## @param msg_box The message box identifier (e.g. "inbox")
## @param msg_ids Array of message ids to retrieve
## @param mark_as_read Whether to mark retrieved messages as read
func get_messages(msg_box: String, msg_ids: Array, mark_as_read: bool) -> Dictionary:
	var data := {
		OperationParam.MESSAGING_MESSAGE_BOX: msg_box,
		OperationParam.MESSAGING_MSG_IDS: msg_ids,
		OperationParam.MESSAGING_MARK_AS_READ: mark_as_read
	}
	return await _send(ServiceOperation.MSG_BOX_GET_MESSAGES, data)

## Marks list of user messages as read on the server.
##
## Service Name - Messaging[br]
## Service Operation - MarkMessagesRead
##
## @param msg_box The message box identifier (e.g. "inbox")
## @param msg_ids Array of message ids to mark as read
func mark_messages_read(msg_box: String, msg_ids: Array) -> Dictionary:
	var data := {
		OperationParam.MESSAGING_MESSAGE_BOX: msg_box,
		OperationParam.MESSAGING_MSG_IDS: msg_ids
	}
	return await _send(ServiceOperation.MSG_BOX_MARK_MESSAGES_READ, data)

## Sends a message with specified content to a list of users.
##
## Service Name - Messaging[br]
## Service Operation - SendMessage
##
## @param to_profile_ids Array of profile ids to send the message to
## @param content_json The message content as a Dictionary
func send_message(to_profile_ids: Array, content_json: Dictionary) -> Dictionary:
	var data := {
		OperationParam.MESSAGING_PROFILE_IDS: to_profile_ids,
		OperationParam.MESSAGING_CONTENT: content_json
	}
	return await _send(ServiceOperation.MSG_BOX_SEND_MESSAGE, data)

## Sends a simple text message to a specified list of users.
##
## Service Name - Messaging[br]
## Service Operation - SendMessageSimple
##
## @param to_profile_ids Array of profile ids to send the message to
## @param text The message text to send
func send_message_simple(to_profile_ids: Array, text: String) -> Dictionary:
	var data := {
		OperationParam.MESSAGING_PROFILE_IDS: to_profile_ids,
		OperationParam.MESSAGING_CONTENT_TEXT: text
	}
	return await _send(ServiceOperation.MSG_BOX_SEND_MESSAGE_SIMPLE, data)

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.MESSAGING, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
