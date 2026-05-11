# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_get_file_list(bc)

func test_get_file_list(bc: BCTest) -> void:
	bc.begin_test("test_get_file_list")

	# Create a temporary group to test with
	var create_resp := await bc.bc_wrapper.group_service.create_group(
		"GroupFileTestGroup", "test", false, {"other": 1}, {}, {}, {}
	)
	bc.expect_status_ok(create_resp)
	var group_id: String = create_resp.get("data", {}).get("groupId", "")
	if group_id.is_empty():
		bc.expect_true(false, "Failed to create group for group file test")
		return

	var response := await bc.bc_wrapper.group_file_service.get_file_list(group_id, "", true)
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

	# Cleanup
	await bc.bc_wrapper.group_service.delete_group(group_id, -1)
