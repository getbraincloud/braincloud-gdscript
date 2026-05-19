# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_is_authenticated(bc)
	await test_get_session_id(bc)
	await test_get_app_id(bc)
	await test_send_heartbeat(bc)

func test_is_authenticated(bc: BCTest) -> void:
	bc.begin_test("test_is_authenticated")
	bc.expect_true(bc.bc_wrapper.braincloud_client.is_authenticated(), "client should be authenticated")

func test_get_session_id(bc: BCTest) -> void:
	bc.begin_test("test_get_session_id")
	var session_id: String = bc.bc_wrapper.braincloud_client.get_session_id()
	bc.expect_true(session_id.length() > 0, "session_id should not be empty")

func test_get_app_id(bc: BCTest) -> void:
	bc.begin_test("test_get_app_id")
	var app_id: String = bc.bc_wrapper.braincloud_client.get_app_id()
	bc.expect_true(app_id.length() > 0, "app_id should not be empty")

func test_send_heartbeat(bc: BCTest) -> void:
	bc.begin_test("test_send_heartbeat")
	var response := await bc.bc_wrapper.braincloud_client.send_heartbeat()
	bc.expect_status_ok(response)
