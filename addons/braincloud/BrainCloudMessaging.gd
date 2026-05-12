# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudMessaging
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

func get_message_boxes() -> Dictionary:
	return await _send(ServiceOperation.MSG_BOX_GET_MESSAGE_BOXES, {})

func get_message_counts() -> Dictionary:
	return await _send(ServiceOperation.MSG_BOX_GET_MESSAGE_COUNTS, {})

func delete_messages(msg_box: String, msg_ids: Array) -> Dictionary:
	var data := {
		OperationParam.MESSAGING_MESSAGE_BOX: msg_box,
		OperationParam.MESSAGING_MSG_IDS: msg_ids
	}
	return await _send(ServiceOperation.MSG_BOX_DELETE_MESSAGES, data)

func get_message_page(context: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GROUP_CONTEXT: context
	}
	return await _send(ServiceOperation.MSG_BOX_GET_MESSAGE_PAGE, data)

func get_message_page_offset(context: String, page_offset: int) -> Dictionary:
	var data := {
		OperationParam.GROUP_CONTEXT: context,
		OperationParam.MESSAGING_PAGE_OFFSET: page_offset
	}
	return await _send(ServiceOperation.MSG_BOX_GET_MESSAGE_PAGE_OFFSET, data)

func get_messages(msg_box: String, msg_ids: Array, mark_as_read: bool) -> Dictionary:
	var data := {
		OperationParam.MESSAGING_MESSAGE_BOX: msg_box,
		OperationParam.MESSAGING_MSG_IDS: msg_ids,
		OperationParam.MESSAGING_MARK_AS_READ: mark_as_read
	}
	return await _send(ServiceOperation.MSG_BOX_GET_MESSAGES, data)

func mark_messages_read(msg_box: String, msg_ids: Array) -> Dictionary:
	var data := {
		OperationParam.MESSAGING_MESSAGE_BOX: msg_box,
		OperationParam.MESSAGING_MSG_IDS: msg_ids
	}
	return await _send(ServiceOperation.MSG_BOX_MARK_MESSAGES_READ, data)

func send_message(to_profile_ids: Array, content_json: Dictionary) -> Dictionary:
	var data := {
		OperationParam.MESSAGING_PROFILE_IDS: to_profile_ids,
		OperationParam.MESSAGING_CONTENT: content_json
	}
	return await _send(ServiceOperation.MSG_BOX_SEND_MESSAGE, data)

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
