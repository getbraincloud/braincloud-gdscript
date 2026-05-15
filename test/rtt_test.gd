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
	await test_rtt_event_received(bc)
	await test_rtt_lobby_event_received(bc)
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
	bc.expect_true(cid.length() > 0, "get_rtt_connection_id should return a non-empty string when connected")

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

func test_rtt_event_received(bc: BCTest) -> void:
	bc.begin_test("test_rtt_event_received")
	var event_received := [false]
	bc.bc_wrapper.rtt_service.register_rtt_event_callback(func(_msg): event_received[0] = true)

	var profile_id: String = bc.bc_wrapper.braincloud_client.get_profile_id()
	await bc.bc_wrapper.event_service.send_event(profile_id, "test_rtt_event", {})

	var timed_out := [false]
	var timer := bc.get_tree().create_timer(5.0)
	timer.timeout.connect(func(): timed_out[0] = true)
	while not event_received[0] and not timed_out[0]:
		await bc.get_tree().process_frame

	bc.expect_true(event_received[0], "RTT event callback should fire after sending an event to self")
	bc.bc_wrapper.rtt_service.deregister_rtt_event_callback()

func test_rtt_lobby_event_received(bc: BCTest) -> void:
	bc.begin_test("test_rtt_lobby_event_received")
	var lobby_event := [{}]
	bc.bc_wrapper.rtt_service.register_rtt_lobby_callback(func(msg): lobby_event[0] = msg)

	var algo := {"strategy": "ranged-absolute", "alignment": "center", "ranges": [1000]}
	await bc.bc_wrapper.lobby_service.find_or_create_lobby("MATCH_UNRANKED", 0, 1, algo, {}, {}, true, {}, "all", [])

	var timed_out := [false]
	var timer := bc.get_tree().create_timer(10.0)
	timer.timeout.connect(func(): timed_out[0] = true)
	while lobby_event[0].is_empty() and not timed_out[0]:
		await bc.get_tree().process_frame

	bc.bc_wrapper.rtt_service.deregister_rtt_lobby_callback()

	if timed_out[0]:
		bc.expect_true(false, "timed out waiting for RTT lobby event after find_or_create_lobby")
		return

	var op: String = lobby_event[0].get("operation", "")
	bc.expect_true(not op.is_empty(), "RTT lobby event should have an 'operation' field, got: %s" % str(lobby_event[0]))

	# Leave or cancel so we don't leave a dangling lobby entry
	var lobby_id: String = lobby_event[0].get("data", {}).get("lobby", {}).get("id", "")
	if not lobby_id.is_empty():
		await bc.bc_wrapper.lobby_service.leave_lobby(lobby_id)
	else:
		await bc.bc_wrapper.lobby_service.cancel_find_request("MATCH_UNRANKED", "")

func test_disable_rtt(bc: BCTest) -> void:
	bc.begin_test("test_disable_rtt")
	bc.bc_wrapper.rtt_service.disable_rtt()
	bc.expect_true(not bc.bc_wrapper.rtt_service.is_rtt_enabled(), "RTT should be disabled after disable_rtt")
