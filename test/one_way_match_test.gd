# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_start_and_cancel(bc)

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
