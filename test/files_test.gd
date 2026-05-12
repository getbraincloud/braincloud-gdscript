# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_get_file_list(bc)
	await test_get_cdn_url_for_file(bc)
	await test_delete_user_files(bc)

func test_get_file_list(bc: BCTest) -> void:
	bc.begin_test("test_get_file_list")
	var response := await bc.bc_wrapper.file_service.get_file_list("", true)
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_get_cdn_url_for_file(bc: BCTest) -> void:
	bc.begin_test("test_get_cdn_url_for_file")
	var response := await bc.bc_wrapper.file_service.get_cdn_url_for_file("", "nonexistent.txt")
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)

func test_delete_user_files(bc: BCTest) -> void:
	bc.begin_test("test_delete_user_files")
	var response := await bc.bc_wrapper.file_service.delete_user_files("", true)
	bc.expect_status_ok(response)
