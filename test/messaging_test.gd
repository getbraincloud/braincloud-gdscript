# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

var _msg_id: String = ""
var _page_context: String = ""

func run(bc: BCTest) -> void:
	await test_get_message_counts(bc)
	await test_get_message_boxes(bc)
	await test_send_message_simple(bc)
	await test_delete_messages(bc)
	await test_get_messages(bc)
	await test_get_message_page(bc)
	await test_get_message_page_offset(bc)
	await test_mark_messages_read(bc)
	await test_send_message(bc)

func _ensure_msg(bc: BCTest) -> void:
	if _msg_id.is_empty():
		var resp := await bc.bc_wrapper.messaging_service.send_message_simple(
			[bc.user_a.profile_id], "Test"
		)
		_msg_id = resp.get("data", {}).get("msgId", "")

func test_get_message_counts(bc: BCTest) -> void:
	bc.begin_test("test_get_message_counts")
	var response := await bc.bc_wrapper.messaging_service.get_message_counts()
	bc.expect_status_ok(response)

func test_get_message_boxes(bc: BCTest) -> void:
	bc.begin_test("test_get_message_boxes")
	var response := await bc.bc_wrapper.messaging_service.get_message_boxes()
	bc.expect_status_ok(response)

func test_send_message_simple(bc: BCTest) -> void:
	bc.begin_test("test_send_message_simple")
	var response := await bc.bc_wrapper.messaging_service.send_message_simple(
		[bc.user_a.profile_id], "Test"
	)
	bc.expect_status_ok(response)
	_msg_id = response.get("data", {}).get("msgId", "")

func test_delete_messages(bc: BCTest) -> void:
	bc.begin_test("test_delete_messages")
	await _ensure_msg(bc)
	if _msg_id.is_empty():
		bc.expect_true(false, "Need a msgId to test deletion")
		return
	var response := await bc.bc_wrapper.messaging_service.delete_messages("inbox", [_msg_id])
	bc.expect_status_ok(response)
	_msg_id = ""

func test_get_messages(bc: BCTest) -> void:
	bc.begin_test("test_get_messages")
	await _ensure_msg(bc)
	if _msg_id.is_empty():
		bc.expect_true(false, "Need a msgId to test get_messages")
		return
	var response := await bc.bc_wrapper.messaging_service.get_messages("inbox", [_msg_id], true)
	bc.expect_status_ok(response)

func test_get_message_page(bc: BCTest) -> void:
	bc.begin_test("test_get_message_page")
	var context := {
		"pagination": {"rowsPerPage": 10, "pageNumber": 1},
		"searchCriteria": {"msgbox": "inbox"},
		"sortCriteria": {"mbCr": 1, "mbUp": -1}
	}
	var response := await bc.bc_wrapper.messaging_service.get_message_page(context)
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")
	_page_context = response.get("data", {}).get("context", "")

func test_get_message_page_offset(bc: BCTest) -> void:
	bc.begin_test("test_get_message_page_offset")
	if _page_context.is_empty():
		var context := {
			"pagination": {"rowsPerPage": 10, "pageNumber": 1},
			"searchCriteria": {"msgbox": "inbox"},
			"sortCriteria": {"mbCr": 1, "mbUp": -1}
		}
		var page_resp := await bc.bc_wrapper.messaging_service.get_message_page(context)
		_page_context = page_resp.get("data", {}).get("context", "")
	var response := await bc.bc_wrapper.messaging_service.get_message_page_offset(_page_context, 1)
	bc.expect_status_ok(response)

func test_mark_messages_read(bc: BCTest) -> void:
	bc.begin_test("test_mark_messages_read")
	await _ensure_msg(bc)
	if _msg_id.is_empty():
		bc.expect_true(false, "Need a msgId to test mark_messages_read")
		return
	var response := await bc.bc_wrapper.messaging_service.mark_messages_read("inbox", [_msg_id])
	bc.expect_status_ok(response)

func test_send_message(bc: BCTest) -> void:
	bc.begin_test("test_send_message")
	var response := await bc.bc_wrapper.messaging_service.send_message(
		[bc.user_a.profile_id], {"msg": "missed call"}
	)
	bc.expect_status_ok(response)
	_msg_id = response.get("data", {}).get("msgId", "")
