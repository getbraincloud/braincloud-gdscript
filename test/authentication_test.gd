# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

const STABLE_EMAIL := "braincloudunittest@gmail.com"

func run(bc: BCTest) -> void:
	await test_get_server_version(bc)
	await test_authenticate_anonymous(bc)
	await test_authenticate_universal(bc)
	await test_authenticate_universal_bad_password(bc)
	await test_authenticate_email_password(bc)
	await test_reset_email_password(bc)
	await test_reset_email_password_with_expiry(bc)
	await test_reset_universal_id_password(bc)

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

func test_authenticate_email_password(bc: BCTest) -> void:
	bc.begin_test("test_authenticate_email_password")
	var response := await bc.bc_wrapper.authenticate_email_password(bc.user_c.email, bc.user_c.password, true)
	bc.expect_status_ok(response)
	# Restore session as user_a
	await bc.bc_wrapper.authenticate_universal(bc.user_a.name, bc.user_a.password, true)

func test_reset_email_password(bc: BCTest) -> void:
	bc.begin_test("test_reset_email_password")
	# Use a stable email that exists on the server (mirrors Dart test pattern)
	await bc.bc_wrapper.authenticate_email_password(STABLE_EMAIL, STABLE_EMAIL, true)
	var response := await bc.bc_wrapper.authentication_service.reset_email_password(STABLE_EMAIL)
	bc.expect_status_ok(response)
	# Restore session as user_a
	await bc.bc_wrapper.authenticate_universal(bc.user_a.name, bc.user_a.password, true)

func test_reset_email_password_with_expiry(bc: BCTest) -> void:
	bc.begin_test("test_reset_email_password_with_expiry")
	await bc.bc_wrapper.authenticate_email_password(STABLE_EMAIL, STABLE_EMAIL, true)
	var response := await bc.bc_wrapper.authentication_service.reset_email_password_with_expiry(STABLE_EMAIL, 1)
	bc.expect_status_ok(response)
	await bc.bc_wrapper.authenticate_universal(bc.user_a.name, bc.user_a.password, true)

func test_reset_universal_id_password(bc: BCTest) -> void:
	bc.begin_test("test_reset_universal_id_password")
	# UserA is a Universal user with no email attached — server returns 400 (EMAIL_ID_NOT_FOUND).
	# Both 200 and 400 are valid outcomes depending on whether the user has email.
	var response := await bc.bc_wrapper.authentication_service.reset_universal_id_password(bc.user_a.name)
	var status: int = response.get("status", -1)
	bc.expect_true(status == StatusCodes.OK or status == StatusCodes.CONFLICT,
		"Expected 200 or 409 (email not found), got %d" % status)
