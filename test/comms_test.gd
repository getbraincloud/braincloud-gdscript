# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_authenticated(bc)
	await test_packet_timeouts(bc)
	await test_authentication_timeout(bc)

func test_authenticated(bc: BCTest) -> void:
	bc.begin_test("test_authenticated")
	bc.expect_true(bc.bc_wrapper.braincloud_client.is_authenticated(), "client should be authenticated")

func test_packet_timeouts(bc: BCTest) -> void:
	bc.begin_test("test_packet_timeouts")
	var timeouts: Array[int] = [5, 10, 15]
	bc.bc_wrapper.braincloud_client.set_packet_timeouts(timeouts)
	var result: Array[int] = bc.bc_wrapper.braincloud_client.get_packet_timeouts()
	bc.expect_eq(result, timeouts, "packet timeouts should match what was set")

func test_authentication_timeout(bc: BCTest) -> void:
	bc.begin_test("test_authentication_timeout")
	bc.bc_wrapper.braincloud_client.set_authentication_packet_timeout(20)
	var result: int = bc.bc_wrapper.braincloud_client.get_authentication_packet_timeout()
	bc.expect_eq(result, 20, "authentication timeout should be 20")
