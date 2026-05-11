# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

var _friend_id: String = ""

func run(bc: BCTest) -> void:
	await test_get_profile_info_for_credential(bc)
	await test_get_profile_info_for_external_auth_id(bc)
	await test_get_external_id_for_profile_id(bc)
	await test_get_summary_data_for_profile_id(bc)
	await test_find_users_by_exact_name(bc)
	await test_find_users_by_substr_name(bc)
	await test_add_friends(bc)
	await test_add_friends_from_platform(bc)
	await test_list_friends(bc)
	await test_get_my_social_info(bc)
	await test_read_friend_entity(bc)
	await test_read_friend_user_state(bc)
	await test_read_friends_entities(bc)
	await test_remove_friends(bc)
	await test_get_users_online_status(bc)
	await test_find_users_by_universal_id_starting_with(bc)
	await test_find_users_by_name_starting_with(bc)
	await test_find_user_by_exact_universal_id(bc)

func test_get_profile_info_for_credential(bc: BCTest) -> void:
	bc.begin_test("test_get_profile_info_for_credential")
	var response := await bc.bc_wrapper.friend_service.get_profile_info_for_credential(bc.user_a.name, AuthenticationType.UNIVERSAL)
	bc.expect_status_ok(response)

func test_get_profile_info_for_external_auth_id(bc: BCTest) -> void:
	bc.begin_test("test_get_profile_info_for_external_auth_id")
	var response := await bc.bc_wrapper.friend_service.get_profile_info_for_external_auth_id("externalId", "Test")
	var status: int = response.get("status", -1)
	bc.expect_true(status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status)

func test_get_external_id_for_profile_id(bc: BCTest) -> void:
	bc.begin_test("test_get_external_id_for_profile_id")
	var response := await bc.bc_wrapper.friend_service.get_external_id_for_profile_id(bc.user_a.profile_id, AuthenticationType.FACEBOOK)
	bc.expect_status_ok(response)

func test_get_summary_data_for_profile_id(bc: BCTest) -> void:
	bc.begin_test("test_get_summary_data_for_profile_id")
	var response := await bc.bc_wrapper.friend_service.get_summary_data_for_profile_id(bc.user_a.profile_id)
	bc.expect_status_ok(response)

func test_find_users_by_exact_name(bc: BCTest) -> void:
	bc.begin_test("test_find_users_by_exact_name")
	var response := await bc.bc_wrapper.friend_service.find_users_by_exact_name("NotAUser", 10)
	bc.expect_status_ok(response)

func test_find_users_by_substr_name(bc: BCTest) -> void:
	bc.begin_test("test_find_users_by_substr_name")
	var response := await bc.bc_wrapper.friend_service.find_users_by_substr_name("NotAUser", 10)
	bc.expect_status_ok(response)

func test_add_friends(bc: BCTest) -> void:
	bc.begin_test("test_add_friends")
	var response := await bc.bc_wrapper.friend_service.add_friends([bc.user_b.profile_id])
	bc.expect_status_ok(response)
	_friend_id = bc.user_b.profile_id

func test_add_friends_from_platform(bc: BCTest) -> void:
	bc.begin_test("test_add_friends_from_platform")
	var response := await bc.bc_wrapper.friend_service.add_friends_from_platform("Facebook", "ADD", [])
	bc.expect_status_ok(response)

func test_list_friends(bc: BCTest) -> void:
	bc.begin_test("test_list_friends")
	var response := await bc.bc_wrapper.friend_service.list_friends("All", false)
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_get_my_social_info(bc: BCTest) -> void:
	bc.begin_test("test_get_my_social_info")
	var response := await bc.bc_wrapper.friend_service.get_my_social_info("Facebook", false)
	bc.expect_status_ok(response)

func test_read_friend_entity(bc: BCTest) -> void:
	bc.begin_test("test_read_friend_entity")
	if _friend_id.is_empty():
		await bc.bc_wrapper.friend_service.add_friends([bc.user_b.profile_id])
		_friend_id = bc.user_b.profile_id
	var response := await bc.bc_wrapper.friend_service.read_friend_entity("", bc.user_b.profile_id)
	bc.expect_status_ok(response)

func test_read_friend_user_state(bc: BCTest) -> void:
	bc.begin_test("test_read_friend_user_state")
	if _friend_id.is_empty():
		await bc.bc_wrapper.friend_service.add_friends([bc.user_b.profile_id])
		_friend_id = bc.user_b.profile_id
	var response := await bc.bc_wrapper.friend_service.read_friend_user_state(_friend_id)
	bc.expect_status_ok(response)

func test_read_friends_entities(bc: BCTest) -> void:
	bc.begin_test("test_read_friends_entities")
	if _friend_id.is_empty():
		await bc.bc_wrapper.friend_service.add_friends([bc.user_b.profile_id])
		_friend_id = bc.user_b.profile_id
	var response := await bc.bc_wrapper.friend_service.read_friends_entities("Test")
	bc.expect_status_ok(response)

func test_remove_friends(bc: BCTest) -> void:
	bc.begin_test("test_remove_friends")
	if _friend_id.is_empty():
		await bc.bc_wrapper.friend_service.add_friends([bc.user_b.profile_id])
		_friend_id = bc.user_b.profile_id
	var response := await bc.bc_wrapper.friend_service.remove_friends([_friend_id])
	bc.expect_status_ok(response)

func test_get_users_online_status(bc: BCTest) -> void:
	bc.begin_test("test_get_users_online_status")
	var response := await bc.bc_wrapper.friend_service.get_users_online_status([bc.user_b.profile_id])
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_find_users_by_universal_id_starting_with(bc: BCTest) -> void:
	bc.begin_test("test_find_users_by_universal_id_starting_with")
	var response := await bc.bc_wrapper.friend_service.find_users_by_universal_id_starting_with("completelyRandomName", 30)
	bc.expect_status_ok(response)

func test_find_users_by_name_starting_with(bc: BCTest) -> void:
	bc.begin_test("test_find_users_by_name_starting_with")
	var response := await bc.bc_wrapper.friend_service.find_user_by_name_starting_with("completelyRandomUniversalId", 30)
	bc.expect_status_ok(response)

func test_find_user_by_exact_universal_id(bc: BCTest) -> void:
	bc.begin_test("test_find_user_by_exact_universal_id")
	var response := await bc.bc_wrapper.friend_service.find_user_by_exact_universal_id(bc.user_b.name)
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")
