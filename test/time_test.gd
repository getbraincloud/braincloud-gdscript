# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_read_server_time(bc)
	await test_read_server_time_value(bc)

func test_read_server_time(bc: BCTest) -> void:
	bc.begin_test("test_read_server_time")
	var response := await bc.bc_wrapper.time_service.read_server_time()
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")
	var data: Dictionary = response.get("data", {})
	bc.expect_true(data.has("server_time"), "data should have server_time")

func test_read_server_time_value(bc: BCTest) -> void:
	bc.begin_test("test_read_server_time_value")
	var response := await bc.bc_wrapper.time_service.read_server_time()
	bc.expect_status_ok(response)
	var server_time: int = response.get("data", {}).get("server_time", 0)
	bc.expect_true(server_time > 0, "server_time should be a positive integer (Unix ms), got %d" % server_time)
