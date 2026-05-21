# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_service_accessible(bc)
	await test_not_connected_initially(bc)
	await test_register_relay_callback(bc)
	await test_register_system_callback(bc)
	await test_send_when_not_connected(bc)
	await test_disconnect_when_not_connected(bc)
	await test_connect_invalid_host(bc)

func test_service_accessible(bc: BCTest) -> void:
	bc.begin_test("relay_service_accessible")
	bc.expect_true(bc.bc_wrapper.relay_service != null, "relay_service should be accessible")

func test_not_connected_initially(bc: BCTest) -> void:
	bc.begin_test("relay_not_connected_initially")
	bc.expect_false(bc.bc_wrapper.relay_service.relay_is_connected(), "relay should not be connected before relay_connect")

func test_register_relay_callback(bc: BCTest) -> void:
	bc.begin_test("relay_register_relay_callback")
	bc.bc_wrapper.relay_service.register_relay_callback(func(_net_id, _data): pass)
	bc.expect_true(true, "register_relay_callback should not crash")
	bc.bc_wrapper.relay_service.deregister_relay_callback()
	bc.expect_true(true, "deregister_relay_callback should not crash")

func test_register_system_callback(bc: BCTest) -> void:
	bc.begin_test("relay_register_system_callback")
	bc.bc_wrapper.relay_service.register_system_callback(func(_msg): pass)
	bc.expect_true(true, "register_system_callback should not crash")
	bc.bc_wrapper.relay_service.deregister_system_callback()
	bc.expect_true(true, "deregister_system_callback should not crash")

func test_send_when_not_connected(bc: BCTest) -> void:
	bc.begin_test("relay_send_when_not_connected")
	bc.bc_wrapper.relay_service.send(PackedByteArray([1, 2, 3]), 0, true, true, 0)
	bc.expect_true(true, "send when disconnected should not crash")

func test_disconnect_when_not_connected(bc: BCTest) -> void:
	bc.begin_test("relay_disconnect_when_not_connected")
	bc.bc_wrapper.relay_service.relay_disconnect()
	bc.expect_false(bc.bc_wrapper.relay_service.relay_is_connected(), "should remain disconnected after relay_disconnect when already disconnected")

func test_connect_invalid_host(bc: BCTest) -> void:
	bc.begin_test("relay_connect_invalid_host")
	var failed := [false]
	await bc.bc_wrapper.relay_service.relay_connect(
		{"host": "127.0.0.1", "port": 1, "ssl": false, "cxId": "invalid", "lobbyId": "invalid", "passcode": "invalid"},
		func(_r): pass,
		func(_r): failed[0] = true
	)
	bc.expect_true(failed[0], "relay_connect with unreachable host should invoke failure callback")
	bc.expect_false(bc.bc_wrapper.relay_service.relay_is_connected(), "relay should not be connected after failed connect")
