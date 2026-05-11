# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_get_recent_for_initiating(bc)

func test_get_recent_for_initiating(bc: BCTest) -> void:
	bc.begin_test("test_get_recent_for_initiating")
	var response := await bc.bc_wrapper.playback_stream_service.get_recent_streams_for_initiating_player(
		bc.user_a.profile_id, 10
	)
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")
