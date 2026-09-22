# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

var _channel_id: String = ""
var _msg_id: String = ""
var _msg_version: int = 1

func run(bc: BCTest) -> void:
	await test_get_channel_id(bc)
	await test_get_subscribed_channels(bc)
	await test_get_channel_info(bc)
	await test_channel_connect(bc)
	await test_get_recent_chat_messages(bc)
	await test_post_chat_message_simple(bc)
	await test_post_chat_message(bc)
	await test_get_chat_message(bc)
	await test_update_chat_message(bc)
	await test_delete_chat_message(bc)
	await test_channel_disconnect(bc)

func test_get_channel_id(bc: BCTest) -> void:
	bc.begin_test("test_get_channel_id")
	var sub_id: String = bc.ids.get("channelId", "valid")
	var response := await bc.bc_wrapper.chat_service.get_channel_id("gl", sub_id)
	bc.expect_status_ok(response)
	_channel_id = response.get("data", {}).get("channelId", "")

func test_get_subscribed_channels(bc: BCTest) -> void:
	bc.begin_test("test_get_subscribed_channels")
	var response := await bc.bc_wrapper.chat_service.get_subscribed_channels("gl")
	bc.expect_status_ok(response)

func test_get_channel_info(bc: BCTest) -> void:
	bc.begin_test("test_get_channel_info")
	if _channel_id.is_empty():
		bc.expect_true(true, "skipping — no channel_id")
		return
	var response := await bc.bc_wrapper.chat_service.get_channel_info(_channel_id)
	bc.expect_status_ok(response)

func test_channel_connect(bc: BCTest) -> void:
	bc.begin_test("test_channel_connect")
	if _channel_id.is_empty():
		bc.expect_true(true, "skipping — no channel_id")
		return
	var response := await bc.bc_wrapper.chat_service.channel_connect(_channel_id, 50)
	bc.expect_status_ok(response)

func test_get_recent_chat_messages(bc: BCTest) -> void:
	bc.begin_test("test_get_recent_chat_messages")
	if _channel_id.is_empty():
		bc.expect_true(true, "skipping — no channel_id")
		return
	var response := await bc.bc_wrapper.chat_service.get_recent_chat_messages(_channel_id, 10)
	bc.expect_status_ok(response)

func test_post_chat_message_simple(bc: BCTest) -> void:
	bc.begin_test("test_post_chat_message_simple")
	if _channel_id.is_empty():
		bc.expect_true(true, "skipping — no channel_id")
		return
	var response := await bc.bc_wrapper.chat_service.post_chat_message_simple(_channel_id, "Hello GDScript test", true)
	bc.expect_status_ok(response)
	_msg_id = response.get("data", {}).get("msgId", "")
	_msg_version = response.get("data", {}).get("version", 1)

func test_post_chat_message(bc: BCTest) -> void:
	bc.begin_test("test_post_chat_message")
	if _channel_id.is_empty():
		bc.expect_true(true, "skipping — no channel_id")
		return
	var content := {"text": "GDScript rich message", "data": {"type": "test"}}
	var response := await bc.bc_wrapper.chat_service.post_chat_message(_channel_id, content, true)
	bc.expect_status_ok(response)

func test_get_chat_message(bc: BCTest) -> void:
	bc.begin_test("test_get_chat_message")
	if _channel_id.is_empty() or _msg_id.is_empty():
		bc.expect_true(true, "skipping — no channel_id or msg_id")
		return
	var response := await bc.bc_wrapper.chat_service.get_chat_message(_channel_id, _msg_id)
	bc.expect_status_ok(response)

func test_update_chat_message(bc: BCTest) -> void:
	bc.begin_test("test_update_chat_message")
	if _channel_id.is_empty() or _msg_id.is_empty():
		bc.expect_true(true, "skipping — no channel_id or msg_id")
		return
	var content := {"text": "Updated message", "data": {}}
	var response := await bc.bc_wrapper.chat_service.update_chat_message(
		_channel_id, _msg_id, _msg_version, content
	)
	bc.expect_status_ok(response)
	_msg_version = response.get("data", {}).get("version", _msg_version)

func test_delete_chat_message(bc: BCTest) -> void:
	bc.begin_test("test_delete_chat_message")
	if _channel_id.is_empty() or _msg_id.is_empty():
		bc.expect_true(true, "skipping — no channel_id or msg_id")
		return
	var response := await bc.bc_wrapper.chat_service.delete_chat_message(_channel_id, _msg_id, -1)
	bc.expect_status_ok(response)

func test_channel_disconnect(bc: BCTest) -> void:
	bc.begin_test("test_channel_disconnect")
	if _channel_id.is_empty():
		bc.expect_true(true, "skipping — no channel_id")
		return
	var response := await bc.bc_wrapper.chat_service.channel_disconnect(_channel_id)
	bc.expect_status_ok(response)
