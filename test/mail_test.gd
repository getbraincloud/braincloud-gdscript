# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_send_basic_email(bc)
	await test_send_advanced_email(bc)
	await test_send_advanced_email_by_address(bc)

func test_send_basic_email(bc: BCTest) -> void:
	bc.begin_test("test_send_basic_email")
	var response := await bc.bc_wrapper.mail_service.send_basic_email(
		bc.user_a.profile_id, "Test Subject", "Test Body"
	)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)

func test_send_advanced_email(bc: BCTest) -> void:
	bc.begin_test("test_send_advanced_email")
	var service_params := {
		"subject": "Test Subject - Advanced",
		"body": "Test body content.",
		"categories": ["unit-test"]
	}
	var response := await bc.bc_wrapper.mail_service.send_advanced_email(
		bc.user_a.profile_id, service_params
	)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)

func test_send_advanced_email_by_address(bc: BCTest) -> void:
	bc.begin_test("test_send_advanced_email_by_address")
	var service_params := {
		"subject": "Test Subject - By Address",
		"body": "Test body content.",
		"categories": ["unit-test"]
	}
	var email: String = bc.user_c.email if bc.user_c.email.length() > 0 else "test@test.getbraincloud.com"
	var response := await bc.bc_wrapper.mail_service.send_advanced_email_by_address(
		email, service_params
	)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)
