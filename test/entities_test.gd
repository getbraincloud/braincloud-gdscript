# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

var _entity_id: String = ""

func run(bc: BCTest) -> void:
	await test_create_entity(bc)
	await test_get_entity(bc)
	await test_update_entity(bc)
	await test_get_entities_by_type(bc)
	await test_get_page(bc)
	await test_singleton(bc)
	await test_delete_entity(bc)

func test_create_entity(bc: BCTest) -> void:
	bc.begin_test("test_create_entity")
	var acl := {"other": 2}
	var data := {"testKey": "testValue", "number": 42}
	var response := await bc.bc_wrapper.entity_service.create_entity(bc.entity_type, data, acl)
	bc.expect_status_ok(response)
	_entity_id = response.get("data", {}).get("entityId", "")
	bc.expect_true(_entity_id.length() > 0, "entity_id should not be empty")

func test_get_entity(bc: BCTest) -> void:
	bc.begin_test("test_get_entity")
	if _entity_id.is_empty():
		bc.expect_true(false, "entity_id not set from create")
		return
	var response := await bc.bc_wrapper.entity_service.get_entity(_entity_id)
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_update_entity(bc: BCTest) -> void:
	bc.begin_test("test_update_entity")
	if _entity_id.is_empty():
		bc.expect_true(false, "entity_id not set from create")
		return
	var new_data := {"testKey": "updatedValue", "number": 99}
	var acl := {"other": 2}
	var response := await bc.bc_wrapper.entity_service.update_entity(_entity_id, bc.entity_type, new_data, acl, -1)
	bc.expect_status_ok(response)

func test_get_entities_by_type(bc: BCTest) -> void:
	bc.begin_test("test_get_entities_by_type")
	var response := await bc.bc_wrapper.entity_service.get_entities_by_type(bc.entity_type)
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_get_page(bc: BCTest) -> void:
	bc.begin_test("test_get_page")
	var context := {
		"pagination": {"rowsPerPage": 10, "pageNumber": 1},
		"searchCriteria": {"entityType": bc.entity_type},
		"sortCriteria": {}
	}
	var response := await bc.bc_wrapper.entity_service.get_page(context)
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_singleton(bc: BCTest) -> void:
	bc.begin_test("test_singleton")
	var data := {"singletonKey": "singletonValue"}
	var acl := {"other": 1}
	var update_resp := await bc.bc_wrapper.entity_service.update_singleton(bc.entity_type, data, acl, -1)
	bc.expect_status_ok(update_resp)

	var get_resp := await bc.bc_wrapper.entity_service.get_singleton(bc.entity_type)
	bc.expect_status_ok(get_resp)

	var delete_resp := await bc.bc_wrapper.entity_service.delete_singleton(bc.entity_type, -1)
	bc.expect_status_ok(delete_resp)

func test_delete_entity(bc: BCTest) -> void:
	bc.begin_test("test_delete_entity")
	if _entity_id.is_empty():
		bc.expect_true(false, "entity_id not set from create")
		return
	var response := await bc.bc_wrapper.entity_service.delete_entity(_entity_id, -1)
	bc.expect_status_ok(response)
	_entity_id = ""
