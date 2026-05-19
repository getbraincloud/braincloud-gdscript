# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_get_presence_of_friends(bc)
	await test_get_presence_of_users(bc)
	await test_initialize_presence(bc)
	await test_update_activity(bc)
	await test_force_presence(bc)
	await test_stop_listening(bc)

func test_get_presence_of_friends(bc: BCTest) -> void:
	bc.begin_test("test_get_presence_of_friends")
	var response := await bc.bc_wrapper.presence_service.get_presence_of_friends("brainCloud", false)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)

func test_get_presence_of_users(bc: BCTest) -> void:
	bc.begin_test("test_get_presence_of_users")
	var response := await bc.bc_wrapper.presence_service.get_presence_of_users(
		[bc.user_a.profile_id, bc.user_b.profile_id], true
	)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)

func test_initialize_presence(bc: BCTest) -> void:
	bc.begin_test("test_initialize_presence")
	var response := await bc.bc_wrapper.presence_service.initialize_presence("brainCloud", false)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)

func test_update_activity(bc: BCTest) -> void:
	bc.begin_test("test_update_activity")
	var response := await bc.bc_wrapper.presence_service.update_activity({"status": "ingame"})
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)

func test_force_presence(bc: BCTest) -> void:
	bc.begin_test("test_force_presence")
	var response := await bc.bc_wrapper.presence_service.force_presence(true)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)

func test_stop_listening(bc: BCTest) -> void:
	bc.begin_test("test_stop_listening")
	var response := await bc.bc_wrapper.presence_service.stop_listening()
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)
