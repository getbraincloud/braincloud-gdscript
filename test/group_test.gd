# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

var _group_id: String = ""

func run(bc: BCTest) -> void:
	await test_create_group(bc)
	await test_read_group(bc)
	await test_get_my_groups(bc)
	await test_list_groups(bc)
	await test_update_group_data(bc)
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

func test_update_group_data(bc: BCTest) -> void:
	bc.begin_test("test_update_group_data")
	if _group_id.is_empty():
		bc.expect_true(false, "group_id not set from create")
		return
	var response := await bc.bc_wrapper.group_service.update_group_data(
		_group_id, -1, {"updated": true, "score": 100}
	)
	bc.expect_status_ok(response)

func test_delete_group(bc: BCTest) -> void:
	bc.begin_test("test_delete_group")
	if _group_id.is_empty():
		bc.expect_true(false, "group_id not set from create")
		return
	var response := await bc.bc_wrapper.group_service.delete_group(_group_id, -1)
	bc.expect_status_ok(response)
	_group_id = ""
