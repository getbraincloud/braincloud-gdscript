# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_use_invalid_code(bc)

func test_use_invalid_code(bc: BCTest) -> void:
	bc.begin_test("test_use_invalid_code")
	var response := await bc.bc_wrapper.redemption_code_service.use_redemption_code(
		"INVALID-CODE-999", "testType", {}
	)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.BAD_REQUEST or status == StatusCodes.FORBIDDEN,
		"Expected 400 or 403 for invalid code, got %d" % status
	)
