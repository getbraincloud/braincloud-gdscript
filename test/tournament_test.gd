# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_get_tournament_status(bc)
	await test_get_division_info(bc)
	await test_get_my_divisions(bc)
	await test_join_tournament(bc)
	await test_post_tournament_score(bc)
	await test_post_tournament_score_with_results(bc)
	await test_view_current_reward(bc)
	await test_view_reward(bc)
	await test_get_completed_tournament(bc)
	await test_leave_tournament(bc)

func _lb_id(bc: BCTest) -> String:
	return bc.ids.get("tournamentLeaderboardId", bc.ids.get("leaderboardId", "testLeaderboard"))

func _expect_tournament(bc: BCTest, response: Dictionary) -> void:
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST or status == StatusCodes.FORBIDDEN,
		"Expected 200, 400 or 403, got %d" % status
	)

func test_get_tournament_status(bc: BCTest) -> void:
	bc.begin_test("test_get_tournament_status")
	var response := await bc.bc_wrapper.tournament_service.get_tournament_status(_lb_id(bc), -1)
	_expect_tournament(bc, response)

func test_get_division_info(bc: BCTest) -> void:
	bc.begin_test("test_get_division_info")
	var response := await bc.bc_wrapper.tournament_service.get_division_info("invalid_division_set")
	_expect_tournament(bc, response)

func test_get_my_divisions(bc: BCTest) -> void:
	bc.begin_test("test_get_my_divisions")
	var response := await bc.bc_wrapper.tournament_service.get_my_divisions()
	bc.expect_status_ok(response)

func test_join_tournament(bc: BCTest) -> void:
	bc.begin_test("test_join_tournament")
	var response := await bc.bc_wrapper.tournament_service.join_tournament(_lb_id(bc), "free", 0)
	_expect_tournament(bc, response)

func test_post_tournament_score(bc: BCTest) -> void:
	bc.begin_test("test_post_tournament_score")
	var now_ms: int = int(Time.get_unix_time_from_system() * 1000)
	var response := await bc.bc_wrapper.tournament_service.post_tournament_score(
		_lb_id(bc), 1000, {"extra": "data"}, now_ms
	)
	_expect_tournament(bc, response)

func test_post_tournament_score_with_results(bc: BCTest) -> void:
	bc.begin_test("test_post_tournament_score_with_results")
	var now_ms: int = int(Time.get_unix_time_from_system() * 1000)
	var response := await bc.bc_wrapper.tournament_service.post_tournament_score_with_results(
		_lb_id(bc), 2000, {"extra": "data"}, now_ms, "HIGH_TO_LOW", 4, 5, 0
	)
	_expect_tournament(bc, response)

func test_view_current_reward(bc: BCTest) -> void:
	bc.begin_test("test_view_current_reward")
	var response := await bc.bc_wrapper.tournament_service.view_current_reward(_lb_id(bc))
	_expect_tournament(bc, response)

func test_view_reward(bc: BCTest) -> void:
	bc.begin_test("test_view_reward")
	var response := await bc.bc_wrapper.tournament_service.view_reward(_lb_id(bc), -1)
	_expect_tournament(bc, response)

func test_get_completed_tournament(bc: BCTest) -> void:
	bc.begin_test("test_get_completed_tournament")
	var response := await bc.bc_wrapper.tournament_service.get_completed_tournament(_lb_id(bc), -1)
	_expect_tournament(bc, response)

func test_leave_tournament(bc: BCTest) -> void:
	bc.begin_test("test_leave_tournament")
	var response := await bc.bc_wrapper.tournament_service.leave_tournament(_lb_id(bc))
	_expect_tournament(bc, response)
