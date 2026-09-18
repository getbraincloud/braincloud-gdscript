# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

# Mirrors BrainCloudComms.packet_timeouts / _authentication_packet_timeout_secs defaults.
const _DEFAULT_PACKET_TIMEOUTS: Array[int] = [15, 20, 35, 50]

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
	# These values must be LONGER than the default, never shorter, and must be restored.
	# comms_test runs first and packet_timeouts is global to the client, so whatever this
	# leaves behind applies to every later test in the suite. The old [5, 10, 15] made a
	# request that was merely slow look timed out: the client resent the same packetId up
	# to four times and then failed the call with 900/90001 "Server unavailable", which
	# read like a brainCloud outage but was this test's leftover state. It only showed up
	# on the slowest agent (Linux), which is exactly how a too-tight timeout presents.
	var timeouts: Array[int] = [21, 31, 41]
	bc.bc_wrapper.braincloud_client.set_packet_timeouts(timeouts)
	var result: Array[int] = bc.bc_wrapper.braincloud_client.get_packet_timeouts()
	bc.expect_eq(result, timeouts, "packet timeouts should match what was set")

	# Restore, and assert the restore took — an unasserted restore is how this regressed.
	bc.bc_wrapper.braincloud_client.set_packet_timeouts_to_default()
	var restored: Array[int] = bc.bc_wrapper.braincloud_client.get_packet_timeouts()
	bc.expect_eq(restored, _DEFAULT_PACKET_TIMEOUTS, "packet timeouts should be back to default")

func test_authentication_timeout(bc: BCTest) -> void:
	bc.begin_test("test_authentication_timeout")
	# Same leak risk as test_packet_timeouts — capture and put it back afterwards.
	var original: int = bc.bc_wrapper.braincloud_client.get_authentication_packet_timeout()
	bc.bc_wrapper.braincloud_client.set_authentication_packet_timeout(20)
	var result: int = bc.bc_wrapper.braincloud_client.get_authentication_packet_timeout()
	bc.expect_eq(result, 20, "authentication timeout should be 20")

	bc.bc_wrapper.braincloud_client.set_authentication_packet_timeout(original)
	var restored: int = bc.bc_wrapper.braincloud_client.get_authentication_packet_timeout()
	bc.expect_eq(restored, original, "authentication timeout should be back to its original value")

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
