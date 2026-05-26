# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_get_my_campaigns(bc)

func test_get_my_campaigns(bc: BCTest) -> void:
	bc.begin_test("test_get_my_campaigns")
	var response := await bc.bc_wrapper.campaign_service.get_my_campaigns()
	bc.expect_status_ok(response)
