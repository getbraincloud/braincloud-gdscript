# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

var _group_id: String = ""
var _entity_id: String = ""

func run(bc: BCTest) -> void:
	await test_create_group(bc)
	await test_read_group(bc)
	await test_get_my_groups(bc)
	await test_list_groups(bc)
	await test_list_groups_with_member(bc)
	await test_update_group_data(bc)
	await test_update_group_name(bc)
	await test_read_group_members(bc)
	await test_invite_and_cancel(bc)
	await test_add_and_remove_member(bc)
	await test_group_entity_flow(bc)
	await test_delete_group(bc)

func test_create_group(bc: BCTest) -> void:
	bc.begin_test("test_create_group")
	var response := await bc.bc_wrapper.group_service.create_group(
		"TestGroup", "test", false, {"other": 1}, {}, {"description": "GDScript test group"}, {}
	)
	bc.expect_status_ok(response)
	_group_id = response.get("data", {}).get("groupId", "")
	bc.expect_true(_group_id.length() > 0, "group_id should not be empty")

func test_read_group(bc: BCTest) -> void:
	bc.begin_test("test_read_group")
	if _group_id.is_empty():
		bc.expect_true(false, "group_id not set from create")
		return
	var response := await bc.bc_wrapper.group_service.read_group(_group_id)
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_get_my_groups(bc: BCTest) -> void:
	bc.begin_test("test_get_my_groups")
	var response := await bc.bc_wrapper.group_service.get_my_groups()
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_list_groups(bc: BCTest) -> void:
	bc.begin_test("test_list_groups")
	var response := await bc.bc_wrapper.group_service.list_groups_page({
		"pagination": {"rowsPerPage": 10, "pageNumber": 1},
		"searchCriteria": {"groupType": "test"},
		"sortCriteria": {}
	})
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_list_groups_with_member(bc: BCTest) -> void:
	bc.begin_test("test_list_groups_with_member")
	var response := await bc.bc_wrapper.group_service.list_groups_with_member(bc.user_a.profile_id)
	bc.expect_status_ok(response)

func test_update_group_data(bc: BCTest) -> void:
	bc.begin_test("test_update_group_data")
	if _group_id.is_empty():
		bc.expect_true(false, "group_id not set from create")
		return
	var response := await bc.bc_wrapper.group_service.update_group_data(
		_group_id, -1, {"updated": true, "score": 100}
	)
	bc.expect_status_ok(response)

func test_update_group_name(bc: BCTest) -> void:
	bc.begin_test("test_update_group_name")
	if _group_id.is_empty():
		bc.expect_true(true, "group_id not set, skipping")
		return
	var response := await bc.bc_wrapper.group_service.update_group_name(_group_id, "TestGroupRenamed")
	bc.expect_status_ok(response)

func test_read_group_members(bc: BCTest) -> void:
	bc.begin_test("test_read_group_members")
	if _group_id.is_empty():
		bc.expect_true(true, "group_id not set, skipping")
		return
	var response := await bc.bc_wrapper.group_service.read_group_members(_group_id)
	bc.expect_status_ok(response)

func test_invite_and_cancel(bc: BCTest) -> void:
	if _group_id.is_empty():
		return
	bc.begin_test("test_invite_group_member")
	var invite_resp := await bc.bc_wrapper.group_service.invite_group_member(
		_group_id, bc.user_b.profile_id, "MEMBER", {}
	)
	bc.expect_status_ok(invite_resp)

	bc.begin_test("test_cancel_group_invitation")
	var cancel_resp := await bc.bc_wrapper.group_service.cancel_group_invitation(
		_group_id, bc.user_b.profile_id
	)
	bc.expect_status_ok(cancel_resp)

func test_add_and_remove_member(bc: BCTest) -> void:
	if _group_id.is_empty():
		return
	bc.begin_test("test_add_group_member")
	var add_resp := await bc.bc_wrapper.group_service.add_group_member(
		_group_id, bc.user_b.profile_id, "MEMBER", {}
	)
	bc.expect_status_ok(add_resp)

	bc.begin_test("test_update_group_member")
	var update_resp := await bc.bc_wrapper.group_service.update_group_member(
		_group_id, bc.user_b.profile_id, "MEMBER", {"updatedAt": 1}
	)
	bc.expect_status_ok(update_resp)

	bc.begin_test("test_remove_group_member")
	var remove_resp := await bc.bc_wrapper.group_service.remove_group_member(
		_group_id, bc.user_b.profile_id
	)
	bc.expect_status_ok(remove_resp)

func test_group_entity_flow(bc: BCTest) -> void:
	if _group_id.is_empty():
		return
	bc.begin_test("test_create_group_entity")
	var create_resp := await bc.bc_wrapper.group_service.create_group_entity(
		_group_id, "test_entity", true, {"other": 1}, {"entityData": "value"}
	)
	bc.expect_status_ok(create_resp)
	_entity_id = create_resp.get("data", {}).get("entityId", "")
	if _entity_id.is_empty():
		return

	bc.begin_test("test_read_group_entity")
	var read_resp := await bc.bc_wrapper.group_service.read_group_entity(_group_id, _entity_id)
	bc.expect_status_ok(read_resp)

	bc.begin_test("test_update_group_entity_data")
	var update_resp := await bc.bc_wrapper.group_service.update_group_entity_data(
		_group_id, _entity_id, -1, {"updated": true}
	)
	bc.expect_status_ok(update_resp)

	bc.begin_test("test_read_group_entities")
	var list_resp := await bc.bc_wrapper.group_service.read_group_entities(_group_id)
	bc.expect_status_ok(list_resp)

	bc.begin_test("test_delete_group_entity")
	var delete_resp := await bc.bc_wrapper.group_service.delete_group_entity(_group_id, _entity_id, -1)
	bc.expect_status_ok(delete_resp)
	_entity_id = ""

func test_delete_group(bc: BCTest) -> void:
	bc.begin_test("test_delete_group")
	if _group_id.is_empty():
		bc.expect_true(false, "group_id not set from create")
		return
	var response := await bc.bc_wrapper.group_service.delete_group(_group_id, -1)
	bc.expect_status_ok(response)
	_group_id = ""
