# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_get_global_file_list(bc)

func test_get_global_file_list(bc: BCTest) -> void:
	bc.begin_test("test_get_global_file_list")
	var response := await bc.bc_wrapper.global_file_service.get_global_file_list("", true)
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")
