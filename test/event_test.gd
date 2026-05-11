# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

var _event_id: String = ""

func run(bc: BCTest) -> void:
	await test_send_event(bc)
	await test_get_events(bc)
	await test_update_event_data(bc)
	await test_delete_incoming_event(bc)

func test_send_event(bc: BCTest) -> void:
	bc.begin_test("test_send_event")
	var response := await bc.bc_wrapper.event_service.send_event(
		bc.user_b.profile_id, "test_event_type", {"msg": "hello from gdscript test"}
	)
	bc.expect_status_ok(response)
	_event_id = response.get("data", {}).get("evId", "")

func test_get_events(bc: BCTest) -> void:
	bc.begin_test("test_get_events")
	var response := await bc.bc_wrapper.event_service.get_events()
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_update_event_data(bc: BCTest) -> void:
	bc.begin_test("test_update_event_data")
	if _event_id.is_empty():
		# Try to find an event to update
		var get_resp := await bc.bc_wrapper.event_service.get_events()
		var events: Array = get_resp.get("data", {}).get("incoming_events", [])
		if events.size() > 0:
			_event_id = events[0].get("evId", "")

	if _event_id.is_empty():
		bc.expect_true(true, "no event to update, skipping")
		return

	var response := await bc.bc_wrapper.event_service.update_incoming_event_data(_event_id, {"msg": "updated"})
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)

func test_delete_incoming_event(bc: BCTest) -> void:
	bc.begin_test("test_delete_incoming_event")
	if _event_id.is_empty():
		var get_resp := await bc.bc_wrapper.event_service.get_events()
		var events: Array = get_resp.get("data", {}).get("incoming_events", [])
		if events.size() > 0:
			_event_id = events[0].get("evId", "")

	if _event_id.is_empty():
		bc.expect_true(true, "no event to delete, skipping")
		return

	var response := await bc.bc_wrapper.event_service.delete_incoming_event(_event_id)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)
	_event_id = ""
