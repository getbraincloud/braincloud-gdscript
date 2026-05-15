# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

const LOBBY_TYPE := "MATCH_UNRANKED"

var _lobby_id: String = ""

func run(bc: BCTest) -> void:
	await test_service_accessible(bc)
	await test_get_regions_for_lobbies(bc)
	await test_get_lobby_instances(bc)
	await test_find_lobby(bc)
	await test_find_or_create_lobby(bc)
	await test_create_lobby(bc)
	await test_get_lobby_data(bc)
	await test_update_settings(bc)
	await test_update_ready(bc)
	await test_send_signal(bc)
	await test_switch_team(bc)
	await test_leave_lobby(bc)
	await test_get_lobby_data_invalid(bc)
	await test_join_lobby_invalid(bc)
	await test_leave_lobby_invalid(bc)
	await test_remove_member_invalid(bc)
	await test_send_signal_invalid(bc)
	await test_switch_team_invalid(bc)
	await test_update_ready_invalid(bc)
	await test_update_settings_invalid(bc)
	await test_cancel_find_request(bc)

func _algo() -> Dictionary:
	return {"strategy": "ranged-absolute", "alignment": "center", "ranges": [1000]}

func test_service_accessible(bc: BCTest) -> void:
	bc.begin_test("test_service_accessible")
	bc.expect_true(bc.bc_wrapper.lobby_service != null, "lobby_service should be accessible")

func test_get_regions_for_lobbies(bc: BCTest) -> void:
	bc.begin_test("test_get_regions_for_lobbies")
	var response := await bc.bc_wrapper.lobby_service.get_regions_for_lobbies([LOBBY_TYPE])
	bc.expect_status_ok(response)

func test_get_lobby_instances(bc: BCTest) -> void:
	bc.begin_test("test_get_lobby_instances")
	var response := await bc.bc_wrapper.lobby_service.get_lobby_instances(LOBBY_TYPE, {"rating": {"min": 0, "max": 1000}})
	bc.expect_status_ok(response)

func test_find_lobby(bc: BCTest) -> void:
	bc.begin_test("test_find_lobby")
	var response := await bc.bc_wrapper.lobby_service.find_lobby(
		LOBBY_TYPE, 0, 1, _algo(), {}, true, {}, "all", []
	)
	bc.expect_status_ok(response)
	# find_lobby is async — server queues the request and notifies via RTT.
	# The HTTP response is 200 with no lobbyId; cleanup is via cancel_find_request.

func test_find_or_create_lobby(bc: BCTest) -> void:
	bc.begin_test("test_find_or_create_lobby")
	var response := await bc.bc_wrapper.lobby_service.find_or_create_lobby(
		LOBBY_TYPE, 0, 1, _algo(), {}, {}, true, {}, "all", []
	)
	bc.expect_status_ok(response)
	var lid: String = response.get("data", {}).get("lobbyId", "")
	if not lid.is_empty():
		await bc.bc_wrapper.lobby_service.leave_lobby(lid)
	else:
		await bc.bc_wrapper.lobby_service.cancel_find_request(LOBBY_TYPE, "")

func test_create_lobby(bc: BCTest) -> void:
	bc.begin_test("test_create_lobby")
	var response := await bc.bc_wrapper.lobby_service.create_lobby(
		LOBBY_TYPE, 0, true, {}, "all", {}, []
	)
	bc.expect_status_ok(response)
	_lobby_id = response.get("data", {}).get("lobbyId", "")

func test_get_lobby_data(bc: BCTest) -> void:
	bc.begin_test("test_get_lobby_data")
	if _lobby_id.is_empty():
		bc.expect_true(false, "skipping — no lobby_id from test_create_lobby")
		return
	var response := await bc.bc_wrapper.lobby_service.get_lobby_data(_lobby_id)
	bc.expect_status_ok(response)

func test_update_settings(bc: BCTest) -> void:
	bc.begin_test("test_update_settings")
	if _lobby_id.is_empty():
		bc.expect_true(false, "skipping — no lobby_id from test_create_lobby")
		return
	var response := await bc.bc_wrapper.lobby_service.update_settings(_lobby_id, {})
	bc.expect_status_ok(response)

func test_update_ready(bc: BCTest) -> void:
	bc.begin_test("test_update_ready")
	if _lobby_id.is_empty():
		bc.expect_true(false, "skipping — no lobby_id from test_create_lobby")
		return
	var response := await bc.bc_wrapper.lobby_service.update_ready(_lobby_id, true, {})
	bc.expect_status_ok(response)

func test_send_signal(bc: BCTest) -> void:
	bc.begin_test("test_send_signal")
	if _lobby_id.is_empty():
		bc.expect_true(false, "skipping — no lobby_id from test_create_lobby")
		return
	var response := await bc.bc_wrapper.lobby_service.send_signal(_lobby_id, {"hello": "world"})
	bc.expect_status_ok(response)

func test_switch_team(bc: BCTest) -> void:
	bc.begin_test("test_switch_team")
	if _lobby_id.is_empty():
		bc.expect_true(false, "skipping — no lobby_id from test_create_lobby")
		return
	var response := await bc.bc_wrapper.lobby_service.switch_team(_lobby_id, "all")
	bc.expect_status_ok(response)

func test_leave_lobby(bc: BCTest) -> void:
	bc.begin_test("test_leave_lobby")
	if _lobby_id.is_empty():
		bc.expect_true(false, "skipping — no lobby_id from test_create_lobby")
		return
	var response := await bc.bc_wrapper.lobby_service.leave_lobby(_lobby_id)
	bc.expect_status_ok(response)
	_lobby_id = ""

func test_get_lobby_data_invalid(bc: BCTest) -> void:
	bc.begin_test("test_get_lobby_data_invalid")
	var response := await bc.bc_wrapper.lobby_service.get_lobby_data("invalid:lobby:id")
	bc.expect_true(
		response.get("status", -1) != StatusCodes.OK,
		"Expected error for invalid lobby id, got 200"
	)

func test_join_lobby_invalid(bc: BCTest) -> void:
	bc.begin_test("test_join_lobby_invalid")
	var response := await bc.bc_wrapper.lobby_service.join_lobby(
		"invalid:lobby:id", true, {}, "all", []
	)
	bc.expect_true(
		response.get("status", -1) != StatusCodes.OK,
		"Expected error for invalid lobby id, got 200"
	)

func test_leave_lobby_invalid(bc: BCTest) -> void:
	bc.begin_test("test_leave_lobby_invalid")
	var response := await bc.bc_wrapper.lobby_service.leave_lobby("invalid:lobby:id")
	bc.expect_true(
		response.get("status", -1) != StatusCodes.OK,
		"Expected error for invalid lobby id, got 200"
	)

func test_remove_member_invalid(bc: BCTest) -> void:
	bc.begin_test("test_remove_member_invalid")
	var response := await bc.bc_wrapper.lobby_service.remove_member(
		"invalid:lobby:id", "fake-cx-id"
	)
	bc.expect_true(
		response.get("status", -1) != StatusCodes.OK,
		"Expected error for invalid lobby id, got 200"
	)

func test_send_signal_invalid(bc: BCTest) -> void:
	bc.begin_test("test_send_signal_invalid")
	var response := await bc.bc_wrapper.lobby_service.send_signal(
		"invalid:lobby:id", {"hello": "world"}
	)
	bc.expect_true(
		response.get("status", -1) != StatusCodes.OK,
		"Expected error for invalid lobby id, got 200"
	)

func test_switch_team_invalid(bc: BCTest) -> void:
	bc.begin_test("test_switch_team_invalid")
	var response := await bc.bc_wrapper.lobby_service.switch_team("invalid:lobby:id", "red")
	bc.expect_true(
		response.get("status", -1) != StatusCodes.OK,
		"Expected error for invalid lobby id, got 200"
	)

func test_update_ready_invalid(bc: BCTest) -> void:
	bc.begin_test("test_update_ready_invalid")
	var response := await bc.bc_wrapper.lobby_service.update_ready("invalid:lobby:id", true, {})
	bc.expect_true(
		response.get("status", -1) != StatusCodes.OK,
		"Expected error for invalid lobby id, got 200"
	)

func test_update_settings_invalid(bc: BCTest) -> void:
	bc.begin_test("test_update_settings_invalid")
	var response := await bc.bc_wrapper.lobby_service.update_settings("invalid:lobby:id", {})
	bc.expect_true(
		response.get("status", -1) != StatusCodes.OK,
		"Expected error for invalid lobby id, got 200"
	)

func test_cancel_find_request(bc: BCTest) -> void:
	bc.begin_test("test_cancel_find_request")
	var response := await bc.bc_wrapper.lobby_service.cancel_find_request(LOBBY_TYPE, "")
	bc.expect_status_ok(response)
