# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_get_channel_id(bc)
	await test_get_subscribed_channels(bc)

func test_get_channel_id(bc: BCTest) -> void:
	bc.begin_test("test_get_channel_id")
	var channel_id: String = bc.ids.get("channelId", "valid-channel-id")
	var response := await bc.bc_wrapper.chat_service.get_channel_id("gl", channel_id)
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)

func test_get_subscribed_channels(bc: BCTest) -> void:
	bc.begin_test("test_get_subscribed_channels")
	var response := await bc.bc_wrapper.chat_service.get_subscribed_channels("gl")
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)
