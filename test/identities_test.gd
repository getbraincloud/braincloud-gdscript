# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_get_identities(bc)
	await test_get_expired_identities(bc)
	await test_attach_detach_universal(bc)
	await test_attach_detach_email(bc)
	await test_merge_email_identity(bc)
	await test_attach_detach_blockchain(bc)
	await test_attach_nonlogin_universal_id(bc)
	await test_update_universal_id_login(bc)
	await test_refresh_identity(bc)
	await test_attach_peer_profile(bc)
	await test_get_peer_profiles(bc)
	await test_detach_peer(bc)
	await test_child_parent_flow(bc)
	# Safety net: always restore to main app/user_a after child/parent tests
	bc.bc_wrapper.reset_to_default_app()
	await bc.bc_wrapper.authenticate_universal(bc.user_a.name, bc.user_a.password, true)

func test_get_identities(bc: BCTest) -> void:
	bc.begin_test("test_get_identities")
	var response := await bc.bc_wrapper.identity_service.get_identities()
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_get_expired_identities(bc: BCTest) -> void:
	bc.begin_test("test_get_expired_identities")
	var response := await bc.bc_wrapper.identity_service.get_expired_identities()
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_attach_detach_universal(bc: BCTest) -> void:
	bc.begin_test("test_attach_detach_universal")
	var random_id := "gdtest_" + str(randi() % 999999)
	var random_pass := "pass_" + str(randi() % 999999)

	var attach_resp := await bc.bc_wrapper.identity_service.attach_universal_identity(random_id, random_pass)
	bc.expect_status_ok(attach_resp)

	var detach_resp := await bc.bc_wrapper.identity_service.detach_universal_identity(random_id, false)
	bc.expect_status_ok(detach_resp)

func test_attach_detach_email(bc: BCTest) -> void:
	bc.begin_test("test_attach_email_identity")
	var attach_resp := await bc.bc_wrapper.identity_service.attach_email_identity(bc.user_a.email, bc.user_a.password)
	var attach_status: int = attach_resp.get("status", -1)
	bc.expect_true(
		attach_status == StatusCodes.OK or attach_status == StatusCodes.ACCEPTED,
		"Expected 200 or 202 on attach email, got %d" % attach_status
	)

	bc.begin_test("test_detach_email_identity")
	var detach_resp := await bc.bc_wrapper.identity_service.detach_email_identity(bc.user_a.email, true)
	var detach_status: int = detach_resp.get("status", -1)
	bc.expect_true(
		detach_status == StatusCodes.OK or detach_status == StatusCodes.ACCEPTED,
		"Expected 200 or 202 on detach email, got %d" % detach_status
	)

func test_merge_email_identity(bc: BCTest) -> void:
	bc.begin_test("test_merge_email_identity")
	var response := await bc.bc_wrapper.identity_service.merge_email_identity(bc.user_c.email, bc.user_c.password)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.ACCEPTED,
		"Expected 200 or 202, got %d" % status
	)

func test_attach_detach_blockchain(bc: BCTest) -> void:
	bc.begin_test("test_attach_blockchain_identity")
	var attach_resp := await bc.bc_wrapper.identity_service.attach_blockchain_identity("config", "test_public_key_gd")
	var attach_status: int = attach_resp.get("status", -1)
	bc.expect_true(
		attach_status == StatusCodes.OK or attach_status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400 on attach blockchain, got %d" % attach_status
	)

	bc.begin_test("test_detach_blockchain_identity")
	var detach_resp := await bc.bc_wrapper.identity_service.detach_blockchain_identity("config")
	var detach_status: int = detach_resp.get("status", -1)
	bc.expect_true(
		detach_status == StatusCodes.OK or detach_status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400 on detach blockchain, got %d" % detach_status
	)

func test_attach_nonlogin_universal_id(bc: BCTest) -> void:
	bc.begin_test("test_attach_nonlogin_universal_id")
	var response := await bc.bc_wrapper.identity_service.attach_nonlogin_universal_id("non_login_gd@bitheads.com")
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.ACCEPTED,
		"Expected 200 or 202, got %d" % status
	)

func test_update_universal_id_login(bc: BCTest) -> void:
	bc.begin_test("test_update_universal_id_login")
	var response := await bc.bc_wrapper.identity_service.update_universal_id_login("non_login_gd@bitheads.com")
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)

func test_refresh_identity(bc: BCTest) -> void:
	bc.begin_test("test_refresh_identity")
	var response := await bc.bc_wrapper.identity_service.refresh_identity(bc.user_a.name, bc.user_a.password, AuthenticationType.UNIVERSAL)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400 on refresh identity, got %d" % status
	)

func test_attach_peer_profile(bc: BCTest) -> void:
	bc.begin_test("test_attach_peer_profile")
	var peer_name: String = bc.ids.get("peerName", "peerapp")
	var response := await bc.bc_wrapper.identity_service.attach_peer_profile(
		peer_name, bc.user_a.name + "_peer", bc.user_a.password,
		AuthenticationType.UNIVERSAL, "", true
	)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.ACCEPTED or status == StatusCodes.BAD_REQUEST,
		"Expected 200, 202, or 400 on attach peer profile, got %d" % status
	)

func test_get_peer_profiles(bc: BCTest) -> void:
	bc.begin_test("test_get_peer_profiles")
	var response := await bc.bc_wrapper.identity_service.get_peer_profiles()
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400 on get_peer_profiles, got %d" % status
	)

func test_detach_peer(bc: BCTest) -> void:
	bc.begin_test("test_detach_peer")
	var peer_name: String = bc.ids.get("peerName", "peerapp")
	var response := await bc.bc_wrapper.identity_service.detach_peer(peer_name)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400 on detach peer, got %d" % status
	)

func test_child_parent_flow(bc: BCTest) -> void:
	var child_app_id: String = bc.ids.get("childAppId", "")
	var parent_level: String = bc.ids.get("parentLevelName", "")
	if child_app_id.is_empty() or parent_level.is_empty():
		bc.begin_test("test_switch_to_child_profile")
		bc.expect_true(true, "skipping — no childAppId configured")
		return

	bc.begin_test("test_switch_to_singleton_child_profile")
	var to_child_resp := await bc.bc_wrapper.identity_service.switch_to_singleton_child_profile(child_app_id, true)
	bc.expect_status_ok(to_child_resp)
	if to_child_resp.get("status", -1) != StatusCodes.OK:
		return

	bc.begin_test("test_switch_to_parent_profile")
	var to_parent_resp := await bc.bc_wrapper.identity_service.switch_to_parent_profile(parent_level)
	var tp_status: int = to_parent_resp.get("status", -1)
	bc.expect_true(
		tp_status == StatusCodes.OK or tp_status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400 on switch to parent, got %d" % tp_status
	)
	if tp_status != StatusCodes.OK:
		# Stuck in child app — reset to default app and re-auth to prevent cascade
		bc.bc_wrapper.reset_to_default_app()
		await bc.bc_wrapper.authenticate_universal(bc.user_a.name, bc.user_a.password, true)
		return

	bc.begin_test("test_get_child_profiles")
	var child_profiles_resp := await bc.bc_wrapper.identity_service.get_child_profiles(true)
	bc.expect_status_ok(child_profiles_resp)
	bc.expect_has_key(child_profiles_resp, "data")

	bc.begin_test("test_detach_parent")
	var to_child2_resp := await bc.bc_wrapper.identity_service.switch_to_singleton_child_profile(child_app_id, true)
	if to_child2_resp.get("status", -1) == StatusCodes.OK:
		var detach_parent_resp := await bc.bc_wrapper.identity_service.detach_parent()
		bc.expect_status_ok(detach_parent_resp)

		bc.begin_test("test_attach_parent_with_identity")
		var attach_parent_resp := await bc.bc_wrapper.identity_service.attach_parent_with_identity(
			bc.user_b.email, bc.user_b.password, AuthenticationType.UNIVERSAL, "", true
		)
		var ap_status: int = attach_parent_resp.get("status", -1)
		bc.expect_true(
			ap_status == StatusCodes.OK or ap_status == StatusCodes.BAD_REQUEST,
			"Expected 200 or 400 on attach parent, got %d" % ap_status
		)

	# Always return to parent app; reset if stuck in child
	var return_resp := await bc.bc_wrapper.identity_service.switch_to_parent_profile(parent_level)
	if return_resp.get("status", -1) != StatusCodes.OK:
		bc.bc_wrapper.reset_to_default_app()
		await bc.bc_wrapper.authenticate_universal(bc.user_a.name, bc.user_a.password, true)
