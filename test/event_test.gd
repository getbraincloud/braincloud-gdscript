# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

var _event_id: String = ""

func run(bc: BCTest) -> void:
	await test_update_incoming_event_data_if_exists_false(bc)
	await test_send_event(bc)
	await test_update_event_data(bc)
	await test_update_incoming_event_data_if_exists_true(bc)
	await test_delete_incoming_event(bc)
	await test_get_events(bc)
	await test_delete_incoming_events(bc)
	await test_delete_incoming_events_by_type_older_than(bc)
	await test_delete_incoming_events_older_than(bc)

func test_update_incoming_event_data_if_exists_false(bc: BCTest) -> void:
	bc.begin_test("test_update_incoming_event_data_if_exists_false")
	var non_existent_id := "999999999999999999999999"
	var response := await bc.bc_wrapper.event_service.update_incoming_event_data_if_exists(
		non_existent_id, {"testData": 118}
	)
	bc.expect_status_ok(response)

func test_send_event(bc: BCTest) -> void:
	bc.begin_test("test_send_event")
	var response := await bc.bc_wrapper.event_service.send_event(
		bc.user_a.profile_id, "test", {"testData": 24}
	)
	bc.expect_status_ok(response)
	_event_id = response.get("data", {}).get("evId", "")

func test_update_event_data(bc: BCTest) -> void:
	bc.begin_test("test_update_event_data")
	if _event_id.is_empty():
		bc.expect_true(true, "no event to update, skipping")
		return
	var response := await bc.bc_wrapper.event_service.update_incoming_event_data(_event_id, {"testData": 117})
	bc.expect_status_ok(response)

func test_update_incoming_event_data_if_exists_true(bc: BCTest) -> void:
	bc.begin_test("test_update_incoming_event_data_if_exists_true")
	if _event_id.is_empty():
		bc.expect_true(true, "no event to update, skipping")
		return
	var response := await bc.bc_wrapper.event_service.update_incoming_event_data_if_exists(
		_event_id, {"testData": 118}
	)
	bc.expect_status_ok(response)

func test_delete_incoming_event(bc: BCTest) -> void:
	bc.begin_test("test_delete_incoming_event")
	if _event_id.is_empty():
		bc.expect_true(true, "no event to delete, skipping")
		return
	var response := await bc.bc_wrapper.event_service.delete_incoming_event(_event_id)
	bc.expect_status_ok(response)
	_event_id = ""

func test_get_events(bc: BCTest) -> void:
	bc.begin_test("test_get_events")
	var response := await bc.bc_wrapper.event_service.get_events()
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_delete_incoming_events(bc: BCTest) -> void:
	bc.begin_test("test_delete_incoming_events")
	var response := await bc.bc_wrapper.event_service.delete_incoming_events([])
	bc.expect_status_ok(response)

func test_delete_incoming_events_by_type_older_than(bc: BCTest) -> void:
	bc.begin_test("test_delete_incoming_events_by_type_older_than")
	var response := await bc.bc_wrapper.event_service.delete_incoming_events_by_type_older_than(
		"my-event-type", 1619804426154
	)
	bc.expect_status_ok(response)

func test_delete_incoming_events_older_than(bc: BCTest) -> void:
	bc.begin_test("test_delete_incoming_events_older_than")
	var response := await bc.bc_wrapper.event_service.delete_incoming_events_older_than(1619804426154)
	bc.expect_status_ok(response)
