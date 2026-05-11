# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_init(bc)
	await test_authenticate_anonymous(bc)
	await test_reauthenticate(bc)

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
