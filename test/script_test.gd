# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_run_script(bc)
	await test_get_scheduled_cloud_scripts(bc)
	await test_get_running_or_queued_cloud_scripts(bc)

func test_run_script(bc: BCTest) -> void:
	bc.begin_test("test_run_script")
	var response := await bc.bc_wrapper.script_service.run_script("SendFinalEmail", {})
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)

func test_get_scheduled_cloud_scripts(bc: BCTest) -> void:
	bc.begin_test("test_get_scheduled_cloud_scripts")
	var start_time: int = Time.get_unix_time_from_system() * 1000
	var end_time: int = start_time + 3600000
	var response := await bc.bc_wrapper.script_service.get_scheduled_cloud_scripts(start_time)
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_get_running_or_queued_cloud_scripts(bc: BCTest) -> void:
	bc.begin_test("test_get_running_or_queued_cloud_scripts")
	var response := await bc.bc_wrapper.script_service.get_running_or_queued_cloud_scripts()
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")
