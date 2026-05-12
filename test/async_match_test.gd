# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

var _match_id: String = ""
var _owner_id: String = ""

func run(bc: BCTest) -> void:
	await test_find_matches(bc)
	await test_find_complete_matches(bc)
	await test_create_and_complete_flow(bc)
	await test_create_match_with_initial_turn(bc)
	await test_complete_match_with_summary_data(bc)
	await test_abandon_match_with_summary_data(bc)

func test_find_matches(bc: BCTest) -> void:
	bc.begin_test("test_find_matches")
	var response := await bc.bc_wrapper.async_match_service.find_matches()
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_find_complete_matches(bc: BCTest) -> void:
	bc.begin_test("test_find_complete_matches")
	var response := await bc.bc_wrapper.async_match_service.find_complete_matches()
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_create_and_complete_flow(bc: BCTest) -> void:
	# createMatch
	bc.begin_test("test_create_match")
	var opponents := [{"platform": "BC", "id": bc.user_b.profile_id}]
	var create_resp := await bc.bc_wrapper.async_match_service.create_match(opponents, {})
	bc.expect_status_ok(create_resp)
	var match_data: Dictionary = create_resp.get("data", {})
	_match_id = match_data.get("matchId", "")
	_owner_id = match_data.get("ownerId", "")
	if _match_id.is_empty() or _owner_id.is_empty():
		bc.expect_true(false, "match_id or owner_id missing from create response")
		return

	# updateMatchSummary (version 0 → 1)
	bc.begin_test("test_update_match_summary")
	var summary_resp := await bc.bc_wrapper.async_match_service.update_match_summary(
		_owner_id, _match_id, 0, {"summary": "test_sum"}
	)
	bc.expect_status_ok(summary_resp)
	var version: int = summary_resp.get("data", {}).get("version", 1)

	# submitTurn (use version returned by updateMatchSummary)
	bc.begin_test("test_submit_turn")
	var turn_resp := await bc.bc_wrapper.async_match_service.submit_turn(
		_owner_id, _match_id, version, {"map": "level1"}, {},
		bc.user_b.profile_id, {"summary": "test_sum"}, {"summary": "test_sum"}
	)
	bc.expect_status_ok(turn_resp)

	# abandonMatch
	bc.begin_test("test_abandon_match")
	var abandon_resp := await bc.bc_wrapper.async_match_service.abandon_match(_owner_id, _match_id)
	bc.expect_status_ok(abandon_resp)

	# deleteMatch
	bc.begin_test("test_delete_match")
	var delete_resp := await bc.bc_wrapper.async_match_service.delete_match(_owner_id, _match_id)
	bc.expect_status_ok(delete_resp)
	_match_id = ""
	_owner_id = ""

func test_create_match_with_initial_turn(bc: BCTest) -> void:
	bc.begin_test("test_create_match_with_initial_turn")
	var opponents := [{"platform": "BC", "id": bc.user_b.profile_id}]
	var create_resp := await bc.bc_wrapper.async_match_service.create_match_with_initial_turn(
		opponents, {"matchStateData": "test"}, {}, bc.user_b.profile_id, {"summary": "sum"}
	)
	bc.expect_status_ok(create_resp)
	var match_data: Dictionary = create_resp.get("data", {})
	_match_id = match_data.get("matchId", "")
	_owner_id = match_data.get("ownerId", "")
	if _match_id.is_empty() or _owner_id.is_empty():
		bc.expect_true(false, "match_id or owner_id missing")
		return

	# readMatch
	bc.begin_test("test_read_match")
	var read_resp := await bc.bc_wrapper.async_match_service.read_match(_owner_id, _match_id)
	bc.expect_status_ok(read_resp)

	# readMatchHistory
	bc.begin_test("test_read_match_history")
	var hist_resp := await bc.bc_wrapper.async_match_service.read_match_history(_owner_id, _match_id)
	bc.expect_status_ok(hist_resp)

	# completeMatch
	bc.begin_test("test_complete_match")
	var complete_resp := await bc.bc_wrapper.async_match_service.complete_match(_owner_id, _match_id)
	bc.expect_status_ok(complete_resp)
	_match_id = ""
	_owner_id = ""

func test_complete_match_with_summary_data(bc: BCTest) -> void:
	bc.begin_test("test_complete_match_with_summary_data")
	var opponents := [
		{"platform": "BC", "id": bc.user_a.profile_id},
		{"platform": "BC", "id": bc.user_b.profile_id}
	]
	var create_resp := await bc.bc_wrapper.async_match_service.create_match(opponents, {})
	bc.expect_status_ok(create_resp)
	var match_data: Dictionary = create_resp.get("data", {})
	var match_id: String = match_data.get("matchId", "")
	var owner_id: String = match_data.get("ownerId", "")
	if match_id.is_empty() or owner_id.is_empty():
		bc.expect_true(false, "match_id or owner_id missing")
		return

	var turn_resp := await bc.bc_wrapper.async_match_service.submit_turn(
		owner_id, match_id, 0, {"summary": "sum"}, {},
		bc.user_b.profile_id, {"summary": "sum"}, {"summary": "sum"}
	)
	bc.expect_status_ok(turn_resp)

	var complete_resp := await bc.bc_wrapper.async_match_service.complete_match_with_summary_data(
		owner_id, match_id, {"msg": "done"}, {"summary": "sum"}
	)
	bc.expect_status_ok(complete_resp)

func test_abandon_match_with_summary_data(bc: BCTest) -> void:
	bc.begin_test("test_abandon_match_with_summary_data")
	var opponents := [
		{"platform": "BC", "id": bc.user_a.profile_id},
		{"platform": "BC", "id": bc.user_b.profile_id}
	]
	var create_resp := await bc.bc_wrapper.async_match_service.create_match(opponents, {})
	bc.expect_status_ok(create_resp)
	var match_data: Dictionary = create_resp.get("data", {})
	var match_id: String = match_data.get("matchId", "")
	var owner_id: String = match_data.get("ownerId", "")
	if match_id.is_empty() or owner_id.is_empty():
		bc.expect_true(false, "match_id or owner_id missing")
		return

	var turn_resp := await bc.bc_wrapper.async_match_service.submit_turn(
		owner_id, match_id, 0, {"summary": "sum"}, {},
		bc.user_b.profile_id, {"summary": "sum"}, {"summary": "sum"}
	)
	bc.expect_status_ok(turn_resp)

	var abandon_resp := await bc.bc_wrapper.async_match_service.abandon_match_with_summary_data(
		owner_id, match_id, {"msg": "done"}, {"summary": "sum"}
	)
	bc.expect_status_ok(abandon_resp)
