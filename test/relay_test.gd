# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

const _ROOM_READY_TIMEOUT := 90.0
const _DISBAND_ROOM_LAUNCHED := 80101
# Same lobby type used by the C++ and Dart relay unit tests against app 20001.
# Has everyReadyMinNum=1 so a single ready player immediately triggers ROOM_READY.
const _RELAY_LOBBY_TYPE   := "READY_START_V2"

# State passed between integration tests
var _relay_lobby_type: String     = ""
var _room_data:        Dictionary = {}
var _lobby_id:         String     = ""
var _rtt_ok:           bool       = false

func run(bc: BCTest) -> void:
	await test_service_accessible(bc)
	await test_not_connected_initially(bc)
	await test_register_relay_callback(bc)
	await test_register_system_callback(bc)
	await test_send_when_not_connected(bc)
	await test_disconnect_when_not_connected(bc)
	await test_connect_invalid_host(bc)
	# Integration tests — require relayLobbyType in ids.cfg pointing to a lobby
	# type that has a relay server configured (everyReadyMinNum=1 recommended so
	# a single ready player triggers ROOM_READY without waiting for others).
	await test_relay_enable_rtt(bc)
	await test_relay_find_lobby_and_room_ready(bc)
	await test_relay_connect_ws(bc)
	await test_relay_net_id_assigned(bc)
	await test_relay_send_to_self(bc)
	await test_relay_ping_measured(bc)
	await test_relay_disconnect_clean(bc)
	await test_relay_cleanup(bc)

# ── Offline tests ─────────────────────────────────────────────────────────────

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
		{"host": "127.0.0.1", "port": 1, "ssl": false, "lobbyId": "invalid", "passcode": "invalid"},
		func(_r): pass,
		func(_r): failed[0] = true
	)
	bc.expect_true(failed[0], "relay_connect with unreachable host should invoke failure callback")
	bc.expect_false(bc.bc_wrapper.relay_service.relay_is_connected(), "relay should not be connected after failed connect")

# ── Integration tests ─────────────────────────────────────────────────────────

func test_relay_enable_rtt(bc: BCTest) -> void:
	bc.begin_test("relay_enable_rtt")
	# Hardcoded, like every other SDK: cpp, java, dart and csharp all pass "READY_START_V2"
	# as a literal. This used to read a "relayLobbyType" key out of ids.cfg, which made
	# GDScript the only SDK needing that key - so on any environment whose ids file lacked
	# it the whole relay suite skipped itself and blamed missing config, even though the
	# lobby type was configured on the portal exactly as it is everywhere else.
	_relay_lobby_type = _RELAY_LOBBY_TYPE

	var result := [{}]
	await bc.bc_wrapper.rtt_service.enable_rtt(
		"WEBSOCKET",
		func(r): result[0] = r,
		func(r): result[0] = r
	)
	_rtt_ok = result[0].get("status", 0) == 200
	bc.expect_true(_rtt_ok, "enable_rtt should succeed before relay integration tests")

func test_relay_find_lobby_and_room_ready(bc: BCTest) -> void:
	bc.begin_test("relay_find_lobby_and_room_ready")
	if not _rtt_ok:
		bc.expect_true(false, "skipping — RTT not enabled (see test_relay_enable_rtt)")
		return

	var room_ready    := [{}]
	var disbanded     := [{}]
	var saw_assigned  := [false]
	var saw_launch_disband := [false]
	var all_ops:    Array[String] = []

	bc.bc_wrapper.rtt_service.register_rtt_lobby_callback(func(msg: Dictionary) -> void:
		var op: String = msg.get("operation", "")
		if not all_ops.has(op):
			all_ops.append(op)
			print("[relay_test] RTT lobby op: %s" % op)
		# ROOM_READY is the ONLY op that permits connecting. ROOM_ASSIGNED means a relay
		# server has been allocated, not that it is listening yet — connecting on it races
		# the server's startup and is never valid brainCloud usage. So there is no fallback
		# and no grace window: we wait for ROOM_READY however long it takes. If the room
		# genuinely fails to report ready, the server says so with DISBANDED (carrying the
		# reason) — that is what ends the wait early and fails the test.
		if op == "ROOM_READY":
			if room_ready[0].is_empty():
				room_ready[0] = msg.get("data", {})
		elif op == "ROOM_ASSIGNED":
			saw_assigned[0] = true # diagnostics only — never connect on this
		elif op == "DISBANDED":
			var reason: Dictionary = msg.get("data", {}).get("reason", {})
			if int(reason.get("code", 0)) == _DISBAND_ROOM_LAUNCHED:
				# The room launched and the lobby was torn down because it is no longer
				# needed. Expected on disband-on-start lobby types. Deliberately does NOT
				# end the wait: if ROOM_READY somehow has not landed yet, it still will.
				saw_launch_disband[0] = true
			elif disbanded[0].is_empty():
				disbanded[0] = msg.get("data", {})
	)

	var algo := {"strategy": "ranged-absolute", "alignment": "center", "ranges": [1000]}
	var lobby_resp := await bc.bc_wrapper.lobby_service.find_or_create_lobby(
		_relay_lobby_type, 0, 1, algo, {}, {}, true, {"presentSinceStart": true}, "all", []
	)
	if lobby_resp.get("status", 0) != 200:
		bc.bc_wrapper.rtt_service.deregister_rtt_lobby_callback()
		bc.expect_status_ok(lobby_resp)
		return

	_lobby_id = lobby_resp.get("data", {}).get("lobbyId", "")

	var timed_out := [false]
	var timer := bc.get_tree().create_timer(_ROOM_READY_TIMEOUT)
	timer.timeout.connect(func(): timed_out[0] = true)

	# Wait for ROOM_READY only. A DISBANDED that is NOT the "room launched" one (80101) is
	# the server saying the room will never be ready, so that is the real failure signal;
	# the timer is just the hang guard.
	while room_ready[0].is_empty() and disbanded[0].is_empty() and not timed_out[0]:
		await bc.get_tree().process_frame

	bc.bc_wrapper.rtt_service.deregister_rtt_lobby_callback()

	# ROOM_READY wins over anything else seen in the same batch. The ops arrive together
	# (STARTING → ROOM_ASSIGNED → ROOM_READY → DISBANDED all land before this loop next
	# runs), so checking a disband first would fail a room that came up perfectly.
	if not room_ready[0].is_empty():
		_room_data = room_ready[0]
		bc.expect_true(not _room_data.is_empty(), "room data should not be empty")
		bc.expect_true(_room_data.has("connectData"), "room data should contain connectData")
		return

	if not disbanded[0].is_empty():
		bc.expect_true(false,
			"lobby DISBANDED before ROOM_READY: %s" % JSON.stringify(disbanded[0]))
	elif saw_launch_disband[0]:
		# The room reported as launched but its connect info never arrived — a real
		# failure, and a different one from the room failing to come up at all.
		bc.expect_true(false,
			"lobby disbanded with 'room launched' (%d) but ROOM_READY never arrived after %.0fs (ops seen: %s)"
				% [_DISBAND_ROOM_LAUNCHED, _ROOM_READY_TIMEOUT, str(all_ops)])
	else:
		bc.expect_true(false,
			"timed out waiting for ROOM_READY after %.0fs (ROOM_ASSIGNED %s; ops seen: %s) — check that '%s' has a relay server with everyReadyMinNum=1"
				% [_ROOM_READY_TIMEOUT, ("was received" if saw_assigned[0] else "never arrived"), str(all_ops), _relay_lobby_type])

	if not _lobby_id.is_empty():
		await bc.bc_wrapper.lobby_service.leave_lobby(_lobby_id)
		_lobby_id = ""


func test_relay_connect_ws(bc: BCTest) -> void:
	bc.begin_test("relay_connect_ws")
	if _room_data.is_empty():
		bc.expect_true(false, "skipping — no room data from test_relay_find_lobby_and_room_ready")
		return

	var connect_data: Dictionary = _room_data.get("connectData", {})
	var host: String = connect_data.get("address", "")
	var ports: Dictionary = connect_data.get("ports", {})
	var passcode: String = _room_data.get("passcode", "")
	if _lobby_id.is_empty():
		_lobby_id = _room_data.get("lobbyId", connect_data.get("lobbyId", ""))

	# Port resolution: gamelift > i3d > ws > wss > first available
	var use_ssl := false
	var port: int
	if ports.has("gamelift"):
		port = int(ports["gamelift"])
	elif ports.has("i3d"):
		port = int(ports["i3d"])
	elif ports.has("ws"):
		port = int(ports["ws"])
	elif ports.has("wss"):
		port = int(ports["wss"])
		use_ssl = true
	else:
		port = int(ports.values()[0]) if not ports.is_empty() else 9301

	print("[relay_test] relay_connect host='%s' port=%d ssl=%s lobbyId='%s'" % [host, port, str(use_ssl), _lobby_id])

	var result := [{}]
	await bc.bc_wrapper.relay_service.relay_connect(
		{
			"host": host, "port": port, "ssl": use_ssl,
			"lobbyId": _lobby_id, "passcode": passcode
		},
		func(r): result[0] = r,
		func(r): result[0] = r
	)
	print("[relay_test] relay_connect result: ", result[0])
	bc.expect_status_ok(result[0])
	bc.expect_true(bc.bc_wrapper.relay_service.relay_is_connected(),
		"relay should be connected after successful relay_connect")

func test_relay_net_id_assigned(bc: BCTest) -> void:
	bc.begin_test("relay_net_id_assigned")
	if not bc.bc_wrapper.relay_service.relay_is_connected():
		bc.expect_true(false, "skipping — relay not connected")
		return
	var net_id := bc.bc_wrapper.relay_service.get_net_id()
	bc.expect_true(net_id >= 0, "net_id should be >= 0 after relay connect, got %d" % net_id)

func test_relay_ping_measured(bc: BCTest) -> void:
	bc.begin_test("relay_ping_measured")
	if not bc.bc_wrapper.relay_service.relay_is_connected():
		bc.expect_true(false, "skipping — relay not connected")
		return
	# RelayComms sends a ping every 2s; wait up to 5s for the first measurement
	var timed_out := [false]
	var timer := bc.get_tree().create_timer(5.0)
	timer.timeout.connect(func(): timed_out[0] = true)
	while bc.bc_wrapper.relay_service.get_ping() < 0 and not timed_out[0]:
		await bc.get_tree().process_frame
	var ping := bc.bc_wrapper.relay_service.get_ping()
	bc.expect_true(ping >= 0, "relay ping should be measured within 5s, got %d" % ping)

func test_relay_send_to_self(bc: BCTest) -> void:
	bc.begin_test("relay_send_to_self")
	if not bc.bc_wrapper.relay_service.relay_is_connected():
		bc.expect_true(false, "skipping — relay not connected")
		return

	var payload_bytes := JSON.stringify({"op": "test_echo", "seq": 42}).to_utf8_buffer()
	var received := [false]
	var received_seq := [-1]

	bc.bc_wrapper.relay_service.register_relay_callback(func(_net_id: int, data: PackedByteArray) -> void:
		var parsed = JSON.parse_string(data.get_string_from_utf8())
		if parsed is Dictionary and parsed.get("op", "") == "test_echo":
			received[0] = true
			received_seq[0] = int(parsed.get("seq", -1))
	)

	bc.bc_wrapper.relay_service.send(
		payload_bytes,
		BrainCloudRelay.TO_ALL_PLAYERS,
		true, false,
		BrainCloudRelay.CHANNEL_HIGH_PRIORITY_1
	)

	var timed_out := [false]
	var timer := bc.get_tree().create_timer(5.0)
	timer.timeout.connect(func(): timed_out[0] = true)
	while not received[0] and not timed_out[0]:
		await bc.get_tree().process_frame

	bc.bc_wrapper.relay_service.deregister_relay_callback()
	bc.expect_true(received[0], "message sent to TO_ALL_PLAYERS should be echoed back within 5s")
	if received[0]:
		bc.expect_eq(received_seq[0], 42, "echoed message seq should match sent value")

func test_relay_disconnect_clean(bc: BCTest) -> void:
	bc.begin_test("relay_disconnect_clean")
	bc.bc_wrapper.relay_service.deregister_relay_callback()
	bc.bc_wrapper.relay_service.deregister_system_callback()
	if bc.bc_wrapper.relay_service.relay_is_connected():
		bc.bc_wrapper.relay_service.relay_disconnect()
	bc.expect_false(bc.bc_wrapper.relay_service.relay_is_connected(),
		"relay should not be connected after relay_disconnect")

func test_relay_cleanup(bc: BCTest) -> void:
	bc.begin_test("relay_cleanup")
	if not _lobby_id.is_empty():
		await bc.bc_wrapper.lobby_service.leave_lobby(_lobby_id)
		_lobby_id = ""
	bc.bc_wrapper.rtt_service.deregister_rtt_lobby_callback()
	bc.bc_wrapper.rtt_service.disable_rtt()
	bc.expect_true(not bc.bc_wrapper.rtt_service.is_rtt_enabled(),
		"RTT should be disabled after relay test cleanup")
