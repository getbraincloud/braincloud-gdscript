# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_list_all_leaderboards(bc)
	await test_get_global_leaderboard_page(bc)
	await test_get_global_leaderboard_view(bc)
	await test_get_global_leaderboard_versions(bc)
	await test_get_global_leaderboard_entry_count(bc)
	await test_post_score_to_leaderboard(bc)
	await test_get_social_leaderboard(bc)
	await test_get_social_leaderboard_by_version(bc)
	await test_get_multi_social_leaderboard(bc)
	await test_post_score_to_dynamic_leaderboard(bc)
	await test_post_score_to_dynamic_leaderboard_utc(bc)
	await test_post_score_to_leaderboard_using_config(bc)
	await test_get_player_score(bc)
	await test_get_player_scores(bc)
	await test_get_player_scores_from_leaderboards(bc)
	await test_remove_player_score(bc)
	await test_group_leaderboard_flow(bc)

func test_list_all_leaderboards(bc: BCTest) -> void:
	bc.begin_test("test_list_all_leaderboards")
	var response := await bc.bc_wrapper.social_leaderboard_service.list_all_leaderboards()
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_get_global_leaderboard_page(bc: BCTest) -> void:
	bc.begin_test("test_get_global_leaderboard_page")
	var lb_id: String = bc.ids.get("leaderboardId", "testLeaderboard")
	var response := await bc.bc_wrapper.social_leaderboard_service.get_global_leaderboard_page(
		lb_id, "HIGH_TO_LOW", 0, 10
	)
	bc.expect_status_ok(response)

func test_get_global_leaderboard_view(bc: BCTest) -> void:
	bc.begin_test("test_get_global_leaderboard_view")
	var lb_id: String = bc.ids.get("leaderboardId", "testLeaderboard")
	var response := await bc.bc_wrapper.social_leaderboard_service.get_global_leaderboard_view(
		lb_id, "HIGH_TO_LOW", 4, 5
	)
	bc.expect_status_ok(response)

func test_get_global_leaderboard_versions(bc: BCTest) -> void:
	bc.begin_test("test_get_global_leaderboard_versions")
	var lb_id: String = bc.ids.get("leaderboardId", "testLeaderboard")
	var response := await bc.bc_wrapper.social_leaderboard_service.get_global_leaderboard_versions(lb_id)
	bc.expect_status_ok(response)

func test_get_global_leaderboard_entry_count(bc: BCTest) -> void:
	bc.begin_test("test_get_global_leaderboard_entry_count")
	var lb_id: String = bc.ids.get("leaderboardId", "testLeaderboard")
	var response := await bc.bc_wrapper.social_leaderboard_service.get_global_leaderboard_entry_count(lb_id)
	bc.expect_status_ok(response)

func test_post_score_to_leaderboard(bc: BCTest) -> void:
	bc.begin_test("test_post_score_to_leaderboard")
	var lb_id: String = bc.ids.get("leaderboardId", "testLeaderboard")
	var response := await bc.bc_wrapper.social_leaderboard_service.post_score_to_leaderboard(
		lb_id, 1000, {"extra": 123}
	)
	bc.expect_status_ok(response)

func test_get_social_leaderboard(bc: BCTest) -> void:
	bc.begin_test("test_get_social_leaderboard")
	var lb_id: String = bc.ids.get("leaderboardId", "testLeaderboard")
	var response := await bc.bc_wrapper.social_leaderboard_service.get_social_leaderboard(lb_id, true)
	bc.expect_status_ok(response)

func test_get_social_leaderboard_by_version(bc: BCTest) -> void:
	bc.begin_test("test_get_social_leaderboard_by_version")
	var lb_id: String = bc.ids.get("leaderboardId", "testLeaderboard")
	var response := await bc.bc_wrapper.social_leaderboard_service.get_social_leaderboard_by_version(lb_id, true, 0)
	bc.expect_status_ok(response)

func test_get_multi_social_leaderboard(bc: BCTest) -> void:
	bc.begin_test("test_get_multi_social_leaderboard")
	var lb_id: String = bc.ids.get("leaderboardId", "testLeaderboard")
	var response := await bc.bc_wrapper.social_leaderboard_service.get_multi_social_leaderboard(
		[lb_id, "testDynamicJs"], 10, true
	)
	bc.expect_status_ok(response)

func test_post_score_to_dynamic_leaderboard(bc: BCTest) -> void:
	bc.begin_test("test_post_score_to_dynamic_leaderboard")
	var tomorrow_ms: int = (Time.get_unix_time_from_system() + 86400) * 1000
	var response := await bc.bc_wrapper.social_leaderboard_service.post_score_to_dynamic_leaderboard(
		"testDynamicJs", 1000, {"extra": 123}, "HIGH_VALUE", "WEEKLY", tomorrow_ms, 2
	)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)

func test_post_score_to_dynamic_leaderboard_utc(bc: BCTest) -> void:
	bc.begin_test("test_post_score_to_dynamic_leaderboard_utc")
	var tomorrow_ms: int = (Time.get_unix_time_from_system() + 86400) * 1000
	var response := await bc.bc_wrapper.social_leaderboard_service.post_score_to_dynamic_leaderboard_utc(
		"testDynamicJs", 1000, {"extra": 123}, "HIGH_VALUE", "DAILY", tomorrow_ms, 3
	)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)

func test_post_score_to_leaderboard_using_config(bc: BCTest) -> void:
	bc.begin_test("test_post_score_to_leaderboard_using_config")
	var tomorrow_ms: int = (Time.get_unix_time_from_system() + 86400) * 1000
	var config := {
		"leaderboardType": "HIGH_VALUE",
		"rotationType": "DAYS",
		"numDaysToRotate": 4,
		"resetAt": tomorrow_ms,
		"retainedCount": 2,
		"expireInMins": null
	}
	var response := await bc.bc_wrapper.social_leaderboard_service.post_score_to_leaderboard_using_config(
		"testDynamicJs", 9999, {"nickname": "tester"}, config
	)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)

func test_get_player_score(bc: BCTest) -> void:
	bc.begin_test("test_get_player_score")
	var lb_id: String = bc.ids.get("leaderboardId", "testLeaderboard")
	var response := await bc.bc_wrapper.social_leaderboard_service.get_player_score(lb_id, -1)
	bc.expect_status_ok(response)

func test_get_player_scores(bc: BCTest) -> void:
	bc.begin_test("test_get_player_scores")
	var lb_id: String = bc.ids.get("leaderboardId", "testLeaderboard")
	var response := await bc.bc_wrapper.social_leaderboard_service.get_player_scores(lb_id, -1, 10)
	bc.expect_status_ok(response)

func test_get_player_scores_from_leaderboards(bc: BCTest) -> void:
	bc.begin_test("test_get_player_scores_from_leaderboards")
	var lb_id: String = bc.ids.get("leaderboardId", "testLeaderboard")
	var response := await bc.bc_wrapper.social_leaderboard_service.get_player_scores_from_leaderboards([lb_id])
	bc.expect_status_ok(response)

func test_remove_player_score(bc: BCTest) -> void:
	bc.begin_test("test_remove_player_score")
	var lb_id: String = bc.ids.get("leaderboardId", "testLeaderboard")
	var response := await bc.bc_wrapper.social_leaderboard_service.remove_player_score(lb_id, -1)
	bc.expect_status_ok(response)

func test_group_leaderboard_flow(bc: BCTest) -> void:
	bc.begin_test("test_group_leaderboard_create_group")
	var create_resp := await bc.bc_wrapper.group_service.create_group(
		"test", "test", false, {}, {}, {"test": "asdf"}, {}
	)
	bc.expect_status_ok(create_resp)
	var group_id: String = create_resp.get("data", {}).get("groupId", "")
	if group_id.is_empty():
		bc.expect_true(false, "groupId missing from create_group response")
		return

	var lb_id: String = bc.ids.get("leaderboardId", "testLeaderboard")

	bc.begin_test("test_get_group_leaderboard")
	var gl_resp := await bc.bc_wrapper.social_leaderboard_service.get_group_leaderboard(lb_id, group_id)
	var gl_status: int = gl_resp.get("status", -1)
	bc.expect_true(
		gl_status == StatusCodes.OK or gl_status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % gl_status
	)

	bc.begin_test("test_get_group_leaderboard_view")
	var glv_resp := await bc.bc_wrapper.social_leaderboard_service.get_group_leaderboard_view(
		lb_id, group_id, "HIGH_TO_LOW", 5, 5
	)
	var glv_status: int = glv_resp.get("status", -1)
	bc.expect_true(
		glv_status == StatusCodes.OK or glv_status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % glv_status
	)

	bc.begin_test("test_remove_group_score")
	var rgs_resp := await bc.bc_wrapper.social_leaderboard_service.remove_group_score(lb_id, group_id, 0, -1)
	var rgs_status: int = rgs_resp.get("status", -1)
	bc.expect_true(
		rgs_status == StatusCodes.OK or rgs_status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % rgs_status
	)

	bc.begin_test("test_delete_group_for_leaderboard_cleanup")
	var del_resp := await bc.bc_wrapper.group_service.delete_group(group_id, -1)
	bc.expect_status_ok(del_resp)
