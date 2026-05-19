# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

var _entity_id: String = ""
var _entity_version: int = 1

func run(bc: BCTest) -> void:
	await test_create_entity(bc)
	await test_read_entity(bc)
	await test_update_entity(bc)
	await test_update_entity_fields(bc)
	await test_increment_entity_data(bc)
	await test_count_entities_where(bc)
	await test_get_entity_page(bc)
	await test_get_entity_page_offset(bc)
	await test_get_random_entities_matching(bc)
	await test_singleton_flow(bc)
	await test_delete_entity(bc)

func test_create_entity(bc: BCTest) -> void:
	bc.begin_test("test_create_entity")
	var entity_type: String = bc.ids.get("customEntityType", "testCustomEntity")
	var response := await bc.bc_wrapper.custom_entity_service.create_entity(
		entity_type, {"val": 1, "team": "RedTeam", "games": 0}, {"other": 1}, -1, false
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
	var entity_type: String = bc.ids.get("customEntityType", "testCustomEntity")
	var response := await bc.bc_wrapper.custom_entity_service.read_entity(entity_type, _entity_id)
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_update_entity(bc: BCTest) -> void:
	bc.begin_test("test_update_entity")
	if _entity_id.is_empty():
		bc.expect_true(false, "entity_id not set from create")
		return
	var entity_type: String = bc.ids.get("customEntityType", "testCustomEntity")
	var response := await bc.bc_wrapper.custom_entity_service.update_entity(
		entity_type, _entity_id, -1, {"val": 2, "team": "BlueTeam", "games": 1}, {"other": 1}, -1
	)
	bc.expect_status_ok(response)
	_entity_version = response.get("data", {}).get("version", _entity_version)

func test_update_entity_fields(bc: BCTest) -> void:
	bc.begin_test("test_update_entity_fields")
	if _entity_id.is_empty():
		bc.expect_true(false, "entity_id not set from create")
		return
	var entity_type: String = bc.ids.get("customEntityType", "testCustomEntity")
	var response := await bc.bc_wrapper.custom_entity_service.update_entity_fields(
		entity_type, _entity_id, -1, {"val": 3, "updated": true}
	)
	bc.expect_status_ok(response)
	_entity_version = response.get("data", {}).get("version", _entity_version)

func test_increment_entity_data(bc: BCTest) -> void:
	bc.begin_test("test_increment_entity_data")
	if _entity_id.is_empty():
		bc.expect_true(true, "skipping — no entity_id")
		return
	var entity_type: String = bc.ids.get("customEntityType", "testCustomEntity")
	var response := await bc.bc_wrapper.custom_entity_service.increment_entity_data(
		entity_type, _entity_id, {"games": 2}
	)
	bc.expect_status_ok(response)

func test_count_entities_where(bc: BCTest) -> void:
	bc.begin_test("test_count_entities_where")
	var entity_type: String = bc.ids.get("customEntityType", "testCustomEntity")
	var response := await bc.bc_wrapper.custom_entity_service.count_entities_where(entity_type, {})
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_get_entity_page(bc: BCTest) -> void:
	bc.begin_test("test_get_entity_page")
	var entity_type: String = bc.ids.get("customEntityType", "testCustomEntity")
	var context := {
		"pagination": {"rowsPerPage": 10, "pageNumber": 1},
		"searchCriteria": {},
		"sortCriteria": {}
	}
	var response := await bc.bc_wrapper.custom_entity_service.get_entity_page(entity_type, context)
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_get_entity_page_offset(bc: BCTest) -> void:
	bc.begin_test("test_get_entity_page_offset")
	var entity_type: String = bc.ids.get("customEntityType", "testCustomEntity")
	var context := {
		"pagination": {"rowsPerPage": 10, "pageNumber": 1},
		"searchCriteria": {},
		"sortCriteria": {}
	}
	var context_str := Marshalls.utf8_to_base64(JSON.stringify(context))
	var response := await bc.bc_wrapper.custom_entity_service.get_entity_page_offset(
		entity_type, context_str, 1
	)
	bc.expect_status_ok(response)

func test_get_random_entities_matching(bc: BCTest) -> void:
	bc.begin_test("test_get_random_entities_matching")
	var entity_type: String = bc.ids.get("customEntityType", "testCustomEntity")
	var response := await bc.bc_wrapper.custom_entity_service.get_random_entities_matching(
		entity_type, {}, 5
	)
	bc.expect_status_ok(response)

func test_singleton_flow(bc: BCTest) -> void:
	var entity_type: String = bc.ids.get("customEntityType", "testCustomEntity")

	bc.begin_test("test_update_singleton")
	var update_resp := await bc.bc_wrapper.custom_entity_service.update_singleton(
		entity_type, -1, {"singletonVal": 1}, {"other": 1}, -1
	)
	var u_status: int = update_resp.get("status", -1)
	bc.expect_true(
		u_status == StatusCodes.OK or u_status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % u_status
	)

	if u_status == StatusCodes.OK:
		bc.begin_test("test_read_singleton")
		var read_resp := await bc.bc_wrapper.custom_entity_service.read_singleton(entity_type)
		bc.expect_status_ok(read_resp)

		bc.begin_test("test_delete_singleton")
		var delete_resp := await bc.bc_wrapper.custom_entity_service.delete_singleton(entity_type, -1)
		bc.expect_status_ok(delete_resp)

func test_delete_entity(bc: BCTest) -> void:
	bc.begin_test("test_delete_entity")
	if _entity_id.is_empty():
		bc.expect_true(false, "entity_id not set from create")
		return
	var entity_type: String = bc.ids.get("customEntityType", "testCustomEntity")
	var response := await bc.bc_wrapper.custom_entity_service.delete_entity(entity_type, _entity_id, -1)
	bc.expect_status_ok(response)
	_entity_id = ""
