# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_start_and_cancel(bc)
	await test_start_and_complete(bc)

func test_start_and_cancel(bc: BCTest) -> void:
	bc.begin_test("test_start_and_cancel")
	var start_resp := await bc.bc_wrapper.one_way_match_service.start_match(bc.user_b.profile_id, 10)
	bc.expect_status_ok(start_resp)

	var playback_stream_id: String = start_resp.get("data", {}).get("playbackStreamId", "")
	if playback_stream_id.is_empty():
		bc.expect_true(false, "playbackStreamId missing from start_match response")
		return

	var cancel_resp := await bc.bc_wrapper.one_way_match_service.cancel_match(playback_stream_id)
	bc.expect_status_ok(cancel_resp)

func test_start_and_complete(bc: BCTest) -> void:
	bc.begin_test("test_start_match_for_complete")
	var start_resp := await bc.bc_wrapper.one_way_match_service.start_match(bc.user_b.profile_id, 1000)
	bc.expect_status_ok(start_resp)

	var playback_stream_id: String = start_resp.get("data", {}).get("playbackStreamId", "")
	if playback_stream_id.is_empty():
		bc.expect_true(false, "playbackStreamId missing from start_match response")
		return

	bc.begin_test("test_complete_match")
	var complete_resp := await bc.bc_wrapper.one_way_match_service.complete_match(playback_stream_id)
	bc.expect_status_ok(complete_resp)
