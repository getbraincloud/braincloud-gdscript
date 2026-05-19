# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_custom_page_event(bc)
	await test_custom_screen_event(bc)
	await test_custom_track_event(bc)

func test_custom_page_event(bc: BCTest) -> void:
	bc.begin_test("test_custom_page_event")
	var response := await bc.bc_wrapper.data_stream_service.custom_page_event("testEvent", {"prop": "val"})
	bc.expect_status_ok(response)

func test_custom_screen_event(bc: BCTest) -> void:
	bc.begin_test("test_custom_screen_event")
	var response := await bc.bc_wrapper.data_stream_service.custom_screen_event("screen", {"prop": "val"})
	bc.expect_status_ok(response)

func test_custom_track_event(bc: BCTest) -> void:
	bc.begin_test("test_custom_track_event")
	var response := await bc.bc_wrapper.data_stream_service.custom_track_event("track", {"prop": "val"})
	bc.expect_status_ok(response)
