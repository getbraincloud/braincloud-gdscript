# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_increment_global_stats(bc)
	await test_read_all_global_stats(bc)
	await test_read_global_stats_subset(bc)
	await test_read_global_stats_for_category(bc)
	await test_process_statistics(bc)

func test_increment_global_stats(bc: BCTest) -> void:
	bc.begin_test("test_increment_global_stats")
	var response := await bc.bc_wrapper.global_statistics_service.increment_global_stats({"gamesPlayed": 1, "gamesWon": 1, "gamesLost": 2})
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)

func test_read_all_global_stats(bc: BCTest) -> void:
	bc.begin_test("test_read_all_global_stats")
	var response := await bc.bc_wrapper.global_statistics_service.read_all_global_stats()
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_read_global_stats_subset(bc: BCTest) -> void:
	bc.begin_test("test_read_global_stats_subset")
	var response := await bc.bc_wrapper.global_statistics_service.read_global_stats_subset(["gamesPlayed"])
	bc.expect_status_ok(response)

func test_read_global_stats_for_category(bc: BCTest) -> void:
	bc.begin_test("test_read_global_stats_for_category")
	var response := await bc.bc_wrapper.global_statistics_service.query_global_stats_by_category("Test")
	bc.expect_status_ok(response)

func test_process_statistics(bc: BCTest) -> void:
	bc.begin_test("test_process_statistics")
	var response := await bc.bc_wrapper.global_statistics_service.process_statistics({"gamesPlayed": 1, "gamesWon": 1, "gamesLost": 2})
	bc.expect_status_ok(response)
