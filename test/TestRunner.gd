# Copyright 2026 bitHeads, Inc. All Rights Reserved.
# Run with: godot --headless --script test/TestRunner.gd
extends SceneTree

const TEST_FILES := [
	"res://test/authentication_test.gd",
	"res://test/wrapper_test.gd",
	"res://test/client_test.gd",
	"res://test/comms_test.gd",
	"res://test/entities_test.gd",
	"res://test/global_entity_test.gd",
	"res://test/global_app_test.gd",
	"res://test/global_statistics_test.gd",
	"res://test/player_state_test.gd",
	"res://test/player_statistics_test.gd",
	"res://test/player_statistics_event_test.gd",
	"res://test/time_test.gd",
	"res://test/script_test.gd",
	"res://test/identities_test.gd",
	"res://test/event_test.gd",
	"res://test/friend_test.gd",
	"res://test/gamification_test.gd",
	"res://test/virtual_currency_test.gd",
	"res://test/files_test.gd",
	"res://test/global_file_test.gd",
	"res://test/group_test.gd",
	"res://test/group_file_test.gd",
	"res://test/chat_test.gd",
	"res://test/messaging_test.gd",
	"res://test/lobby_test.gd",
	"res://test/rtt_test.gd",
	"res://test/relay_test.gd",
	"res://test/presence_test.gd",
	"res://test/push_notification_test.gd",
	"res://test/match_making_test.gd",
	"res://test/async_match_test.gd",
	"res://test/one_way_match_test.gd",
	"res://test/playback_stream_test.gd",
	"res://test/profanity_test.gd",
	"res://test/redemption_code_test.gd",
	"res://test/appstore_test.gd",
	"res://test/blockchain_test.gd",
	"res://test/user_items_test.gd",
	"res://test/item_catalog_test.gd",
	"res://test/data_stream_test.gd",
	"res://test/mail_test.gd",
	"res://test/tournament_test.gd",
	"res://test/custom_entity_test.gd",
	"res://test/social_leaderboard_test.gd",
]

var _bc_test: BCTest = null
var _total_pass: int = 0
var _total_fail: int = 0

func _init() -> void:
	print("=== BrainCloud GDScript SDK Tests ===\n")
	_bc_test = BCTest.new()
	root.add_child(_bc_test)
	_run_tests.call_deferred()

func _run_tests() -> void:
	var ok := await _bc_test.setup_bc()
	if not ok:
		push_error("BCTest setup failed — check test/ids.cfg")
		quit(1)
		return

	# Optional: --suite rtt_test  (comma-separated, no .gd extension needed)
	var filter := ""
	var args := OS.get_cmdline_user_args()
	var suite_idx := args.find("--suite")
	if suite_idx >= 0 and suite_idx + 1 < args.size():
		filter = args[suite_idx + 1]

	for test_path in TEST_FILES:
		var matches := filter.is_empty()
		if not matches:
			for f in filter.split(","):
				if test_path.contains(f.strip_edges()):
					matches = true
					break
		if matches:
			await _run_file(test_path)

	_bc_test.print_summary()
	_total_pass = _bc_test._pass_count
	_total_fail = _bc_test._fail_count

	print("\n=== TOTAL: %d passed, %d failed ===" % [_total_pass, _total_fail])
	quit(1 if _total_fail > 0 else 0)

func _run_file(path: String) -> void:
	var script: GDScript = load(path)
	if script == null:
		push_error("Could not load test script: %s" % path)
		return

	var test_instance = script.new()
	if not test_instance:
		return

	var suite_name := path.get_file().get_basename()
	print("\n[SUITE] %s" % suite_name)
	_bc_test.begin_suite(suite_name)
	if test_instance.has_method("run"):
		await test_instance.run(_bc_test)
