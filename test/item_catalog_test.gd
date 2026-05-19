# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_get_catalog_items_page(bc)
	await test_get_catalog_item_definition(bc)
	await test_get_catalog_items_page_offset(bc)

func test_get_catalog_items_page(bc: BCTest) -> void:
	bc.begin_test("test_get_catalog_items_page")
	var context := {
		"pagination": {"rowsPerPage": 10, "pageNumber": 1},
		"searchCriteria": {},
		"sortCriteria": {}
	}
	var response := await bc.bc_wrapper.item_catalog_service.get_catalog_items_page(context)
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_get_catalog_item_definition(bc: BCTest) -> void:
	bc.begin_test("test_get_catalog_item_definition")
	var response := await bc.bc_wrapper.item_catalog_service.get_catalog_item_definition("sword001")
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)

func test_get_catalog_items_page_offset(bc: BCTest) -> void:
	bc.begin_test("test_get_catalog_items_page_offset")
	var context_str := "eyJzZWFyY2hDcml0ZXJpYSI6eyJnYW1lSWQiOiIyMDAwMSJ9LCJzb3J0Q3JpdGVyaWEiOnt9LCJwYWdpbmF0aW9uIjp7InJvd3NQZXJQYWdlIjoxMDAsInBhZ2VOdW1iZXIiOm51bGx9LCJvcHRpb25zIjpudWxsfQ"
	var response := await bc.bc_wrapper.item_catalog_service.get_catalog_items_page_offset(context_str, 1)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)
