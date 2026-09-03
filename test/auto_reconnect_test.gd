# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_can_reconnect(bc)
	await test_reconnect(bc)
	await test_auto_reconnect_enabled_with_callback(bc)
	# Restore the expected auth state for any suites that run after this one.
	await bc._auth()

func test_can_reconnect(bc: BCTest) -> void:
	bc.begin_test("test_can_reconnect")
	# Setup authenticated the main wrapper, so both profile id and anonymous id are stored.
	bc.expect_true(bc.bc_wrapper.can_reconnect(),
		"can_reconnect should be true while authenticated")

func test_reconnect(bc: BCTest) -> void:
	bc.begin_test("test_reconnect")
	# reconnect() restores the session using only the stored anonymous id + profile id.
	var response := await bc.bc_wrapper.reconnect()
	bc.expect_status_ok(response)

# Mirrors the C# SDK's TestAutoReconnectWithCallback: a *second* user ends the main
# user's session via the LogoutSession cloud script, then the main wrapper makes a call.
# With auto-reconnect enabled the call should transparently re-authenticate and succeed,
# and the registered callback should fire exactly once.
func test_auto_reconnect_enabled_with_callback(bc: BCTest) -> void:
	bc.begin_test("test_auto_reconnect_enabled_with_callback")
	var client := bc.bc_wrapper.braincloud_client

	# Track how many times the auto-reconnect callback is invoked. Use a Dictionary so the
	# lambda can mutate it by reference.
	var cb_state := {"count": 0}
	client.register_auto_reconnect_callback(func(_resp: Dictionary) -> void:
		cb_state.count += 1
		print("  [auto-reconnect callback] handled session reconnect"))

	bc.bc_wrapper.enable_auto_reconnect(true)

	# Capture the active session/profile so a second user can end it server-side.
	var profile_id := bc.bc_wrapper.get_stored_profile_id()
	var session_id := client.get_session_id()
	bc.expect_true(not session_id.is_empty(), "main wrapper should have an active session")

	# Spin up a second wrapper (different user) to end the main user's session.
	var url: String = bc.ids.get("serverUrl", BrainCloudClient.DEFAULT_SERVER_URL)
	var app_id: String = bc.ids.get("appId", "")
	var secret: String = bc.ids.get("secret", "")
	var version: String = bc.ids.get("version", "")

	var other := BrainCloudWrapper.new()
	other.name = "BCWrapperOther"
	other.wrapper_name = "GDScriptTestOther"
	bc.add_child(other)
	other.initialize(secret, app_id, version, url)
	other.braincloud_client.enable_logging(true)
	other.braincloud_client.authentication_service.clear_saved_profile_id()
	var other_auth := await other.authenticate_universal(bc.user_b.name, bc.user_b.password, true)
	bc.expect_status_ok(other_auth)

	# End the main user's session via cloud code.
	var script_data := {"sessionId": session_id, "profileId": profile_id}
	var script_resp := await other.script_service.run_script("LogoutSession", script_data)
	bc.expect_status_ok(script_resp)

	# The next call on the main wrapper hits PLAYER_SESSION_EXPIRED, but auto-reconnect
	# should silently restore the session and replay the call so it succeeds.
	var response := await bc.bc_wrapper.identity_service.get_identities()
	bc.expect_status_ok(response)
	bc.expect_eq(cb_state.count, 1, "auto-reconnect callback should fire exactly once")

	# Cleanup
	bc.bc_wrapper.enable_auto_reconnect(false)
	client.deregister_auto_reconnect_callback()
	await other.logout(true)
	other.queue_free()
