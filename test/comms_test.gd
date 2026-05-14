# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_authenticated(bc)
	await test_packet_timeouts(bc)
	await test_authentication_timeout(bc)
	await test_insert_end_of_message_bundle_marker(bc)
	await test_enable_disable_communications(bc)

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

func test_insert_end_of_message_bundle_marker(bc: BCTest) -> void:
	bc.begin_test("test_insert_end_of_message_bundle_marker")
	bc.bc_wrapper.braincloud_client.insert_end_of_message_bundle_marker()
	var r1 := await bc.bc_wrapper.player_statistics_service.read_all_user_stats()
	bc.expect_status_ok(r1)
	bc.bc_wrapper.braincloud_client.insert_end_of_message_bundle_marker()
	var r2 := await bc.bc_wrapper.player_statistics_service.read_all_user_stats()
	bc.expect_status_ok(r2)

func test_enable_disable_communications(bc: BCTest) -> void:
	bc.begin_test("test_enable_disable_communications")
	bc.expect_true(bc.bc_wrapper.braincloud_client.is_authenticated(), "Should be authenticated before test")
	bc.bc_wrapper.braincloud_client.enable_communications(false)
	bc.bc_wrapper.braincloud_client.enable_communications(true)
	var response := await bc.bc_wrapper.global_app_service.read_properties()
	bc.expect_status_ok(response)
