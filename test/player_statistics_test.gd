# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_read_all_user_stats(bc)
	await test_increment_user_stats(bc)
	await test_reset_all_user_stats(bc)

func test_read_all_user_stats(bc: BCTest) -> void:
	bc.begin_test("test_read_all_user_stats")
	var response := await bc.bc_wrapper.player_statistics_service.read_all_user_stats()
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_increment_user_stats(bc: BCTest) -> void:
	bc.begin_test("test_increment_user_stats")
	var response := await bc.bc_wrapper.player_statistics_service.increment_user_stats({"GAMES_PLAYED": 1})
	bc.expect_status_ok(response)

func test_reset_all_user_stats(bc: BCTest) -> void:
	bc.begin_test("test_reset_all_user_stats")
	var response := await bc.bc_wrapper.player_statistics_service.reset_all_user_stats()
	bc.expect_status_ok(response)
