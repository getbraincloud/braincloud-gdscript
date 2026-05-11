# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_deregister_all(bc)
	await test_register_device_token(bc)

func test_deregister_all(bc: BCTest) -> void:
	bc.begin_test("test_deregister_all")
	var response := await bc.bc_wrapper.push_notification_service.deregister_all_push_notification_device_tokens()
	bc.expect_status_ok(response)

func test_register_device_token(bc: BCTest) -> void:
	bc.begin_test("test_register_device_token")
	# Register a fake iOS token for testing purposes
	var response := await bc.bc_wrapper.push_notification_service.register_push_notification_device_token(
		"iOS", "fakeDeviceToken_GDScriptTest_" + str(randi() % 999999)
	)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)
