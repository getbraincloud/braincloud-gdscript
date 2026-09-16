# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_read_all_gamification(bc)
	await test_read_milestones(bc)
	await test_read_achievements(bc)
	await test_read_achieved_achievements(bc)
	await test_read_milestones_by_category(bc)
	await test_award_achievements(bc)
	await test_read_xp_levels(bc)
	await test_read_completed_quests(bc)
	await test_read_in_progress_quests(bc)
	await test_read_quests_by_status(bc)
	await test_read_quests_by_category(bc)
	await test_read_quests_with_status(bc)
	await test_reset_milestones(bc)

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

func test_read_achieved_achievements(bc: BCTest) -> void:
	bc.begin_test("test_read_achieved_achievements")
	var response := await bc.bc_wrapper.gamification_service.read_achieved_achievements(true)
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_read_milestones_by_category(bc: BCTest) -> void:
	bc.begin_test("test_read_milestones_by_category")
	var response := await bc.bc_wrapper.gamification_service.read_milestones_by_category("general", true)
	bc.expect_status_ok(response)

func test_award_achievements(bc: BCTest) -> void:
	bc.begin_test("test_award_achievements")
	var response := await bc.bc_wrapper.gamification_service.award_achievements(["testAchievement01"])
	bc.expect_status_ok(response)

func test_read_xp_levels(bc: BCTest) -> void:
	bc.begin_test("test_read_xp_levels")
	var response := await bc.bc_wrapper.gamification_service.read_xp_levels_meta_data()
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_read_completed_quests(bc: BCTest) -> void:
	bc.begin_test("test_read_completed_quests")
	var response := await bc.bc_wrapper.gamification_service.read_completed_quests(true)
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_read_in_progress_quests(bc: BCTest) -> void:
	bc.begin_test("test_read_in_progress_quests")
	var response := await bc.bc_wrapper.gamification_service.read_in_progress_quests(true)
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_read_quests_by_status(bc: BCTest) -> void:
	bc.begin_test("test_read_quests_by_status")
	var response := await bc.bc_wrapper.gamification_service.read_quests_by_status("Incomplete", true)
	bc.expect_status_ok(response)

func test_read_quests_by_category(bc: BCTest) -> void:
	bc.begin_test("test_read_quests_by_category")
	var response := await bc.bc_wrapper.gamification_service.read_quests_by_category("general", true)
	bc.expect_status_ok(response)

func test_read_quests_with_status(bc: BCTest) -> void:
	bc.begin_test("test_read_quests_with_status")
	var response := await bc.bc_wrapper.gamification_service.read_quests_with_status(true)
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_reset_milestones(bc: BCTest) -> void:
	bc.begin_test("test_reset_milestones")
	var response := await bc.bc_wrapper.gamification_service.reset_milestones([])
	bc.expect_status_ok(response)
