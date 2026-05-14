# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_get_blockchain_items(bc)
	await test_get_uniqs(bc)

func test_get_blockchain_items(bc: BCTest) -> void:
	bc.begin_test("test_get_blockchain_items")
	var response := await bc.bc_wrapper.blockchain_service.get_blockchain_items("default", {})
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)

func test_get_uniqs(bc: BCTest) -> void:
	bc.begin_test("test_get_uniqs")
	var response := await bc.bc_wrapper.blockchain_service.get_uniqs("default", {})
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)
