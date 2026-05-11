# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_read_all_gamification(bc)
	await test_read_milestones(bc)
	await test_read_achievements(bc)
	await test_read_xp_levels(bc)

func test_read_all_gamification(bc: BCTest) -> void:
	bc.begin_test("test_read_all_gamification")
	var response := await bc.bc_wrapper.gamification_service.read_all_gamification(true)
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_read_milestones(bc: BCTest) -> void:
	bc.begin_test("test_read_milestones")
	var response := await bc.bc_wrapper.gamification_service.read_milestones(true)
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_read_achievements(bc: BCTest) -> void:
	bc.begin_test("test_read_achievements")
	var response := await bc.bc_wrapper.gamification_service.read_achievements(true)
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_read_xp_levels(bc: BCTest) -> void:
	bc.begin_test("test_read_xp_levels")
	var response := await bc.bc_wrapper.gamification_service.read_xp_levels_meta()
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")
