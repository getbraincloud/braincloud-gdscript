# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_get_next_experience_level(bc)
	await test_increment_experience_points(bc)
	await test_increment_user_stats(bc)
	await test_read_all_user_stats(bc)
	await test_read_user_stats_subset(bc)
	await test_read_user_stats_for_category(bc)
	await test_reset_all_user_stats(bc)
	await test_set_experience_points(bc)
	await test_process_statistics(bc)

func test_get_next_experience_level(bc: BCTest) -> void:
	bc.begin_test("test_get_next_experience_level")
	var response := await bc.bc_wrapper.player_statistics_service.get_next_experience_level()
	bc.expect_status_ok(response)

func test_increment_experience_points(bc: BCTest) -> void:
	bc.begin_test("test_increment_experience_points")
	var response := await bc.bc_wrapper.player_statistics_service.increment_experience_points(100)
	bc.expect_status_ok(response)

func test_increment_user_stats(bc: BCTest) -> void:
	bc.begin_test("test_increment_user_stats")
	var response := await bc.bc_wrapper.player_statistics_service.increment_user_stats({"wins": 10, "losses": 4})
	bc.expect_status_ok(response)

func test_read_all_user_stats(bc: BCTest) -> void:
	bc.begin_test("test_read_all_user_stats")
	var response := await bc.bc_wrapper.player_statistics_service.read_all_user_stats()
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_read_user_stats_subset(bc: BCTest) -> void:
	bc.begin_test("test_read_user_stats_subset")
	var response := await bc.bc_wrapper.player_statistics_service.read_user_stats_subset(["wins"])
	bc.expect_status_ok(response)

func test_read_user_stats_for_category(bc: BCTest) -> void:
	bc.begin_test("test_read_user_stats_for_category")
	var response := await bc.bc_wrapper.player_statistics_service.read_user_stats_for_category("Test")
	bc.expect_status_ok(response)

func test_reset_all_user_stats(bc: BCTest) -> void:
	bc.begin_test("test_reset_all_user_stats")
	var response := await bc.bc_wrapper.player_statistics_service.reset_all_user_stats()
	bc.expect_status_ok(response)

func test_set_experience_points(bc: BCTest) -> void:
	bc.begin_test("test_set_experience_points")
	var response := await bc.bc_wrapper.player_statistics_service.set_experience_points(50)
	bc.expect_status_ok(response)

func test_process_statistics(bc: BCTest) -> void:
	bc.begin_test("test_process_statistics")
	var response := await bc.bc_wrapper.player_statistics_service.process_statistics({"gamesPlayed": 1, "gamesWon": 1, "gamesLost": 2})
	bc.expect_status_ok(response)
