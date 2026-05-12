# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_run_script(bc)
	await test_schedule_run_script_utc(bc)
	await test_schedule_run_script_minutes_and_cancel(bc)
	await test_run_peer_script(bc)
	await test_run_peer_script_async(bc)
	await test_get_scheduled_cloud_scripts(bc)
	await test_get_running_or_queued_cloud_scripts(bc)
	await test_run_parent_script(bc)

func test_run_script(bc: BCTest) -> void:
	bc.begin_test("test_run_script")
	var response := await bc.bc_wrapper.script_service.run_script("emptyScript", {"testParam1": 1})
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)

func test_schedule_run_script_utc(bc: BCTest) -> void:
	bc.begin_test("test_schedule_run_script_utc")
	var tomorrow_ms: int = (Time.get_unix_time_from_system() + 86400) * 1000
	var response := await bc.bc_wrapper.script_service.schedule_run_script_utc(
		"emptyScript", {"testParam1": 1}, tomorrow_ms
	)
	bc.expect_status_ok(response)
	# Clean up the scheduled job
	var job_id: String = response.get("data", {}).get("jobId", "")
	if not job_id.is_empty():
		await bc.bc_wrapper.script_service.cancel_scheduled_script(job_id)

func test_schedule_run_script_minutes_and_cancel(bc: BCTest) -> void:
	bc.begin_test("test_schedule_run_script_minutes")
	var response := await bc.bc_wrapper.script_service.schedule_run_script_minutes(
		"emptyScript", {"testParam1": 1}, 60
	)
	bc.expect_status_ok(response)
	var job_id: String = response.get("data", {}).get("jobId", "")

	bc.begin_test("test_cancel_scheduled_script")
	if job_id.is_empty():
		bc.expect_true(false, "jobId missing from scheduleRunScriptMinutes response")
		return
	var cancel_resp := await bc.bc_wrapper.script_service.cancel_scheduled_script(job_id)
	bc.expect_status_ok(cancel_resp)

func test_run_peer_script(bc: BCTest) -> void:
	bc.begin_test("test_run_peer_script")
	var peer_name: String = bc.ids.get("peerName", "peerapp")
	var response := await bc.bc_wrapper.script_service.run_peer_script(
		"TestPeerScriptPublic", {"testParam1": 1}, peer_name
	)
	bc.expect_status_ok(response)

func test_run_peer_script_async(bc: BCTest) -> void:
	bc.begin_test("test_run_peer_script_async")
	var peer_name: String = bc.ids.get("peerName", "peerapp")
	var response := await bc.bc_wrapper.script_service.run_peer_script_async(
		"TestPeerScriptPublic", {"testParam1": 1}, peer_name
	)
	bc.expect_status_ok(response)

func test_get_scheduled_cloud_scripts(bc: BCTest) -> void:
	bc.begin_test("test_get_scheduled_cloud_scripts")
	var start_time: int = Time.get_unix_time_from_system() * 1000
	var response := await bc.bc_wrapper.script_service.get_scheduled_cloud_scripts(start_time)
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_get_running_or_queued_cloud_scripts(bc: BCTest) -> void:
	bc.begin_test("test_get_running_or_queued_cloud_scripts")
	var response := await bc.bc_wrapper.script_service.get_running_or_queued_cloud_scripts()
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_run_parent_script(bc: BCTest) -> void:
	bc.begin_test("test_run_parent_script")
	var response := await bc.bc_wrapper.script_service.run_parent_script("None", {}, "Invalid")
	bc.expect_status(response, StatusCodes.BAD_REQUEST)
