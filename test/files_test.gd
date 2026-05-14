# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

const CLOUD_PATH := "gdscript_test"
const CLOUD_FILENAME := "test_file.txt"

func run(bc: BCTest) -> void:
	await test_prepare_upload(bc)
	await test_get_file_list(bc)
	await test_list_user_files_in_path(bc)
	await test_get_cdn_url_for_file(bc)
	await test_delete_user_file(bc)
	await test_delete_user_files(bc)

func test_prepare_upload(bc: BCTest) -> void:
	bc.begin_test("test_prepare_upload")
	var file_data := "Hello BrainCloud GDScript Test".to_utf8_buffer()
	var response := await bc.bc_wrapper.file_service.upload_file_from_memory(
		CLOUD_PATH, CLOUD_FILENAME, true, true, file_data
	)
	bc.expect_status_ok(response)
	var data: Dictionary = response.get("data", {})
	bc.expect_true(data.has("fileDetails"), "data should have fileDetails")
	if data.has("fileDetails"):
		bc.expect_true(data["fileDetails"].has("uploadId"), "fileDetails should have uploadId")

func test_get_file_list(bc: BCTest) -> void:
	bc.begin_test("test_get_file_list")
	var response := await bc.bc_wrapper.file_service.get_file_list("", true)
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_list_user_files_in_path(bc: BCTest) -> void:
	bc.begin_test("test_list_user_files_in_path")
	var response := await bc.bc_wrapper.file_service.get_file_list(CLOUD_PATH, false)
	bc.expect_status_ok(response)
	var data: Dictionary = response.get("data", {})
	bc.expect_true(data.has("fileList"), "data should have fileList")

func test_get_cdn_url_for_file(bc: BCTest) -> void:
	bc.begin_test("test_get_cdn_url_for_file")
	var response := await bc.bc_wrapper.file_service.get_cdn_url_for_file("", "nonexistent.txt")
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)

func test_delete_user_file(bc: BCTest) -> void:
	bc.begin_test("test_delete_user_file")
	var response := await bc.bc_wrapper.file_service.delete_user_file(CLOUD_PATH, CLOUD_FILENAME)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)

func test_delete_user_files(bc: BCTest) -> void:
	bc.begin_test("test_delete_user_files")
	var response := await bc.bc_wrapper.file_service.delete_user_files("", true)
	bc.expect_status_ok(response)
