# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_find_matches(bc)
	await test_create_and_abandon(bc)

func test_find_matches(bc: BCTest) -> void:
	bc.begin_test("test_find_matches")
	var response := await bc.bc_wrapper.async_match_service.find_matches()
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_create_and_abandon(bc: BCTest) -> void:
	bc.begin_test("test_create_and_abandon")
	var opponents := [{"platform": "BC", "id": bc.user_b.profile_id}]
	var create_resp := await bc.bc_wrapper.async_match_service.create_match(opponents, "")
	bc.expect_status_ok(create_resp)

	var match_data: Dictionary = create_resp.get("data", {})
	var match_id: String = match_data.get("matchId", "")
	var owner_id: String = match_data.get("ownerId", "")

	if match_id.is_empty() or owner_id.is_empty():
		bc.expect_true(false, "match_id or owner_id missing from create response")
		return

	var abandon_resp := await bc.bc_wrapper.async_match_service.abandon_match(owner_id, match_id)
	bc.expect_status_ok(abandon_resp)
