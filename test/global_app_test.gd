# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_read_properties(bc)
	await test_read_selected_properties(bc)
	await test_read_properties_in_categories(bc)

func test_read_properties(bc: BCTest) -> void:
	bc.begin_test("test_read_properties")
	var response := await bc.bc_wrapper.global_app_service.read_properties()
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_read_selected_properties(bc: BCTest) -> void:
	bc.begin_test("test_read_selected_properties")
	var response := await bc.bc_wrapper.global_app_service.read_selected_properties(["prop1", "prop2", "prop3"])
	bc.expect_status_ok(response)

func test_read_properties_in_categories(bc: BCTest) -> void:
	bc.begin_test("test_read_properties_in_categories")
	var response := await bc.bc_wrapper.global_app_service.read_properties_in_categories(["test"])
	bc.expect_status_ok(response)
