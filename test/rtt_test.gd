# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_service_accessible(bc)
	await test_request_client_connection(bc)
	await test_enable_rtt(bc)
	await test_rtt_is_enabled(bc)
	await test_get_connection_id(bc)
	await test_set_heart_beat_seconds(bc)
	await test_register_rtt_callback(bc)
	await test_disable_rtt(bc)

func test_service_accessible(bc: BCTest) -> void:
	bc.begin_test("test_service_accessible")
	bc.expect_true(bc.bc_wrapper.rtt_service != null, "rtt_service should be accessible")

func test_request_client_connection(bc: BCTest) -> void:
	bc.begin_test("test_request_client_connection")
	var response := await bc.bc_wrapper.rtt_service.request_client_connection()
	bc.expect_status_ok(response)

func test_enable_rtt(bc: BCTest) -> void:
	bc.begin_test("test_enable_rtt")
	var _out := [{}]
	await bc.bc_wrapper.rtt_service.enable_rtt(
		"WEBSOCKET",
		func(r): _out[0] = r,
		func(r): _out[0] = r
	)
	bc.expect_status_ok(_out[0])

func test_rtt_is_enabled(bc: BCTest) -> void:
	bc.begin_test("test_rtt_is_enabled")
	bc.expect_true(bc.bc_wrapper.rtt_service.is_rtt_enabled(), "RTT should be enabled after enable_rtt")

func test_get_connection_id(bc: BCTest) -> void:
	bc.begin_test("test_get_connection_id")
	var cid: String = bc.bc_wrapper.rtt_service.get_rtt_connection_id()
	bc.expect_true(cid.length() >= 0, "get_rtt_connection_id should return a string")

func test_set_heart_beat_seconds(bc: BCTest) -> void:
	bc.begin_test("test_set_heart_beat_seconds")
	bc.bc_wrapper.rtt_service.set_rtt_heart_beat_seconds(30)
	bc.expect_true(true, "set_rtt_heart_beat_seconds should not crash")

func test_register_rtt_callback(bc: BCTest) -> void:
	bc.begin_test("test_register_rtt_callback")
	bc.bc_wrapper.rtt_service.register_rtt_event_callback(func(_r): pass)
	bc.expect_true(true, "register_rtt_event_callback should not crash")
	bc.bc_wrapper.rtt_service.deregister_rtt_event_callback()
	bc.expect_true(true, "deregister_rtt_event_callback should not crash")

func test_disable_rtt(bc: BCTest) -> void:
	bc.begin_test("test_disable_rtt")
	bc.bc_wrapper.rtt_service.disable_rtt()
	bc.expect_true(not bc.bc_wrapper.rtt_service.is_rtt_enabled(), "RTT should be disabled after disable_rtt")
