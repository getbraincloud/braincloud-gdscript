# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_get_tournament_status_invalid(bc)

func test_get_tournament_status_invalid(bc: BCTest) -> void:
	bc.begin_test("test_get_tournament_status_invalid")
	var response := await bc.bc_wrapper.tournament_service.get_tournament_status("invalid_lb", 0)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.BAD_REQUEST or status == StatusCodes.FORBIDDEN,
		"Expected 400 or 403 for invalid tournament, got %d" % status
	)
