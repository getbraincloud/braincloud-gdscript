# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_read_all_global_stats(bc)
	await test_increment_global_stats(bc)

func test_read_all_global_stats(bc: BCTest) -> void:
	bc.begin_test("test_read_all_global_stats")
	var response := await bc.bc_wrapper.global_statistics_service.read_all_global_stats()
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_increment_global_stats(bc: BCTest) -> void:
	bc.begin_test("test_increment_global_stats")
	var response := await bc.bc_wrapper.global_statistics_service.increment_global_stats({"POINTS": 1})
	bc.expect_status_ok(response)
