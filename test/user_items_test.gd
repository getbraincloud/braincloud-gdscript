# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

var _item_ids: Array = []

func run(bc: BCTest) -> void:
	await test_award_user_item(bc)
	await test_drop_user_item(bc)
	await test_get_user_items_page(bc)
	await test_get_user_item(bc)
	await test_give_user_item_to(bc)
	await test_sell_user_item(bc)
	await test_update_user_item_data(bc)
	await test_use_user_item(bc)

func _next_item_id(bc: BCTest) -> String:
	if _item_ids.size() > 0:
		return _item_ids[0]
	var page_resp := await bc.bc_wrapper.user_items_service.get_user_items_page(
		{"pagination": {"rowsPerPage": 1, "pageNumber": 1}, "searchCriteria": {"defId": "sword001"}, "sortCriteria": {}},
		false
	)
	var items: Array = page_resp.get("data", {}).get("results", {}).get("items", [])
	if items.size() > 0:
		return items[0].get("userItemId", "")
	return ""

func test_award_user_item(bc: BCTest) -> void:
	bc.begin_test("test_award_user_item")
	var response := await bc.bc_wrapper.user_items_service.award_user_item("sword001", 5, true)
	bc.expect_status_ok(response)
	var items: Dictionary = response.get("data", {}).get("items", {})
	_item_ids = items.keys()
	bc.expect_true(_item_ids.size() > 0, "Should have received item IDs")

func test_drop_user_item(bc: BCTest) -> void:
	bc.begin_test("test_drop_user_item")
	var item_id: String = await _next_item_id(bc)
	if item_id.is_empty():
		bc.expect_true(true, "no item to drop, skipping")
		return
	var response := await bc.bc_wrapper.user_items_service.drop_user_item(item_id, 1, true)
	bc.expect_status_ok(response)
	if not _item_ids.is_empty():
		_item_ids.remove_at(0)

func test_get_user_items_page(bc: BCTest) -> void:
	bc.begin_test("test_get_user_items_page")
	var context := {
		"pagination": {"rowsPerPage": 50, "pageNumber": 1},
		"searchCriteria": {"defId": "sword001"},
		"sortCriteria": {"createdAt": 1, "updatedAt": -1}
	}
	var response := await bc.bc_wrapper.user_items_service.get_user_items_page(context, true)
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_get_user_item(bc: BCTest) -> void:
	bc.begin_test("test_get_user_item")
	var item_id: String = await _next_item_id(bc)
	if item_id.is_empty():
		bc.expect_true(true, "no item to get, skipping")
		return
	var response := await bc.bc_wrapper.user_items_service.get_user_item(item_id, true)
	bc.expect_status_ok(response)

func test_give_user_item_to(bc: BCTest) -> void:
	bc.begin_test("test_give_user_item_to")
	var item_id: String = await _next_item_id(bc)
	if item_id.is_empty():
		bc.expect_true(true, "no item to give, skipping")
		return
	var response := await bc.bc_wrapper.user_items_service.give_user_item_to(
		bc.user_b.profile_id, item_id, 1, "", 0
	)
	bc.expect_status_ok(response)
	if not _item_ids.is_empty():
		_item_ids.remove_at(0)

func test_sell_user_item(bc: BCTest) -> void:
	bc.begin_test("test_sell_user_item")
	var item_id: String = await _next_item_id(bc)
	if item_id.is_empty():
		bc.expect_true(true, "no item to sell, skipping")
		return
	var response := await bc.bc_wrapper.user_items_service.sell_user_item(item_id, 1, "", true)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)
	if status == StatusCodes.OK and not _item_ids.is_empty():
		_item_ids.remove_at(0)

func test_update_user_item_data(bc: BCTest) -> void:
	bc.begin_test("test_update_user_item_data")
	var item_id: String = await _next_item_id(bc)
	if item_id.is_empty():
		bc.expect_true(true, "no item to update, skipping")
		return
	var response := await bc.bc_wrapper.user_items_service.update_user_item_data(
		item_id, {"customKey": "customValue"}
	)
	bc.expect_status_ok(response)

func test_use_user_item(bc: BCTest) -> void:
	bc.begin_test("test_use_user_item")
	var item_id: String = await _next_item_id(bc)
	if item_id.is_empty():
		bc.expect_true(true, "no item to use, skipping")
		return
	var response := await bc.bc_wrapper.user_items_service.use_user_item(item_id, 1, {}, true)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)
