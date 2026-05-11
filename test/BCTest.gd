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

func load_ids(path: String = "res://test/ids.cfg") -> bool:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("BCTest: Cannot open ids file: %s" % path)
		return false
	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if line.is_empty() or line.begins_with("#"):
			continue
		var kv := line.split("=", true, 1)
		if kv.size() == 2:
			ids[kv[0].strip_edges()] = kv[1].strip_edges()
	file.close()
	return true

func setup_bc(server_url: String = "") -> bool:
	if not load_ids():
		return false

	var url: String = server_url if server_url.length() > 0 else ids.get("serverUrl", BrainCloudClient.DEFAULT_SERVER_URL)
	bc_wrapper.wrapper_name = "GDScriptTest"
	bc_wrapper.init(
		ids.get("secret", ""),
		ids.get("appId", ""),
		ids.get("version", "1.0.0"),
		url
	)
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
var _current_test: String = ""

func begin_test(test_name: String) -> void:
	_current_test = test_name
	print("  [TEST] %s" % test_name)

func expect_eq(actual, expected, msg: String = "") -> void:
	if actual == expected:
		_pass_count += 1
	else:
		_fail_count += 1
		push_error("  FAIL [%s]: expected %s == %s. %s" % [_current_test, str(actual), str(expected), msg])

func expect_status_ok(response: Dictionary) -> void:
	expect_eq(response.get("status", -1), StatusCodes.OK, "Expected status 200")

func expect_status(response: Dictionary, expected_status: int) -> void:
	expect_eq(response.get("status", -1), expected_status, "Expected status %d" % expected_status)

func expect_has_key(response: Dictionary, key: String) -> void:
	if response.has(key):
		_pass_count += 1
	else:
		_fail_count += 1
		push_error("  FAIL [%s]: response missing key '%s'" % [_current_test, key])

func expect_true(condition: bool, msg: String = "") -> void:
	if condition:
		_pass_count += 1
	else:
		_fail_count += 1
		push_error("  FAIL [%s]: expected true. %s" % [_current_test, msg])

func expect_false(condition: bool, msg: String = "") -> void:
	expect_true(not condition, msg)

func print_summary() -> void:
	print("\n=== Test Summary: %d passed, %d failed ===" % [_pass_count, _fail_count])
