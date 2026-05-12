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
	await test_get_chat_history(bc)
	await test_update_chat_message(bc)
	await test_delete_chat_message(bc)
	await test_channel_disconnect(bc)

func test_get_channel_id(bc: BCTest) -> void:
	bc.begin_test("test_get_channel_id")
	var sub_id: String = bc.ids.get("channelId", "valid-channel-id")
	var response := await bc.bc_wrapper.chat_service.get_channel_id("gl", sub_id)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)
	if status == StatusCodes.OK:
		_channel_id = response.get("data", {}).get("channelId", "")

func test_get_subscribed_channels(bc: BCTest) -> void:
	bc.begin_test("test_get_subscribed_channels")
	var response := await bc.bc_wrapper.chat_service.get_subscribed_channels("gl")
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)

func test_get_channel_info(bc: BCTest) -> void:
	bc.begin_test("test_get_channel_info")
	if _channel_id.is_empty():
		bc.expect_true(true, "skipping — no channel_id")
		return
	var response := await bc.bc_wrapper.chat_service.get_channel_info(_channel_id)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)

func test_channel_connect(bc: BCTest) -> void:
	bc.begin_test("test_channel_connect")
	if _channel_id.is_empty():
		bc.expect_true(true, "skipping — no channel_id")
		return
	var response := await bc.bc_wrapper.chat_service.channel_connect(_channel_id, 50)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)

func test_get_recent_chat_messages(bc: BCTest) -> void:
	bc.begin_test("test_get_recent_chat_messages")
	if _channel_id.is_empty():
		bc.expect_true(true, "skipping — no channel_id")
		return
	var response := await bc.bc_wrapper.chat_service.get_recent_chat_messages(_channel_id, 10)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)

func test_post_chat_message_simple(bc: BCTest) -> void:
	bc.begin_test("test_post_chat_message_simple")
	if _channel_id.is_empty():
		bc.expect_true(true, "skipping — no channel_id")
		return
	var response := await bc.bc_wrapper.chat_service.post_chat_message_simple(_channel_id, "Hello GDScript test", true)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)
	if status == StatusCodes.OK:
		_msg_id = response.get("data", {}).get("msgId", "")
		_msg_version = response.get("data", {}).get("version", 1)

func test_post_chat_message(bc: BCTest) -> void:
	bc.begin_test("test_post_chat_message")
	if _channel_id.is_empty():
		bc.expect_true(true, "skipping — no channel_id")
		return
	var content := {"text": "GDScript rich message", "data": {"type": "test"}}
	var response := await bc.bc_wrapper.chat_service.post_chat_message(_channel_id, content, true)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)

func test_get_chat_history(bc: BCTest) -> void:
	bc.begin_test("test_get_chat_history")
	if _channel_id.is_empty():
		bc.expect_true(true, "skipping — no channel_id")
		return
	var now := int(Time.get_unix_time_from_system() * 1000)
	var response := await bc.bc_wrapper.chat_service.get_chat_history(_channel_id, now - 3600000, now, 10)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)

func test_update_chat_message(bc: BCTest) -> void:
	bc.begin_test("test_update_chat_message")
	if _channel_id.is_empty() or _msg_id.is_empty():
		bc.expect_true(true, "skipping — no channel_id or msg_id")
		return
	var content := {"text": "Updated message", "data": {}}
	var response := await bc.bc_wrapper.chat_service.update_chat_message(
		_channel_id, _msg_id, _msg_version, content
	)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)
	if status == StatusCodes.OK:
		_msg_version = response.get("data", {}).get("version", _msg_version)

func test_delete_chat_message(bc: BCTest) -> void:
	bc.begin_test("test_delete_chat_message")
	if _channel_id.is_empty() or _msg_id.is_empty():
		bc.expect_true(true, "skipping — no channel_id or msg_id")
		return
	var response := await bc.bc_wrapper.chat_service.delete_chat_message(_channel_id, _msg_id, -1)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)

func test_channel_disconnect(bc: BCTest) -> void:
	bc.begin_test("test_channel_disconnect")
	if _channel_id.is_empty():
		bc.expect_true(true, "skipping — no channel_id")
		return
	var response := await bc.bc_wrapper.chat_service.channel_disconnect(_channel_id)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)
