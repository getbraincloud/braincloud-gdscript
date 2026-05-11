# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_read_player_state(bc)
	await test_update_name(bc)
	await test_update_summary(bc)
	await test_update_contact_email(bc)
	await test_update_picture_url(bc)
	await test_attributes(bc)

func test_read_player_state(bc: BCTest) -> void:
	bc.begin_test("test_read_player_state")
	var response := await bc.bc_wrapper.player_state_service.read_player_state()
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_update_name(bc: BCTest) -> void:
	bc.begin_test("test_update_name")
	var new_name := "GDTest" + str(randi() % 10000)
	var response := await bc.bc_wrapper.player_state_service.update_name(new_name)
	bc.expect_status_ok(response)

func test_update_summary(bc: BCTest) -> void:
	bc.begin_test("test_update_summary")
	var summary := {"level": 5, "score": 1000}
	var response := await bc.bc_wrapper.player_state_service.update_summary(summary)
	bc.expect_status_ok(response)

func test_update_contact_email(bc: BCTest) -> void:
	bc.begin_test("test_update_contact_email")
	var response := await bc.bc_wrapper.player_state_service.update_contact_email("test@example.com")
	var status: int = response.get("status", -1)
	bc.expect_true(
		status == StatusCodes.OK or status == StatusCodes.BAD_REQUEST,
		"Expected 200 or 400, got %d" % status
	)

func test_update_picture_url(bc: BCTest) -> void:
	bc.begin_test("test_update_picture_url")
	var response := await bc.bc_wrapper.player_state_service.update_picture_url("https://example.com/test_picture.png")
	bc.expect_status_ok(response)

func test_attributes(bc: BCTest) -> void:
	bc.begin_test("test_attributes")
	var attrs := {"testAttr": "attrValue", "numAttr": "42"}
	var update_resp := await bc.bc_wrapper.player_state_service.update_attributes(attrs, false)
	bc.expect_status_ok(update_resp)

	var remove_resp := await bc.bc_wrapper.player_state_service.remove_attributes(["testAttr", "numAttr"])
	bc.expect_status_ok(remove_resp)
