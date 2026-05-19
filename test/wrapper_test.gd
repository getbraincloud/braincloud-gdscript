# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_init(bc)
	await test_authenticate_anonymous(bc)
	await test_reauthenticate(bc)
	await test_get_server_version(bc)
	await test_stored_profile_id(bc)
	await test_stored_anonymous_id(bc)
	await test_always_allow_profile_switch(bc)
	await test_get_app_version(bc)
	await test_get_braincloud_version(bc)

func test_init(bc: BCTest) -> void:
	bc.begin_test("test_init")
	bc.expect_true(bc.bc_wrapper.is_initialized(), "bc_wrapper should be initialized")

func test_authenticate_anonymous(bc: BCTest) -> void:
	bc.begin_test("test_authenticate_anonymous")
	bc.bc_wrapper.braincloud_client.authentication_service.clear_saved_profile_id()
	var response := await bc.bc_wrapper.authenticate_anonymous()
	bc.expect_status_ok(response)
	var data: Dictionary = response.get("data", {})
	bc.expect_true(data.has("profileId"), "data should have profileId")
	# Re-authenticate as user_a to restore session
	await bc.bc_wrapper.authenticate_universal(bc.user_a.name, bc.user_a.password, true)

func test_reauthenticate(bc: BCTest) -> void:
	bc.begin_test("test_reauthenticate")
	# Switch to anonymous so reauthenticate has stored credentials to use
	bc.bc_wrapper.braincloud_client.authentication_service.clear_saved_profile_id()
	await bc.bc_wrapper.authenticate_anonymous()
	await bc.bc_wrapper.logout(false)
	var response: Dictionary = await bc.bc_wrapper.reauthenticate()
	bc.expect_status_ok(response)
	# Restore session as user_a for subsequent test suites
	await bc.bc_wrapper.authenticate_universal(bc.user_a.name, bc.user_a.password, true)

func test_get_server_version(bc: BCTest) -> void:
	bc.begin_test("test_get_server_version")
	var response := await bc.bc_wrapper.braincloud_client.authentication_service.get_server_version()
	bc.expect_status_ok(response)
	var data: Dictionary = response.get("data", {})
	bc.expect_true(data.has("serverVersion"), "data should have serverVersion")
	bc.expect_true(data.get("serverVersion", "").length() > 0, "serverVersion should be non-empty")

func test_stored_profile_id(bc: BCTest) -> void:
	bc.begin_test("test_stored_profile_id")
	var original: String = bc.bc_wrapper.get_stored_profile_id()
	bc.expect_true(original.length() > 0, "stored profile id should be non-empty after auth")
	bc.bc_wrapper.set_stored_profile_id("test-override-id")
	bc.expect_eq(bc.bc_wrapper.get_stored_profile_id(), "test-override-id", "set_stored_profile_id should update the stored value")
	bc.bc_wrapper.reset_stored_profile_id()
	bc.expect_eq(bc.bc_wrapper.get_stored_profile_id(), "", "reset_stored_profile_id should clear the value")
	# Restore original
	bc.bc_wrapper.set_stored_profile_id(original)

func test_stored_anonymous_id(bc: BCTest) -> void:
	bc.begin_test("test_stored_anonymous_id")
	var original: String = bc.bc_wrapper.get_stored_anonymous_id()
	bc.bc_wrapper.set_stored_anonymous_id("test-anon-id")
	bc.expect_eq(bc.bc_wrapper.get_stored_anonymous_id(), "test-anon-id", "set_stored_anonymous_id should update the stored value")
	bc.bc_wrapper.reset_stored_anonymous_id()
	bc.expect_eq(bc.bc_wrapper.get_stored_anonymous_id(), "", "reset_stored_anonymous_id should clear the value")
	# Restore original
	bc.bc_wrapper.set_stored_anonymous_id(original)

func test_always_allow_profile_switch(bc: BCTest) -> void:
	bc.begin_test("test_always_allow_profile_switch")
	bc.bc_wrapper.always_allow_profile_switch = false
	bc.expect_true(not bc.bc_wrapper.always_allow_profile_switch, "should be false after setting")
	bc.bc_wrapper.always_allow_profile_switch = true
	bc.expect_true(bc.bc_wrapper.always_allow_profile_switch, "should be true after setting")

func test_get_app_version(bc: BCTest) -> void:
	bc.begin_test("test_get_app_version")
	var version: String = bc.bc_wrapper.braincloud_client.get_app_version()
	bc.expect_true(version.length() > 0, "app version should be non-empty")

func test_get_braincloud_version(bc: BCTest) -> void:
	bc.begin_test("test_get_braincloud_version")
	var version: String = bc.bc_wrapper.braincloud_client.get_braincloud_version()
	bc.expect_true(version.length() > 0, "braincloud version should be non-empty")
