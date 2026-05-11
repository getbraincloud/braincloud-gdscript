# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_placeholder(bc)

func test_placeholder(bc: BCTest) -> void:
	bc.begin_test("lobby_placeholder")
	bc.expect_true(bc.bc_wrapper.lobby_service != null, "lobby_service should be accessible")
