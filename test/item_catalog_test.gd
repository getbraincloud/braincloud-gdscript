# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_get_catalog_items_page(bc)

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
