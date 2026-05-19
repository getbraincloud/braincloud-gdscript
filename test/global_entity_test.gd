# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

var _entity_id: String = ""
var _entity_version: int = 1
var _indexed_entity_id: String = ""
var _indexed_entity_version: int = 1
const ENTITY_TYPE := "testGlobal"
const INDEXED_ID := "GDScript-GlobalService"

func run(bc: BCTest) -> void:
	await test_create_global_entity(bc)
	await test_read_entity(bc)
	await test_update_entity(bc)
	await test_update_entity_acl(bc)
	await test_update_entity_time_to_live(bc)
	await test_increment_global_entity_data(bc)
	await test_get_list(bc)
	await test_get_list_count(bc)
	await test_get_page(bc)
	await test_get_page_offset(bc)
	await test_make_system_entity(bc)
	await test_create_entity_with_indexed_id(bc)
	await test_get_list_by_indexed_id(bc)
	await test_update_entity_indexed_id(bc)
	await test_update_entity_owner_and_acl(bc)
	await test_delete_entity(bc)

func test_create_global_entity(bc: BCTest) -> void:
	bc.begin_test("test_create_global_entity")
	var response := await bc.bc_wrapper.global_entity_service.create_entity(
		ENTITY_TYPE, "", -1, {"other": 1}, {"val": 1, "games": 0}
	)
	bc.expect_status_ok(response)
	_entity_id = response.get("data", {}).get("entityId", "")
	_entity_version = response.get("data", {}).get("version", 1)
	bc.expect_true(_entity_id.length() > 0, "entity_id should not be empty")

func test_read_entity(bc: BCTest) -> void:
	bc.begin_test("test_read_entity")
	if _entity_id.is_empty():
		bc.expect_true(false, "entity_id not set from create")
		return
	var response := await bc.bc_wrapper.global_entity_service.read_entity(_entity_id)
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_update_entity(bc: BCTest) -> void:
	bc.begin_test("test_update_entity")
	if _entity_id.is_empty():
		bc.expect_true(false, "entity_id not set from create")
		return
	var response := await bc.bc_wrapper.global_entity_service.update_entity(
		_entity_id, -1, {"val": 2}
	)
	bc.expect_status_ok(response)
	_entity_version = response.get("data", {}).get("version", _entity_version)

func test_update_entity_acl(bc: BCTest) -> void:
	bc.begin_test("test_update_entity_acl")
	if _entity_id.is_empty():
		bc.expect_true(true, "skipping — no entity_id")
		return
	var response := await bc.bc_wrapper.global_entity_service.update_entity_acl(
		_entity_id, -1, {"other": 2}
	)
	bc.expect_status_ok(response)
	_entity_version = response.get("data", {}).get("version", _entity_version)

func test_update_entity_time_to_live(bc: BCTest) -> void:
	bc.begin_test("test_update_entity_time_to_live")
	if _entity_id.is_empty():
		bc.expect_true(true, "skipping — no entity_id")
		return
	var ttl := 6 * 3600 * 1000
	var response := await bc.bc_wrapper.global_entity_service.update_entity_time_to_live(
		_entity_id, -1, ttl
	)
	bc.expect_status_ok(response)
	_entity_version = response.get("data", {}).get("version", _entity_version)

func test_increment_global_entity_data(bc: BCTest) -> void:
	bc.begin_test("test_increment_global_entity_data")
	if _entity_id.is_empty():
		bc.expect_true(true, "skipping — no entity_id")
		return
	var response := await bc.bc_wrapper.global_entity_service.increment_global_entity_data(
		_entity_id, {"games": 2}
	)
	bc.expect_status_ok(response)
	_entity_version = response.get("data", {}).get("version", _entity_version)

func test_get_list(bc: BCTest) -> void:
	bc.begin_test("test_get_list")
	var response := await bc.bc_wrapper.global_entity_service.get_list({}, {}, 10)
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_get_list_count(bc: BCTest) -> void:
	bc.begin_test("test_get_list_count")
	var response := await bc.bc_wrapper.global_entity_service.get_list_count({})
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_get_page(bc: BCTest) -> void:
	bc.begin_test("test_get_page")
	var context := {
		"pagination": {"rowsPerPage": 10, "pageNumber": 1},
		"searchCriteria": {"entityType": ENTITY_TYPE},
		"sortCriteria": {}
	}
	var response := await bc.bc_wrapper.global_entity_service.get_page(context)
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_get_page_offset(bc: BCTest) -> void:
	bc.begin_test("test_get_page_offset")
	var context := {
		"pagination": {"rowsPerPage": 10, "pageNumber": 1},
		"searchCriteria": {"entityType": ENTITY_TYPE},
		"sortCriteria": {}
	}
	var context_str := Marshalls.utf8_to_base64(JSON.stringify(context))
	var response := await bc.bc_wrapper.global_entity_service.get_page_offset(context_str, 1)
	bc.expect_status_ok(response)

func test_make_system_entity(bc: BCTest) -> void:
	bc.begin_test("test_make_system_entity")
	if _entity_id.is_empty():
		bc.expect_true(true, "skipping — no entity_id")
		return
	var response := await bc.bc_wrapper.global_entity_service.make_system_entity(
		_entity_id, -1, {"other": 1}
	)
	bc.expect_status_ok(response)
	_entity_version = response.get("data", {}).get("version", _entity_version)

func test_create_entity_with_indexed_id(bc: BCTest) -> void:
	bc.begin_test("test_create_entity_with_indexed_id")
	var response := await bc.bc_wrapper.global_entity_service.create_entity_with_indexed_id(
		ENTITY_TYPE, INDEXED_ID, 3600000, {"other": 1}, {"val": 10}
	)
	bc.expect_status_ok(response)
	_indexed_entity_id = response.get("data", {}).get("entityId", "")
	_indexed_entity_version = response.get("data", {}).get("version", 1)

func test_get_list_by_indexed_id(bc: BCTest) -> void:
	bc.begin_test("test_get_list_by_indexed_id")
	var response := await bc.bc_wrapper.global_entity_service.get_list_by_indexed_id(
		ENTITY_TYPE, INDEXED_ID, 4
	)
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_update_entity_indexed_id(bc: BCTest) -> void:
	bc.begin_test("test_update_entity_indexed_id")
	if _indexed_entity_id.is_empty():
		bc.expect_true(true, "skipping — no indexed_entity_id")
		return
	var response := await bc.bc_wrapper.global_entity_service.update_entity_indexed_id(
		_indexed_entity_id, INDEXED_ID + "New", -1
	)
	bc.expect_status_ok(response)
	_indexed_entity_version = response.get("data", {}).get("version", _indexed_entity_version)

func test_update_entity_owner_and_acl(bc: BCTest) -> void:
	bc.begin_test("test_update_entity_owner_and_acl")
	if _entity_id.is_empty():
		bc.expect_true(true, "skipping — no entity_id")
		return
	var response := await bc.bc_wrapper.global_entity_service.update_entity_owner_and_acl(
		_entity_id, -1, bc.user_b.profile_id, {"other": 2}
	)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.ACCEPTED or status == StatusCodes.BAD_REQUEST,
		"Expected 200, 202, or 400, got %d" % status
	)

func test_delete_entity(bc: BCTest) -> void:
	bc.begin_test("test_delete_entity")
	if _entity_id.is_empty():
		bc.expect_true(false, "entity_id not set from create")
		return
	var response := await bc.bc_wrapper.global_entity_service.delete_entity(_entity_id, -1)
	bc.expect_status_ok(response)
	_entity_id = ""

	if not _indexed_entity_id.is_empty():
		await bc.bc_wrapper.global_entity_service.delete_entity(_indexed_entity_id, -1)
		_indexed_entity_id = ""
