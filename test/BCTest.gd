# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BCTest
extends Node

var bc_wrapper: BrainCloudWrapper = null
var ids: Dictionary = {}
var entity_type: String = "GDScriptUnitTests"

var user_a: TestUser = null
var user_b: TestUser = null
var user_c: TestUser = null

var _instance: BCTest = null
var _setup_done: bool = false

func _ready() -> void:
	bc_wrapper = BrainCloudWrapper.new()
	bc_wrapper.name = "BCWrapper"
	add_child(bc_wrapper)

	var rand_id := TestUser.generate_random_string(9)
	user_a = TestUser.new("UserA", rand_id)
	user_b = TestUser.new("UserB", rand_id)
	user_c = TestUser.new("UserC", rand_id)

# Fixed values the suites expect on the test app; appId/childAppId come from the plugin's config.
const TEST_VALUES := {
	"parentLevelName": "Master",
	"peerName": "peerapp",
	"stableEmail": "braincloudunittest@gmail.com",
	"leaderboardId": "testLeaderboard",
	"channelId": "valid",
	"customEntityType": "DartTestCustomEntity",
}

func setup_bc() -> bool:
	bc_wrapper.wrapper_name = "GDScriptTest"
	bc_wrapper.init()
	if not bc_wrapper.is_initialized():
		push_error("BCTest: no readable app config. Run `node bccm test braincloud-gdscript` to restore it from data/.")
		return false
	ids = TEST_VALUES.duplicate()
	ids["appId"] = bc_wrapper.get_app_id()
	var children := bc_wrapper.get_child_app_id_list()
	ids["childAppId"] = str(children[0]) if not children.is_empty() else ""
	bc_wrapper.braincloud_client.enable_logging(true)

	bc_wrapper.braincloud_client.authentication_service.clear_saved_profile_id()
	await _auth()
	return true

func _auth(user_id: String = "", password: String = "") -> void:
	var id := user_id if user_id.length() > 0 else user_a.name
	var token := password if password.length() > 0 else user_a.password

	# Ensure user_c ready
	if user_c.profile_id.length() == 0:
		var resp := await bc_wrapper.authenticate_email_password(user_c.email, user_c.password, true)
		user_c.profile_id = resp.get("data", {}).get("profileId", "")
		await bc_wrapper.logout(true)

	# Ensure user_b ready
	if user_b.profile_id.length() == 0:
		var resp := await bc_wrapper.authenticate_universal(user_b.name, user_b.password, true)
		user_b.profile_id = resp.get("data", {}).get("profileId", "")
		await bc_wrapper.logout(true)

	# Authenticate as requested user
	var response := await bc_wrapper.authenticate_universal(id, token, true)
	if id == user_a.name:
		user_a.profile_id = response.get("data", {}).get("profileId", "")

	print("BCTest: authenticated as %s / profileId=%s" % [id, user_a.profile_id])

func dispose() -> void:
	if bc_wrapper:
		bc_wrapper.queue_free()

# ── Assertion helpers ───────────────────────────────────────────────────────

var _pass_count: int = 0
var _fail_count: int = 0
var _current_suite: String = ""
var _current_test: String = ""
var _failed_tests: Array = []

func begin_suite(suite_name: String) -> void:
	_current_suite = suite_name

func begin_test(test_name: String) -> void:
	_current_test = test_name
	print("  [TEST] %s" % test_name)

func _fail_key() -> String:
	return "[%s] %s" % [_current_suite, _current_test]

func expect_eq(actual, expected, msg: String = "") -> void:
	if actual == expected:
		_pass_count += 1
	else:
		_fail_count += 1
		var key := _fail_key()
		if not _failed_tests.has(key):
			_failed_tests.append(key)
		push_error("  FAIL [%s]: expected %s == %s. %s" % [_current_test, str(actual), str(expected), msg])

func expect_status_ok(response: Dictionary) -> void:
	var status: int = response.get("status", -1)
	var detail := _response_detail(response, status)
	expect_true(
		status == StatusCodes.OK or status == StatusCodes.ACCEPTED,
		"Expected status 200 or 202, got %d%s" % [status, detail]
	)

func _response_detail(response: Dictionary, status: int) -> String:
	if status == StatusCodes.OK or status == StatusCodes.ACCEPTED:
		return ""
	var msg: String = response.get("status_message", "")
	var reason: int = response.get("reason_code", 0)
	if msg.is_empty():
		return ""
	var short_msg: String = msg.left(120).replace("\n", " ")
	return "\n    [reason_code=%d] %s" % [reason, short_msg]

func expect_status(response: Dictionary, expected_status: int) -> void:
	expect_eq(response.get("status", -1), expected_status, "Expected status %d" % expected_status)

func expect_has_key(response: Dictionary, key: String) -> void:
	if response.has(key):
		_pass_count += 1
	else:
		_fail_count += 1
		var fail_key := _fail_key()
		if not _failed_tests.has(fail_key):
			_failed_tests.append(fail_key)
		push_error("  FAIL [%s]: response missing key '%s'" % [_current_test, key])

func expect_true(condition: bool, msg: String = "") -> void:
	if condition:
		_pass_count += 1
	else:
		_fail_count += 1
		var key := _fail_key()
		if not _failed_tests.has(key):
			_failed_tests.append(key)
		push_error("  FAIL [%s]: expected true. %s" % [_current_test, msg])

func expect_false(condition: bool, msg: String = "") -> void:
	expect_true(not condition, msg)

func print_summary() -> void:
	print("\n=== Test Summary: %d passed, %d failed ===" % [_pass_count, _fail_count])
	if _failed_tests.size() > 0:
		print("\nFailed tests:")
		for t in _failed_tests:
			print("  - %s" % t)
