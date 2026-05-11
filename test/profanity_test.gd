# Copyright 2026 bitHeads, Inc. All Rights Reserved.
extends RefCounted

func run(bc: BCTest) -> void:
	await test_profanity_check(bc)
	await test_profanity_replace(bc)

func test_profanity_check(bc: BCTest) -> void:
	bc.begin_test("test_profanity_check")
	var response := await bc.bc_wrapper.profanity_service.profanity_check(
		"the quick brown fox", ["en"], false, false, false
	)
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")

func test_profanity_replace(bc: BCTest) -> void:
	bc.begin_test("test_profanity_replace")
	var response := await bc.bc_wrapper.profanity_service.profanity_replace_text(
		"hello world", "*", ["en"], false, false, false
	)
	bc.expect_status_ok(response)
	bc.expect_has_key(response, "data")
