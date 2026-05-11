# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_relay_placeholder(bc)

func test_relay_placeholder(bc: BCTest) -> void:
	bc.begin_test("relay_placeholder")
	bc.expect_true(bc.bc_wrapper.relay_service != null, "relay_service should be accessible")
