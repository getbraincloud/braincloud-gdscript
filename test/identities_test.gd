# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_get_identities(bc)
	await test_get_expired_identities(bc)
	await test_attach_detach_universal(bc)

func test_get_identities(bc: BCTest) -> void:
	bc.begin_test("test_get_identities")
	var response := await bc.bc_wrapper.identity_service.get_identities()
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_get_expired_identities(bc: BCTest) -> void:
	bc.begin_test("test_get_expired_identities")
	var response := await bc.bc_wrapper.identity_service.get_expired_identities()
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_attach_detach_universal(bc: BCTest) -> void:
	bc.begin_test("test_attach_detach_universal")
	var random_id := "gdtest_" + str(randi() % 999999)
	var random_pass := "pass_" + str(randi() % 999999)

	var attach_resp := await bc.bc_wrapper.identity_service.attach_universal_identity(random_id, random_pass)
	bc.expect_status_ok(attach_resp)

	var detach_resp := await bc.bc_wrapper.identity_service.detach_universal_identity(random_id, false)
	bc.expect_status_ok(detach_resp)
