# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_get_server_version(bc)
	await test_authenticate_anonymous(bc)
	await test_authenticate_universal(bc)
	await test_authenticate_universal_bad_password(bc)
	await test_authenticate_universal_bad_user(bc)
	await test_authenticate_email_password(bc)
	await test_logout(bc)
	await test_reconnect(bc)
	await test_reset_email_password(bc)
	await test_reset_email_password_with_expiry(bc)
	await test_reset_email_password_advanced(bc)
	await test_reset_email_password_advanced_with_expiry(bc)
	await test_reset_universal_id_password(bc)
	await test_reset_universal_id_password_with_expiry(bc)
	await test_reset_universal_id_password_advanced(bc)
	await test_reset_universal_id_password_advanced_with_expiry(bc)

func test_get_server_version(bc: BCTest) -> void:
	bc.begin_test("test_get_server_version")
	var response := await bc.bc_wrapper.authentication_service.get_server_version()
	bc.expect_status_ok(response)
	var data: Dictionary = response.get("data", {})
	bc.expect_true(data.has("serverVersion"), "data should have serverVersion")

func test_authenticate_anonymous(bc: BCTest) -> void:
	bc.begin_test("test_authenticate_anonymous")
	bc.bc_wrapper.braincloud_client.authentication_service.clear_saved_profile_id()
	var response := await bc.bc_wrapper.authenticate_anonymous()
	bc.expect_status_ok(response)
	var data: Dictionary = response.get("data", {})
	bc.expect_true(data.has("profileId"), "data should have profileId")
	# Restore session as user_a
	await bc.bc_wrapper.authenticate_universal(bc.user_a.name, bc.user_a.password, true)

func test_authenticate_universal(bc: BCTest) -> void:
	bc.begin_test("test_authenticate_universal")
	var response := await bc.bc_wrapper.authenticate_universal(bc.user_a.name, bc.user_a.password, true)
	bc.expect_status_ok(response)
	var data: Dictionary = response.get("data", {})
	bc.expect_true(data.has("profileId"), "data should have profileId")

func test_authenticate_universal_bad_password(bc: BCTest) -> void:
	bc.begin_test("test_authenticate_universal_bad_password")
	var response := await bc.bc_wrapper.authenticate_universal(bc.user_a.name, "wrong_password_xyz", false)
	bc.expect_status(response, StatusCodes.FORBIDDEN)
	# Restore session as user_a
	await bc.bc_wrapper.authenticate_universal(bc.user_a.name, bc.user_a.password, true)

func test_authenticate_universal_bad_user(bc: BCTest) -> void:
	bc.begin_test("test_authenticate_universal_bad_user")
	var response := await bc.bc_wrapper.authenticate_universal(bc.user_a.name + "make_invalid", bc.user_a.password, false)
	bc.expect_status(response, StatusCodes.ACCEPTED)
	# Restore session as user_a
	await bc.bc_wrapper.authenticate_universal(bc.user_a.name, bc.user_a.password, true)

func test_authenticate_email_password(bc: BCTest) -> void:
	bc.begin_test("test_authenticate_email_password")
	var response := await bc.bc_wrapper.authenticate_email_password(bc.user_c.email, bc.user_c.password, true)
	bc.expect_status_ok(response)
	# Restore session as user_a
	await bc.bc_wrapper.authenticate_universal(bc.user_a.name, bc.user_a.password, true)

func test_logout(bc: BCTest) -> void:
	bc.begin_test("test_logout")
	var response := await bc.bc_wrapper.logout(true)
	bc.expect_status_ok(response)
	# After forget_user=true all stored credentials are cleared — reconnect does anonymous auth
	# which returns 202 (no force_create with a fresh anon_id)
	var reconnect_resp := await bc.bc_wrapper.reconnect()
	var status: int = reconnect_resp.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.ACCEPTED,
		"reconnect after forget should return 200 or 202, got %d" % status
	)
	# Restore session as user_a
	await bc.bc_wrapper.authenticate_universal(bc.user_a.name, bc.user_a.password, true)

func test_reconnect(bc: BCTest) -> void:
	bc.begin_test("test_reconnect")
	# Logout without forgetting — stored auth type + credentials stay
	var logout_resp := await bc.bc_wrapper.logout(false)
	bc.expect_status_ok(logout_resp)
	# Reconnect uses stored Universal credentials → should return 200
	var response := await bc.bc_wrapper.reconnect()
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.ACCEPTED,
		"Expected 200 or 202 on reconnect, got %d" % status
	)
	# Restore session as user_a to be safe
	await bc.bc_wrapper.authenticate_universal(bc.user_a.name, bc.user_a.password, true)

func test_reset_email_password(bc: BCTest) -> void:
	bc.begin_test("test_reset_email_password")
	var email: String = bc.ids.get("stableEmail", "braincloudunittest@gmail.com")
	await bc.bc_wrapper.authenticate_email_password(email, email, true)
	var response := await bc.bc_wrapper.authentication_service.reset_email_password(email)
	bc.expect_status_ok(response)
	# Restore session as user_a
	await bc.bc_wrapper.authenticate_universal(bc.user_a.name, bc.user_a.password, true)

func test_reset_email_password_with_expiry(bc: BCTest) -> void:
	bc.begin_test("test_reset_email_password_with_expiry")
	var email: String = bc.ids.get("stableEmail", "braincloudunittest@gmail.com")
	await bc.bc_wrapper.authenticate_email_password(email, email, true)
	var response := await bc.bc_wrapper.authentication_service.reset_email_password_with_expiry(email, 1)
	bc.expect_status_ok(response)
	await bc.bc_wrapper.authenticate_universal(bc.user_a.name, bc.user_a.password, true)

func test_reset_email_password_advanced(bc: BCTest) -> void:
	bc.begin_test("test_reset_email_password_advanced")
	var email: String = bc.ids.get("stableEmail", "braincloudunittest@gmail.com")
	await bc.bc_wrapper.authenticate_email_password(email, email, true)
	var service_params := {
		"fromAddress": "fromAddress",
		"fromName": "fromName",
		"replyToAddress": "replyToAddress",
		"replyToName": "replyToName",
		"templateId": "8f14c77d-61f4-4966-ab6d-0bee8b13d090",
		"subject": "subject",
		"body": "Body goes here",
		"substitutions": {":name": "John Doe", ":resetLink": "www.dummyLink.io"},
		"categories": ["category1", "category2"]
	}
	var response := await bc.bc_wrapper.authentication_service.reset_email_password_advanced(email, service_params)
	# Server returns 400 for invalid fromAddress config
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)
	await bc.bc_wrapper.authenticate_universal(bc.user_a.name, bc.user_a.password, true)

func test_reset_email_password_advanced_with_expiry(bc: BCTest) -> void:
	bc.begin_test("test_reset_email_password_advanced_with_expiry")
	var email: String = bc.ids.get("stableEmail", "braincloudunittest@gmail.com")
	await bc.bc_wrapper.authenticate_email_password(email, email, true)
	var service_params := {
		"fromAddress": "fromAddress",
		"fromName": "fromName",
		"replyToAddress": "replyToAddress",
		"replyToName": "replyToName",
		"templateId": "8f14c77d-61f4-4966-ab6d-0bee8b13d090",
		"subject": "subject",
		"body": "Body goes here",
		"substitutions": {":name": "John Doe", ":resetLink": "www.dummyLink.io"},
		"categories": ["category1", "category2"]
	}
	var response := await bc.bc_wrapper.authentication_service.reset_email_password_advanced_with_expiry(email, service_params, 1)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)
	await bc.bc_wrapper.authenticate_universal(bc.user_a.name, bc.user_a.password, true)

func test_reset_universal_id_password(bc: BCTest) -> void:
	bc.begin_test("test_reset_universal_id_password")
	# UserA is a Universal user with no email attached — server returns 400 (EMAIL_ID_NOT_FOUND).
	# 200, 400, and 409 are all valid outcomes depending on whether the user has email.
	var response := await bc.bc_wrapper.authentication_service.reset_universal_id_password(bc.user_a.name)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST or status == StatusCodes.CONFLICT,
		"Expected 200, 400, or 409, got %d" % status
	)

func test_reset_universal_id_password_with_expiry(bc: BCTest) -> void:
	bc.begin_test("test_reset_universal_id_password_with_expiry")
	var response := await bc.bc_wrapper.authentication_service.reset_universal_id_password_with_expiry(bc.user_a.name, 1)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST or status == StatusCodes.CONFLICT,
		"Expected 200, 400, or 409, got %d" % status
	)

func test_reset_universal_id_password_advanced(bc: BCTest) -> void:
	bc.begin_test("test_reset_universal_id_password_advanced")
	var service_params := {
		"templateId": "8f14c77d-61f4-4966-ab6d-0bee8b13d090",
		"substitutions": {":name": "John Doe", ":resetLink": "www.dummyLink.io"},
		"categories": ["category1", "category2"]
	}
	var response := await bc.bc_wrapper.authentication_service.reset_universal_id_password_advanced(bc.user_a.name, service_params)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST or status == StatusCodes.CONFLICT,
		"Expected 200, 400, or 409, got %d" % status
	)

func test_reset_universal_id_password_advanced_with_expiry(bc: BCTest) -> void:
	bc.begin_test("test_reset_universal_id_password_advanced_with_expiry")
	var service_params := {
		"templateId": "8f14c77d-61f4-4966-ab6d-0bee8b13d090",
		"substitutions": {":name": "John Doe", ":resetLink": "www.dummyLink.io"},
		"categories": ["category1", "category2"]
	}
	var response := await bc.bc_wrapper.authentication_service.reset_universal_id_password_advanced_with_expiry(bc.user_a.name, service_params, 1)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST or status == StatusCodes.CONFLICT,
		"Expected 200, 400, or 409, got %d" % status
	)
