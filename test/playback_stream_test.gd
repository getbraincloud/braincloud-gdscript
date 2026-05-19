# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

var _stream_id: String = ""

func run(bc: BCTest) -> void:
	await test_start_stream(bc)
	await test_read_stream(bc)
	await test_add_event(bc)
	await test_get_recent_for_initiating(bc)
	await test_get_recent_for_target(bc)
	await test_end_stream(bc)
	await test_delete_stream(bc)

func test_start_stream(bc: BCTest) -> void:
	bc.begin_test("test_start_stream")
	var response := await bc.bc_wrapper.playback_stream_service.start_stream(bc.user_b.profile_id, true)
	bc.expect_status_ok(response)
	_stream_id = response.get("data", {}).get("playbackStreamId", "")
	bc.expect_true(_stream_id.length() > 0, "playbackStreamId should not be empty")

func test_read_stream(bc: BCTest) -> void:
	bc.begin_test("test_read_stream")
	if _stream_id.is_empty():
		bc.expect_true(true, "skipping — no stream_id")
		return
	var response := await bc.bc_wrapper.playback_stream_service.read_stream(_stream_id)
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_add_event(bc: BCTest) -> void:
	bc.begin_test("test_add_event")
	if _stream_id.is_empty():
		bc.expect_true(true, "skipping — no stream_id")
		return
	var response := await bc.bc_wrapper.playback_stream_service.add_event(
		_stream_id, {"move": "jump"}, {"score": 100}
	)
	bc.expect_status_ok(response)

func test_get_recent_for_initiating(bc: BCTest) -> void:
	bc.begin_test("test_get_recent_for_initiating")
	var response := await bc.bc_wrapper.playback_stream_service.get_recent_streams_for_initiating_player(
		bc.user_a.profile_id, 10
	)
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_get_recent_for_target(bc: BCTest) -> void:
	bc.begin_test("test_get_recent_for_target")
	var response := await bc.bc_wrapper.playback_stream_service.get_recent_streams_for_target_player(
		bc.user_b.profile_id, 10
	)
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_end_stream(bc: BCTest) -> void:
	bc.begin_test("test_end_stream")
	if _stream_id.is_empty():
		bc.expect_true(true, "skipping — no stream_id")
		return
	var response := await bc.bc_wrapper.playback_stream_service.end_stream(_stream_id)
	bc.expect_status_ok(response)

func test_delete_stream(bc: BCTest) -> void:
	bc.begin_test("test_delete_stream")
	if _stream_id.is_empty():
		bc.expect_true(true, "skipping — no stream_id")
		return
	var response := await bc.bc_wrapper.playback_stream_service.delete_stream(_stream_id)
	bc.expect_status_ok(response)
	_stream_id = ""
