# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_send_basic_email(bc)

func test_send_basic_email(bc: BCTest) -> void:
	bc.begin_test("test_send_basic_email")
	var response := await bc.bc_wrapper.mail_service.send_basic_email(
		bc.user_a.profile_id, "Test Subject", "Test Body"
	)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)
