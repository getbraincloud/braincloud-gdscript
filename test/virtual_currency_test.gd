# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_get_currency(bc)
	await test_award_currency(bc)
	await test_consume_currency(bc)
	await test_reset_currency(bc)

func test_get_currency(bc: BCTest) -> void:
	bc.begin_test("test_get_currency")
	var response := await bc.bc_wrapper.virtual_currency_service.get_currency("")
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_award_currency(bc: BCTest) -> void:
	bc.begin_test("test_award_currency")
	var response := await bc.bc_wrapper.virtual_currency_service.award_currency("credits", 1)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)

func test_consume_currency(bc: BCTest) -> void:
	bc.begin_test("test_consume_currency")
	var response := await bc.bc_wrapper.virtual_currency_service.consume_currency("credits", 1)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)

func test_reset_currency(bc: BCTest) -> void:
	bc.begin_test("test_reset_currency")
	var response := await bc.bc_wrapper.virtual_currency_service.reset_currency()
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)
