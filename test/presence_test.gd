# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_get_presence_of_friends(bc)

func test_get_presence_of_friends(bc: BCTest) -> void:
	bc.begin_test("test_get_presence_of_friends")
	var response := await bc.bc_wrapper.presence_service.get_presence_of_friends("brainCloud", false)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)
