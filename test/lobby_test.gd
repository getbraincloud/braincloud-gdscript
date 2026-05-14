# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

const LOBBY_TYPE := "MATCH_UNRANKED"

func run(bc: BCTest) -> void:
	await test_service_accessible(bc)
	await test_find_lobby(bc)
	await test_find_or_create_lobby(bc)
	await test_create_lobby(bc)
	await test_get_lobby_data_invalid(bc)
	await test_join_lobby_invalid(bc)
	await test_leave_lobby_invalid(bc)
	await test_remove_member_invalid(bc)
	await test_send_signal_invalid(bc)
	await test_switch_team_invalid(bc)
	await test_update_ready_invalid(bc)
	await test_update_settings_invalid(bc)
	await test_cancel_find_request(bc)
	await test_get_regions_for_lobbies(bc)
	await test_get_lobby_instances(bc)

func test_service_accessible(bc: BCTest) -> void:
	bc.begin_test("test_service_accessible")
	bc.expect_true(bc.bc_wrapper.lobby_service != null, "lobby_service should be accessible")

func test_find_lobby(bc: BCTest) -> void:
	bc.begin_test("test_find_lobby")
	var algo := {
		"strategy": "ranged-absolute",
		"alignment": "center",
		"ranges": [1000]
	}
	var response := await bc.bc_wrapper.lobby_service.find_lobby(
		LOBBY_TYPE, 0, 1, algo, {}, true, {}, "all", []
	)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST or status == StatusCodes.FORBIDDEN,
		"Expected 200, 400 or 403, got %d" % status
	)

func test_find_or_create_lobby(bc: BCTest) -> void:
	bc.begin_test("test_find_or_create_lobby")
	var algo := {
		"strategy": "ranged-absolute",
		"alignment": "center",
		"ranges": [1000]
	}
	var response := await bc.bc_wrapper.lobby_service.find_or_create_lobby(
		LOBBY_TYPE, 0, 1, algo, {}, true, {}, "all", []
	)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST or status == StatusCodes.FORBIDDEN,
		"Expected 200, 400 or 403, got %d" % status
	)

func test_create_lobby(bc: BCTest) -> void:
	bc.begin_test("test_create_lobby")
	var response := await bc.bc_wrapper.lobby_service.create_lobby(
		LOBBY_TYPE, 0, true, {}, "all", {}, []
	)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST or status == StatusCodes.FORBIDDEN,
		"Expected 200, 400 or 403, got %d" % status
	)

func test_get_lobby_data_invalid(bc: BCTest) -> void:
	bc.begin_test("test_get_lobby_data_invalid")
	var response := await bc.bc_wrapper.lobby_service.get_lobby_data("invalid:lobby:id")
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.BAD_REQUEST or status == StatusCodes.FORBIDDEN or status == StatusCodes.NOT_FOUND,
		"Expected 400, 403 or 404 for invalid lobby, got %d" % status
	)

func test_join_lobby_invalid(bc: BCTest) -> void:
	bc.begin_test("test_join_lobby_invalid")
	var response := await bc.bc_wrapper.lobby_service.join_lobby(
		"invalid:lobby:id", true, {}, "all", []
	)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.BAD_REQUEST or status == StatusCodes.FORBIDDEN or status == StatusCodes.NOT_FOUND,
		"Expected 400, 403 or 404 for invalid lobby, got %d" % status
	)

func test_leave_lobby_invalid(bc: BCTest) -> void:
	bc.begin_test("test_leave_lobby_invalid")
	var response := await bc.bc_wrapper.lobby_service.leave_lobby("invalid:lobby:id")
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.BAD_REQUEST or status == StatusCodes.FORBIDDEN or status == StatusCodes.NOT_FOUND,
		"Expected 400, 403 or 404 for invalid lobby, got %d" % status
	)

func test_remove_member_invalid(bc: BCTest) -> void:
	bc.begin_test("test_remove_member_invalid")
	var response := await bc.bc_wrapper.lobby_service.remove_member(
		"invalid:lobby:id", "fake-cx-id"
	)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.BAD_REQUEST or status == StatusCodes.FORBIDDEN or status == StatusCodes.NOT_FOUND,
		"Expected 400, 403 or 404 for invalid lobby, got %d" % status
	)

func test_send_signal_invalid(bc: BCTest) -> void:
	bc.begin_test("test_send_signal_invalid")
	var response := await bc.bc_wrapper.lobby_service.send_signal(
		"invalid:lobby:id", {"hello": "world"}
	)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.BAD_REQUEST or status == StatusCodes.FORBIDDEN or status == StatusCodes.NOT_FOUND,
		"Expected 400, 403 or 404 for invalid lobby, got %d" % status
	)

func test_switch_team_invalid(bc: BCTest) -> void:
	bc.begin_test("test_switch_team_invalid")
	var response := await bc.bc_wrapper.lobby_service.switch_team(
		"invalid:lobby:id", "red"
	)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.BAD_REQUEST or status == StatusCodes.FORBIDDEN or status == StatusCodes.NOT_FOUND,
		"Expected 400, 403 or 404 for invalid lobby, got %d" % status
	)

func test_update_ready_invalid(bc: BCTest) -> void:
	bc.begin_test("test_update_ready_invalid")
	var response := await bc.bc_wrapper.lobby_service.update_ready(
		"invalid:lobby:id", true, {}
	)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.BAD_REQUEST or status == StatusCodes.FORBIDDEN or status == StatusCodes.NOT_FOUND,
		"Expected 400, 403 or 404 for invalid lobby, got %d" % status
	)

func test_update_settings_invalid(bc: BCTest) -> void:
	bc.begin_test("test_update_settings_invalid")
	var response := await bc.bc_wrapper.lobby_service.update_settings(
		"invalid:lobby:id", {}
	)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.BAD_REQUEST or status == StatusCodes.FORBIDDEN or status == StatusCodes.NOT_FOUND,
		"Expected 400, 403 or 404 for invalid lobby, got %d" % status
	)

func test_cancel_find_request(bc: BCTest) -> void:
	bc.begin_test("test_cancel_find_request")
	var response := await bc.bc_wrapper.lobby_service.cancel_find_request(LOBBY_TYPE, "")
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST or status == StatusCodes.FORBIDDEN,
		"Expected 200, 400 or 403, got %d" % status
	)

func test_get_regions_for_lobbies(bc: BCTest) -> void:
	bc.begin_test("test_get_regions_for_lobbies")
	var response := await bc.bc_wrapper.lobby_service.get_regions_for_lobbies([LOBBY_TYPE])
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST or status == StatusCodes.FORBIDDEN,
		"Expected 200, 400 or 403, got %d" % status
	)

func test_get_lobby_instances(bc: BCTest) -> void:
	bc.begin_test("test_get_lobby_instances")
	var response := await bc.bc_wrapper.lobby_service.get_lobby_instances(LOBBY_TYPE, {})
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST or status == StatusCodes.FORBIDDEN,
		"Expected 200, 400 or 403, got %d" % status
	)
