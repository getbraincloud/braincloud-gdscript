# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

var _group_id: String = ""

func run(bc: BCTest) -> void:
	await test_setup_group(bc)
	await test_get_file_list(bc)
	await test_check_filename_not_exists(bc)
	await test_get_file_info_bad_id(bc)
	await test_get_cdn_url_bad_id(bc)
	await test_copy_file_bad_id(bc)
	await test_delete_file_bad_id(bc)
	await test_cleanup_group(bc)

func test_setup_group(bc: BCTest) -> void:
	bc.begin_test("test_setup_group")
	var response := await bc.bc_wrapper.group_service.create_group(
		"GDScriptGroupFileTest", "test", false, {"other": 1}, {}, {}, {}
	)
	bc.expect_status_ok(response)
	_group_id = response.get("data", {}).get("groupId", "")
	bc.expect_true(_group_id.length() > 0, "Should have a groupId")

func test_get_file_list(bc: BCTest) -> void:
	bc.begin_test("test_get_file_list")
	if _group_id.is_empty():
		bc.expect_true(false, "No group — skipping")
		return
	var response := await bc.bc_wrapper.group_file_service.get_file_list(_group_id, "", false)
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_check_filename_not_exists(bc: BCTest) -> void:
	bc.begin_test("test_check_filename_not_exists")
	if _group_id.is_empty():
		bc.expect_true(false, "No group — skipping")
		return
	var response := await bc.bc_wrapper.group_file_service.check_filename(_group_id, "", "nonexistent.png")
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.ACCEPTED or status == StatusCodes.BAD_REQUEST,
		"Expected 200, 202 or 400, got %d" % status
	)

func test_get_file_info_bad_id(bc: BCTest) -> void:
	bc.begin_test("test_get_file_info_bad_id")
	if _group_id.is_empty():
		bc.expect_true(false, "No group — skipping")
		return
	var response := await bc.bc_wrapper.group_file_service.get_file_info(
		_group_id, "00000000-0000-0000-0000-000000000000"
	)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)

func test_get_cdn_url_bad_id(bc: BCTest) -> void:
	bc.begin_test("test_get_cdn_url_bad_id")
	if _group_id.is_empty():
		bc.expect_true(false, "No group — skipping")
		return
	var response := await bc.bc_wrapper.group_file_service.get_cdn_url(
		_group_id, "00000000-0000-0000-0000-000000000000"
	)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)

func test_copy_file_bad_id(bc: BCTest) -> void:
	bc.begin_test("test_copy_file_bad_id")
	if _group_id.is_empty():
		bc.expect_true(false, "No group — skipping")
		return
	var response := await bc.bc_wrapper.group_file_service.copy_file(
		_group_id, "00000000-0000-0000-0000-000000000000", -1, "", 0, "copy.png", true
	)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)

func test_delete_file_bad_id(bc: BCTest) -> void:
	bc.begin_test("test_delete_file_bad_id")
	if _group_id.is_empty():
		bc.expect_true(false, "No group — skipping")
		return
	var response := await bc.bc_wrapper.group_file_service.delete_file(
		_group_id, "00000000-0000-0000-0000-000000000000", -1, "nonexistent.png"
	)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)

func test_cleanup_group(bc: BCTest) -> void:
	bc.begin_test("test_cleanup_group")
	if _group_id.is_empty():
		bc.expect_true(true, "Nothing to clean up")
		return
	var response := await bc.bc_wrapper.group_service.delete_group(_group_id, -1)
	bc.expect_status_ok(response)
	_group_id = ""
