# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_find_user_by_exact_universal_id(bc)
	await test_find_users_by_exact_name(bc)
	await test_list_friends(bc)
	await test_add_friends(bc)
	await test_remove_friends(bc)
	await test_get_users_online_status(bc)

func test_find_user_by_exact_universal_id(bc: BCTest) -> void:
	bc.begin_test("test_find_user_by_exact_universal_id")
	var response := await bc.bc_wrapper.friend_service.find_user_by_exact_universal_id(bc.user_b.name)
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_find_users_by_exact_name(bc: BCTest) -> void:
	bc.begin_test("test_find_users_by_exact_name")
	var response := await bc.bc_wrapper.friend_service.find_users_by_exact_name("UserB", 10)
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_list_friends(bc: BCTest) -> void:
	bc.begin_test("test_list_friends")
	var response := await bc.bc_wrapper.friend_service.list_friends("brainCloud", true)
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_add_friends(bc: BCTest) -> void:
	bc.begin_test("test_add_friends")
	var response := await bc.bc_wrapper.friend_service.add_friends([bc.user_b.profile_id])
	bc.expect_status_ok(response)

func test_remove_friends(bc: BCTest) -> void:
	bc.begin_test("test_remove_friends")
	var response := await bc.bc_wrapper.friend_service.remove_friends([bc.user_b.profile_id])
	bc.expect_status_ok(response)

func test_get_users_online_status(bc: BCTest) -> void:
	bc.begin_test("test_get_users_online_status")
	var response := await bc.bc_wrapper.friend_service.get_users_online_status([bc.user_b.profile_id])
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")
