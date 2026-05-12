# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_deregister_all(bc)
	await test_register_device_token(bc)
	await test_deregister_device_token(bc)
	await test_send_simple_push_notification(bc)
	await test_send_rich_push_notification(bc)
	await test_send_normalized_push_notification(bc)

func test_deregister_all(bc: BCTest) -> void:
	bc.begin_test("test_deregister_all")
	var response := await bc.bc_wrapper.push_notification_service.deregister_all_push_notification_device_tokens()
	bc.expect_status_ok(response)

func test_register_device_token(bc: BCTest) -> void:
	bc.begin_test("test_register_device_token")
	var response := await bc.bc_wrapper.push_notification_service.register_push_notification_device_token(
		"iOS", "GARBAGE_TOKEN"
	)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)

func test_deregister_device_token(bc: BCTest) -> void:
	bc.begin_test("test_deregister_device_token")
	var response := await bc.bc_wrapper.push_notification_service.deregister_push_notification_device_token(
		"iOS", "GARBAGE_TOKEN"
	)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)

func test_send_simple_push_notification(bc: BCTest) -> void:
	bc.begin_test("test_send_simple_push_notification")
	var response := await bc.bc_wrapper.push_notification_service.send_simple_push_notification(
		bc.user_a.profile_id, "Test message."
	)
	bc.expect_status_ok(response)

func test_send_rich_push_notification(bc: BCTest) -> void:
	bc.begin_test("test_send_rich_push_notification")
	var response := await bc.bc_wrapper.push_notification_service.send_rich_push_notification(
		bc.user_a.profile_id, 1
	)
	bc.expect_status_ok(response)

func test_send_normalized_push_notification(bc: BCTest) -> void:
	bc.begin_test("test_send_normalized_push_notification")
	var alert := {"body": "test body", "title": "test title"}
	var response := await bc.bc_wrapper.push_notification_service.send_normalized_push_notification(
		bc.user_a.profile_id, alert, {}
	)
	bc.expect_status_ok(response)
