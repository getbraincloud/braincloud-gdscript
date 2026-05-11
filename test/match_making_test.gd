# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_read(bc)
	await test_enable_match_making(bc)
	await test_set_player_rating(bc)
	await test_reset_player_rating(bc)

func test_read(bc: BCTest) -> void:
	bc.begin_test("test_read")
	var response := await bc.bc_wrapper.match_making_service.read()
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_enable_match_making(bc: BCTest) -> void:
	bc.begin_test("test_enable_match_making")
	var response := await bc.bc_wrapper.match_making_service.enable_match_making()
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)

func test_set_player_rating(bc: BCTest) -> void:
	bc.begin_test("test_set_player_rating")
	var response := await bc.bc_wrapper.match_making_service.set_player_rating(100)
	bc.expect_status_ok(response)

func test_reset_player_rating(bc: BCTest) -> void:
	bc.begin_test("test_reset_player_rating")
	var response := await bc.bc_wrapper.match_making_service.reset_player_rating()
	bc.expect_status_ok(response)
