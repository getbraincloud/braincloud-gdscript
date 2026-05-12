# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_trigger_stats_event(bc)

func test_trigger_stats_event(bc: BCTest) -> void:
	bc.begin_test("test_trigger_stats_event")
	var response := await bc.bc_wrapper.player_statistics_event_service.trigger_stats_event("testEvent", 1)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST or status == 404,
		"Expected 200, 400, or 404, got %d" % status
	)
