# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_get_eligible_promotions(bc)
	await test_verify_purchase_bad(bc)

func test_get_eligible_promotions(bc: BCTest) -> void:
	bc.begin_test("test_get_eligible_promotions")
	var response := await bc.bc_wrapper.app_store_service.get_eligible_promotions()
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_verify_purchase_bad(bc: BCTest) -> void:
	bc.begin_test("test_verify_purchase_bad")
	var response := await bc.bc_wrapper.app_store_service.verify_purchase("apple", {"badData": true})
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.BAD_REQUEST or status == StatusCodes.FORBIDDEN,
		"Expected 400 or 403 for bad purchase data, got %d" % status
	)
