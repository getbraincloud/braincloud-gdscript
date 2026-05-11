# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_rtt_placeholder(bc)

func test_rtt_placeholder(bc: BCTest) -> void:
	bc.begin_test("rtt_placeholder")
	bc.expect_true(bc.bc_wrapper.rtt_service != null, "rtt_service should be accessible")
