# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_list_all_leaderboards(bc)
	await test_get_global_leaderboard_page(bc)
	await test_post_score_to_dynamic_leaderboard(bc)

func test_list_all_leaderboards(bc: BCTest) -> void:
	bc.begin_test("test_list_all_leaderboards")
	var response := await bc.bc_wrapper.social_leaderboard_service.list_all_leaderboards()
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_get_global_leaderboard_page(bc: BCTest) -> void:
	bc.begin_test("test_get_global_leaderboard_page")
	# Use a known leaderboard id or accept 400 if it doesn't exist
	var leaderboard_id: String = bc.ids.get("leaderboardId", "testLeaderboard")
	var response := await bc.bc_wrapper.social_leaderboard_service.get_global_leaderboard_page(
		leaderboard_id, "HIGH_TO_LOW", 0, 9
	)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)

func test_post_score_to_dynamic_leaderboard(bc: BCTest) -> void:
	bc.begin_test("test_post_score_to_dynamic_leaderboard")
	var response := await bc.bc_wrapper.social_leaderboard_service.post_score_to_dynamic_leaderboard(
		"testLB", 100, {}, "HIGH_VALUE", "WEEKLY", 0, 2
	)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)
