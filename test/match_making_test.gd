# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_enable_match_making(bc)
	await test_disable_match_making(bc)
	await test_read(bc)
	await test_set_player_rating(bc)
	await test_reset_player_rating(bc)
	await test_increment_player_rating(bc)
	await test_decrement_player_rating(bc)
	await test_turn_shield_on(bc)
	await test_turn_shield_off(bc)
	await test_turn_shield_on_for(bc)
	await test_increment_shield_on_for(bc)
	await test_find_players(bc)
	await test_find_players_using_filter(bc)

func test_enable_match_making(bc: BCTest) -> void:
	bc.begin_test("test_enable_match_making")
	var response := await bc.bc_wrapper.match_making_service.enable_match_making()
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)

func test_disable_match_making(bc: BCTest) -> void:
	bc.begin_test("test_disable_match_making")
	var response := await bc.bc_wrapper.match_making_service.disable_match_making()
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)

func test_read(bc: BCTest) -> void:
	bc.begin_test("test_read")
	var response := await bc.bc_wrapper.match_making_service.read()
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_set_player_rating(bc: BCTest) -> void:
	bc.begin_test("test_set_player_rating")
	var response := await bc.bc_wrapper.match_making_service.set_player_rating(100)
	bc.expect_status_ok(response)

func test_reset_player_rating(bc: BCTest) -> void:
	bc.begin_test("test_reset_player_rating")
	var response := await bc.bc_wrapper.match_making_service.reset_player_rating()
	bc.expect_status_ok(response)

func test_increment_player_rating(bc: BCTest) -> void:
	bc.begin_test("test_increment_player_rating")
	var response := await bc.bc_wrapper.match_making_service.increment_player_rating(10)
	bc.expect_status_ok(response)

func test_decrement_player_rating(bc: BCTest) -> void:
	bc.begin_test("test_decrement_player_rating")
	var response := await bc.bc_wrapper.match_making_service.decrement_player_rating(5)
	bc.expect_status_ok(response)

func test_turn_shield_on(bc: BCTest) -> void:
	bc.begin_test("test_turn_shield_on")
	var response := await bc.bc_wrapper.match_making_service.turn_shield_on()
	bc.expect_status_ok(response)

func test_turn_shield_off(bc: BCTest) -> void:
	bc.begin_test("test_turn_shield_off")
	var response := await bc.bc_wrapper.match_making_service.turn_shield_off()
	bc.expect_status_ok(response)

func test_turn_shield_on_for(bc: BCTest) -> void:
	bc.begin_test("test_turn_shield_on_for")
	var response := await bc.bc_wrapper.match_making_service.turn_shield_on_for(1)
	bc.expect_status_ok(response)
	# Turn it off for cleanup
	await bc.bc_wrapper.match_making_service.turn_shield_off()

func test_increment_shield_on_for(bc: BCTest) -> void:
	bc.begin_test("test_increment_shield_on_for")
	await bc.bc_wrapper.match_making_service.turn_shield_on_for(1)
	var response := await bc.bc_wrapper.match_making_service.increment_shield_on_for(1)
	bc.expect_status_ok(response)
	await bc.bc_wrapper.match_making_service.turn_shield_off()

func test_find_players(bc: BCTest) -> void:
	bc.begin_test("test_find_players")
	var response := await bc.bc_wrapper.match_making_service.find_players(100, 4)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)

func test_find_players_using_filter(bc: BCTest) -> void:
	bc.begin_test("test_find_players_using_filter")
	var response := await bc.bc_wrapper.match_making_service.find_players_using_filter(100, 4, {})
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)
