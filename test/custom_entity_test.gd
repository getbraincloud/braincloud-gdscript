# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

var _entity_id: String = ""

func run(bc: BCTest) -> void:
	await test_create_entity(bc)
	await test_read_entity(bc)
	await test_update_entity(bc)
	await test_get_entity_page(bc)
	await test_delete_entity(bc)

func test_create_entity(bc: BCTest) -> void:
	bc.begin_test("test_create_entity")
	var entity_type: String = bc.ids.get("customEntityType", "testCustomEntity")
	var response := await bc.bc_wrapper.custom_entity_service.create_entity(
		entity_type, {"val": 1}, {"other": 1}, -1, false
	)
	bc.expect_status_ok(response)
	_entity_id = response.get("data", {}).get("entityId", "")
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
	var response := await bc.bc_wrapper.custom_entity_service.update_entity_fields(
		entity_type, _entity_id, -1, {"val": 2, "updated": true}
	)
	bc.expect_status_ok(response)

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

func test_delete_entity(bc: BCTest) -> void:
	bc.begin_test("test_delete_entity")
	if _entity_id.is_empty():
		bc.expect_true(false, "entity_id not set from create")
		return
	var entity_type: String = bc.ids.get("customEntityType", "testCustomEntity")
	var response := await bc.bc_wrapper.custom_entity_service.delete_entity(entity_type, _entity_id, -1)
	bc.expect_status_ok(response)
	_entity_id = ""
