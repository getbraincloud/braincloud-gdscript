# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_get_eligible_promotions(bc)
	await test_refresh_promotions(bc)
	await test_verify_purchase_bad(bc)
	await test_start_purchase(bc)
	await test_get_store_info(bc)
	await test_get_store_info_fail(bc)
	await test_get_user_token(bc)
	await test_get_user_token_fail(bc)

func test_get_eligible_promotions(bc: BCTest) -> void:
	bc.begin_test("test_get_eligible_promotions")
	var response := await bc.bc_wrapper.app_store_service.get_eligible_promotions()
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_refresh_promotions(bc: BCTest) -> void:
	bc.begin_test("test_refresh_promotions")
	var response := await bc.bc_wrapper.app_store_service.refresh_promotions()
	bc.expect_status_ok(response)

func test_verify_purchase_bad(bc: BCTest) -> void:
	bc.begin_test("test_verify_purchase_bad")
	var response := await bc.bc_wrapper.app_store_service.verify_purchase("apple", {"badData": true})
	var status: int = response.get("status", -1)
	# deliberately garbage receipt data ({"badData": true}) — a 400/403 is the expected outcome
	bc.expect_true(
		status == StatusCodes.BAD_REQUEST or status == StatusCodes.FORBIDDEN,
		"Expected 400 or 403 for bad purchase data, got %d" % status
	)

func test_start_purchase(bc: BCTest) -> void:
	bc.begin_test("test_start_purchase")
	var response := await bc.bc_wrapper.app_store_service.start_purchase("googlePlay", "com.example.item")
	var status: int = response.get("status", -1)
	# nonexistent product id / no real store item configured for this test app — 400 is expected
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400 for start_purchase, got %d" % status
	)

func test_get_store_info(bc: BCTest) -> void:
	bc.begin_test("test_get_store_info")
	var response := await bc.bc_wrapper.app_store_service.get_store_info("xsolla")
	bc.expect_status_ok(response)

func test_get_store_info_fail(bc: BCTest) -> void:
	bc.begin_test("test_get_store_info_fail")
	var response := await bc.bc_wrapper.app_store_service.get_store_info("_invalid_store_id_")
	bc.expect_status(response, StatusCodes.BAD_REQUEST)
	bc.expect_eq(response.get("reason_code", 0), ReasonCodes.INVALID_STORE_ID, "reason_code")

func test_get_user_token(bc: BCTest) -> void:
	bc.begin_test("test_get_user_token")
	var response := await bc.bc_wrapper.app_store_service.get_user_token("xsolla")
	bc.expect_status_ok(response)

func test_get_user_token_fail(bc: BCTest) -> void:
	bc.begin_test("test_get_user_token_fail")
	var response := await bc.bc_wrapper.app_store_service.get_user_token("_invalid_store_id_")
	bc.expect_status(response, StatusCodes.BAD_REQUEST)
	bc.expect_eq(response.get("reason_code", 0), ReasonCodes.INVALID_STORE_ID, "reason_code")
