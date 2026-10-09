# Copyright 2026 bitHeads, Inc. All Rights Reserved.
@tool
extends EditorPlugin

const _AUTOLOAD_NAME := "brainCloud"
const _WRAPPER_PATH  := "res://addons/braincloud/BrainCloudWrapper.gd"
const _MENU_ITEM     := "brainCloud"

# Credentials are stored here — add this path to .gitignore
const _CREDS_PATH    := "res://addons/braincloud/braincloud.cfg"

# ── Brand colours ──────────────────────────────────────────────────────────────
const _BC_BLUE       := Color("#29a8e0")
const _BC_DARK       := Color("#0f1923")
const _BC_PANEL      := Color("#141e2b")
const _BC_WARN_DARK  := Color("#FF9B3D")  # orange — dark themes
const _BC_WARN_LIGHT := Color("#FF832B")  # orange — light themes

const _LOGO_PATH       := "res://addons/braincloud/braincloud_logo.png"        # white text — dark themes
const _LOGO_PATH_LIGHT := "res://addons/braincloud/braincloud_logo_light.png"  # dark text — light themes

# Most projects should just point at prod — this is what the "Use Default
# brainCloud Server" checkbox forces the Server URL field to.
const _DEFAULT_SERVER_URL := "https://api.braincloudservers.com/dispatcherv2"

# Only non-sensitive settings live in project.godot
const _SETTINGS := [
	{"name": "braincloud/config/server_url",         "type": TYPE_STRING, "default": _DEFAULT_SERVER_URL},
	{"name": "braincloud/config/app_version",        "type": TYPE_STRING, "default": "1.0.0"},
	{"name": "braincloud/config/enable_compression", "type": TYPE_BOOL,   "default": true},
	{"name": "braincloud/debug/enable_logging",      "type": TYPE_BOOL,   "default": false},
]

const _LINKS := [
	{"label": "Portal",         "url": "https://portalx.braincloudservers.com/"},
	{"label": "Learn",          "url": "https://docs.braincloudservers.com/learn/introduction/"},
	{"label": "API Reference",  "url": "https://docs.braincloudservers.com/api/introduction"},
	{"label": "Knowledge Base", "url": "https://help.getbraincloud.com/en/"},
	{"label": "Code Examples",  "url": "https://apps.braincloudservers.com/code_examples/index.html"},
	{"label": "GDScript SDK",   "url": "https://github.com/getbraincloud/braincloud-gdscript"},
]

# Full server-validated OS/auth platform enum (IClientOsPlatformManager on the
# server — an unrecognized value here is silently dropped, not rejected, by
# app creation), used for the "Create New App" checkboxes. Windows/Mac/Linux
# default on, matching braincloud-unity-plugin's defaults.
const _CREATE_APP_PLATFORMS := [
	{"id": "WINDOWS",      "label": "Windows",         "default": true },
	{"id": "MAC",          "label": "Mac",             "default": true },
	{"id": "LINUX",        "label": "Linux",           "default": true },
	{"id": "WEB",          "label": "Web",             "default": false},
	{"id": "IOS",          "label": "iOS",             "default": false},
	{"id": "ANG",          "label": "Android",         "default": false},
	{"id": "AMAZON",       "label": "Amazon",          "default": false},
	{"id": "APPLE_TV_OS",  "label": "Apple tvOS",      "default": false},
	{"id": "VISION_OS",    "label": "Apple visionOS",  "default": false},
	{"id": "WATCH_OS",     "label": "Apple watchOS",   "default": false},
	{"id": "BB",           "label": "BlackBerry",      "default": false},
	{"id": "FB",           "label": "Facebook",        "default": false},
	{"id": "NINTENDO",     "label": "Nintendo",        "default": false},
	{"id": "OCULUS",       "label": "Oculus",          "default": false},
	{"id": "PS3",          "label": "PlayStation 3",   "default": false},
	{"id": "PS4",          "label": "PlayStation 4",   "default": false},
	{"id": "PS_VITA",      "label": "PlayStation Vita","default": false},
	{"id": "ROKU",         "label": "Roku",            "default": false},
	{"id": "STEAM",        "label": "Steam",           "default": false},
	{"id": "TIZEN",        "label": "Tizen",           "default": false},
	{"id": "WII",          "label": "Wii",             "default": false},
	{"id": "WINP",         "label": "Windows Phone",   "default": false},
	{"id": "XBOX_ONE",     "label": "Xbox One",        "default": false},
	{"id": "XBOX_360",     "label": "Xbox 360",        "default": false},
	{"id": "UNKNOWN",      "label": "Unknown",         "default": false},
]

var _export_plugin: EditorExportPlugin = null
var _panel_control: Control = null

# Nodes that need to swap when the editor theme changes
var _logo_png:   TextureRect = null  # swaps between dark-bg and light-bg variant
var _warn_label: Label       = null  # brand orange — cannot inherit from theme
var _stale_secret_label: Label = null  # brand orange — shown when app_id is set but the saved secret can't be read

# brainCloud account (OAuth + Builder API) login/team/app flow
var _login_flow: BrainCloudLoginFlow = null
var _account_container: Control = null
var _cred_fields: Dictionary = {}
var _logout_btn: Button = null   # lives below App Credentials, hidden until logged in
var _log_check: CheckBox = null
var _status_label: Label = null
var _show_create_app: bool = false
var _new_app_name: String = ""
var _new_app_name_edit: LineEdit = null
var _new_app_platform_state: Dictionary = {}
var _create_with_template: bool = false
var _selected_template_id: String = ""
var _creds_fields_box: Control = null
var _creds_header: Button = null
var _app_name_row: Control = null   # read-only App Name — shown once an app is synced or cached
var _app_name_edit: LineEdit = null
var _app_name_hint: Label = null
var _user_triggered_login: bool = false  # gates showing error_message until the user clicks Log in/Change App

# Child apps of the configured app (saved in braincloud.cfg next to it)
const _CHILD_PLACEHOLDER := "-- Select child app --"
const _CHILD_MANUAL      := "Other (enter manually)"
# Editor-only project metadata (never exported): {parent_app_id: [child_app_id, ...]}
const _CHILD_META_SECTION := "braincloud"
const _CHILD_META_KEY     := "child_apps"
var _children_box: VBoxContainer = null
var _child_list_box: VBoxContainer = null  # read-only child list under App Credentials
var _child_rows: Array = []        # [{id, manual, draft_id, draft_value}]; id = saved child app id or ""
var _child_rows_for: String = ""   # app id the rows belong to
var _child_error: String = ""

func _enter_tree() -> void:
	# Keeps the desktop-only native library out of Web exports - see the plugin's docs.
	_export_plugin = BrainCloudExportPlugin.new()
	add_export_plugin(_export_plugin)
	_register_project_settings()
	if not ProjectSettings.has_setting("autoload/" + _AUTOLOAD_NAME):
		add_autoload_singleton(_AUTOLOAD_NAME, _WRAPPER_PATH)
	ProjectSettings.save()
	_panel_control = _build_panel()
	_panel_control.name = "brainCloud"
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_UL, _panel_control)
	add_tool_menu_item(_MENU_ITEM, _focus_panel)
	get_editor_interface().get_editor_settings().settings_changed.connect(_update_panel_theme)

	_login_flow = BrainCloudLoginFlow.new()
	_login_flow.configure(_panel_control)
	_login_flow.state_changed.connect(_refresh_account_section)
	_login_flow.app_selected.connect(_on_app_selected)
	_refresh_account_section()
	if _login_flow.is_logged_in() and _login_flow.teams.is_empty():
		_login_flow.refresh_teams()


func _exit_tree() -> void:
	if _export_plugin != null:
		remove_export_plugin(_export_plugin)
		_export_plugin = null
	var es := get_editor_interface().get_editor_settings()
	if es.settings_changed.is_connected(_update_panel_theme):
		es.settings_changed.disconnect(_update_panel_theme)
	remove_tool_menu_item(_MENU_ITEM)
	if ProjectSettings.has_setting("autoload/" + _AUTOLOAD_NAME):
		remove_autoload_singleton(_AUTOLOAD_NAME)
	if is_instance_valid(_panel_control):
		remove_control_from_docks(_panel_control)
		_panel_control.queue_free()
	_panel_control = null

	if _login_flow != null:
		_login_flow.cancel_login()
		_login_flow = null


func _process(_delta: float) -> void:
	if _login_flow != null:
		_login_flow.poll()


func _focus_panel() -> void:
	if not is_instance_valid(_panel_control):
		return
	var tabs := _panel_control.get_parent()
	if tabs is TabContainer:
		tabs.current_tab = _panel_control.get_index()
	elif is_instance_valid(tabs):
		tabs.show()


# ── Project Settings ───────────────────────────────────────────────────────────

func _register_project_settings() -> void:
	for entry in _SETTINGS:
		if not ProjectSettings.has_setting(entry["name"]):
			ProjectSettings.set_setting(entry["name"], entry["default"])
		ProjectSettings.set_initial_value(entry["name"], entry["default"])
		ProjectSettings.add_property_info({"name": entry["name"], "type": entry["type"]})


# ── Live theme update ──────────────────────────────────────────────────────────
# Only brand-specific overrides are applied here. All other colours are left to
# Godot's theme system so they adapt automatically to any editor theme.

func _update_panel_theme() -> void:
	if not is_instance_valid(_panel_control):
		return
	# settings_changed fires before the new values are committed — wait one frame
	await get_tree().process_frame
	if not is_instance_valid(_panel_control):
		return

	var es           := get_editor_interface().get_editor_settings()
	var _preset      := str(es.get_setting("interface/theme/preset"))
	var _preset_low  := _preset.to_lower()
	var _bg          := get_editor_interface().get_editor_theme().get_color("base_color", "Editor")
	# Preset name is authoritative for built-in themes with "light"/"dark"/"black" in the name.
	# All other presets (Default, Godot 2, Gray, custom) fall back to the compiled bg color.
	var _is_light: bool
	if "light" in _preset_low:
		_is_light = true
	elif "dark" in _preset_low or "black" in _preset_low:
		_is_light = false
	else:
		_is_light = _bg.r > 0.24 and _bg.g > 0.24 and _bg.b > 0.24
	print("[brainCloud] preset=%-22s  compiled_bg=%s  r=%.2f g=%.2f b=%.2f  is_light=%s" % [
		_preset, _bg.to_html(false),
		_bg.r, _bg.g, _bg.b,
		_is_light
	])

	# Swap logo between the dark-bg and light-bg variants
	if is_instance_valid(_logo_png):
		_logo_png.texture = _try_load_logo(_LOGO_PATH_LIGHT if _is_light else _LOGO_PATH)

	# Warning colour is brand orange — cannot be left to the theme
	if is_instance_valid(_warn_label):
		_warn_label.add_theme_color_override("font_color",
			_BC_WARN_LIGHT if _is_light else _BC_WARN_DARK)
	if is_instance_valid(_stale_secret_label):
		_stale_secret_label.add_theme_color_override("font_color",
			_BC_WARN_LIGHT if _is_light else _BC_WARN_DARK)


# ── Panel build ────────────────────────────────────────────────────────────────

func _build_panel() -> Control:
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical        = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode     = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.custom_minimum_size        = Vector2(180, 0)

	var root := VBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", 0)
	scroll.add_child(root)

	# ── Header ────────────────────────────────────────────────────────────
	var header := MarginContainer.new()
	for s in ["left", "right", "top", "bottom"]:
		header.add_theme_constant_override("margin_" + s, 10)
	root.add_child(header)

	var hvbox := VBoxContainer.new()
	hvbox.add_theme_constant_override("separation", 4)
	hvbox.alignment = BoxContainer.ALIGNMENT_CENTER
	header.add_child(hvbox)

	# PNG logo — assign the dark-bg (white text) variant right away so it is on
	# screen the instant the dock draws; _update_panel_theme() swaps it to the
	# light-bg variant afterwards if needed, but that swap is async (awaits a
	# frame) and must never be the only place a texture gets assigned, or the
	# logo can end up blank until/unless that coroutine resolves.
	_logo_png = TextureRect.new()
	_logo_png.texture               = _try_load_logo(_LOGO_PATH)
	_logo_png.expand_mode           = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	_logo_png.stretch_mode          = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_logo_png.custom_minimum_size   = Vector2(0, 28)
	_logo_png.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hvbox.add_child(_logo_png)

	# Version — inherits theme font colour, no override needed
	var ver_row := HBoxContainer.new()
	ver_row.alignment = BoxContainer.ALIGNMENT_CENTER
	hvbox.add_child(ver_row)
	var ver_lbl := Label.new()
	ver_lbl.text = "Plugin " + _get_plugin_version()
	ver_lbl.add_theme_font_size_override("font_size", 9)
	ver_row.add_child(ver_lbl)

	root.add_child(_horiz_sep())

	# ── brainCloud Account (OAuth + Builder API login/team/app) ─────────────
	var acct_margin := MarginContainer.new()
	for s in ["left", "right", "top", "bottom"]:
		acct_margin.add_theme_constant_override("margin_" + s, 8)
	root.add_child(acct_margin)

	var acct_vbox := VBoxContainer.new()
	acct_vbox.add_theme_constant_override("separation", 8)
	acct_margin.add_child(acct_vbox)

	_account_container = VBoxContainer.new()
	_account_container.add_theme_constant_override("separation", 4)
	acct_vbox.add_child(_account_container)

	_children_box = VBoxContainer.new()
	_children_box.add_theme_constant_override("separation", 4)
	_children_box.visible = false
	acct_vbox.add_child(_children_box)

	root.add_child(_horiz_sep())

	# ── Credentials ───────────────────────────────────────────────────────
	var cred_margin := MarginContainer.new()
	for s in ["left", "right", "top", "bottom"]:
		cred_margin.add_theme_constant_override("margin_" + s, 8)
	root.add_child(cred_margin)

	var cvbox := VBoxContainer.new()
	cvbox.add_theme_constant_override("separation", 4)
	cred_margin.add_child(cvbox)

	var fields: Dictionary = {}

	# ── Server (always visible — most projects just use the default prod URL) ──
	var initial_server_url := _read_setting("server_url")

	var use_default_check := CheckBox.new()
	use_default_check.text           = "Use Default brainCloud Server"
	use_default_check.button_pressed = initial_server_url.is_empty() or initial_server_url == _DEFAULT_SERVER_URL
	use_default_check.add_theme_font_size_override("font_size", 11)
	cvbox.add_child(use_default_check)

	var server_lbl := Label.new()
	server_lbl.text = "Server URL"
	server_lbl.add_theme_font_size_override("font_size", 11)
	cvbox.add_child(server_lbl)

	var server_edit := LineEdit.new()
	server_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	server_edit.clear_button_enabled  = true
	server_edit.text                  = initial_server_url if not initial_server_url.is_empty() else _DEFAULT_SERVER_URL
	server_edit.add_theme_font_size_override("font_size", 11)
	cvbox.add_child(server_edit)
	fields["server_url"] = server_edit

	# Checked = hide the URL entirely (nothing to look at or edit); unchecked =
	# reveal the label + field for a custom value.
	var apply_default_server := func(use_default: bool):
		server_lbl.visible  = not use_default
		server_edit.visible = not use_default
		if use_default:
			server_edit.text = _DEFAULT_SERVER_URL
	apply_default_server.call(use_default_check.button_pressed)
	use_default_check.toggled.connect(apply_default_server)

	cvbox.add_child(_horiz_sep())

	# Collapsed by default — once the Account section above configures the app,
	# there's rarely a need to look at raw App ID/Secret. Click to expand for
	# manual entry (e.g. no portal login) or to copy/inspect values.
	_creds_header = Button.new()
	_creds_header.text                  = "▸ APP CREDENTIALS"
	_creds_header.flat                  = true
	_creds_header.alignment             = HORIZONTAL_ALIGNMENT_LEFT
	_creds_header.focus_mode            = Control.FOCUS_NONE
	_creds_header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_creds_header.add_theme_font_size_override("font_size", 10)
	_creds_header.add_theme_color_override("font_color", _BC_BLUE)
	_creds_header.add_theme_color_override("font_hover_color", _BC_BLUE.lightened(0.15))
	cvbox.add_child(_creds_header)

	_creds_fields_box = VBoxContainer.new()
	_creds_fields_box.add_theme_constant_override("separation", 4)
	_creds_fields_box.visible = false
	cvbox.add_child(_creds_fields_box)

	# App Name — read only. Manual App ID/Secret entry has no name to show, so
	# this row starts hidden; _update_synced_app_name() reveals it once the App
	# ID below matches an app synced through the brainCloud Account login flow.
	_app_name_row = VBoxContainer.new()
	_app_name_row.add_theme_constant_override("separation", 2)
	_app_name_row.visible = false
	_creds_fields_box.add_child(_app_name_row)

	var app_name_lbl := Label.new()
	app_name_lbl.text = "App Name"
	app_name_lbl.add_theme_font_size_override("font_size", 11)
	_app_name_row.add_child(app_name_lbl)

	_app_name_edit = LineEdit.new()
	_app_name_edit.editable              = false
	_app_name_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_app_name_edit.add_theme_font_size_override("font_size", 11)
	_app_name_row.add_child(_app_name_edit)

	_app_name_hint = Label.new()
	_app_name_hint.text = "Read only"
	_app_name_hint.add_theme_font_size_override("font_size", 9)
	_app_name_row.add_child(_app_name_hint)

	var app_ver_lbl := Label.new()
	app_ver_lbl.text = "App Version"
	app_ver_lbl.add_theme_font_size_override("font_size", 11)
	_creds_fields_box.add_child(app_ver_lbl)

	var app_ver_edit := LineEdit.new()
	app_ver_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	app_ver_edit.clear_button_enabled  = true
	app_ver_edit.text                  = _read_setting("app_version")
	app_ver_edit.add_theme_font_size_override("font_size", 11)
	_creds_fields_box.add_child(app_ver_edit)
	fields["app_version"] = app_ver_edit

	var on_creds_header_pressed := func():
		_creds_fields_box.visible = not _creds_fields_box.visible
		_creds_header.text = ("▾ " if _creds_fields_box.visible else "▸ ") + "APP CREDENTIALS"
	_creds_header.pressed.connect(on_creds_header_pressed)

	var field_defs := [
		["App ID",      "app_id",      false],
		["App Secret",  "app_secret",  true ],
	]

	for fd in field_defs:
		# No font_color override — inherits correctly from the editor theme
		var flbl := Label.new()
		flbl.text = fd[0]
		flbl.add_theme_font_size_override("font_size", 11)
		_creds_fields_box.add_child(flbl)

		var edit_row := HBoxContainer.new()
		edit_row.add_theme_constant_override("separation", 4)
		_creds_fields_box.add_child(edit_row)

		var edit := LineEdit.new()
		edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		edit.clear_button_enabled  = true
		edit.secret                = fd[2]
		edit.text                  = _read_setting(fd[1])
		edit.add_theme_font_size_override("font_size", 11)
		edit_row.add_child(edit)

		if fd[2]:
			var eye := Button.new()
			eye.text                = "Show"
			eye.toggle_mode         = true
			eye.flat                = true
			eye.focus_mode          = Control.FOCUS_NONE
			eye.custom_minimum_size = Vector2(38, 0)
			eye.add_theme_font_size_override("font_size", 10)
			eye.add_theme_color_override("font_color", _BC_BLUE)
			eye.toggled.connect(func(on: bool):
				edit.secret = not on
				eye.text    = "Hide" if on else "Show")
			edit_row.add_child(eye)

		fields[fd[1]] = edit

	_cred_fields = fields

	_child_list_box = VBoxContainer.new()
	_child_list_box.add_theme_constant_override("separation", 2)
	_child_list_box.visible = false
	_creds_fields_box.add_child(_child_list_box)

	var log_check := CheckBox.new()
	log_check.text                  = "Debug Logging"
	log_check.button_pressed        = bool(ProjectSettings.get_setting(
		"braincloud/debug/enable_logging", false))
	log_check.add_theme_font_size_override("font_size", 11)
	log_check.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_creds_fields_box.add_child(log_check)
	_log_check = log_check

	var status := Label.new()
	status.text                  = ""
	status.horizontal_alignment  = HORIZONTAL_ALIGNMENT_CENTER
	status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status.add_theme_font_size_override("font_size", 11)
	status.autowrap_mode         = TextServer.AUTOWRAP_WORD_SMART
	_creds_fields_box.add_child(status)
	_status_label = status

	var save_btn := Button.new()
	save_btn.text                  = "Save"
	save_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_btn.custom_minimum_size   = Vector2(0, 28)
	_style_primary(save_btn)
	save_btn.pressed.connect(_on_save.bind(fields, log_check, status))
	_creds_fields_box.add_child(save_btn)

	_warn_label = Label.new()
	_warn_label.text          = "⚠  braincloud.cfg is gitignored"
	_warn_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_warn_label.add_theme_font_size_override("font_size", 11)
	_creds_fields_box.add_child(_warn_label)

	_stale_secret_label = Label.new()
	_stale_secret_label.text          = ("⚠  Saved app secret is in an outdated format and can't be read. " +
		"Log in above and reselect this app to update it.")
	_stale_secret_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_stale_secret_label.add_theme_font_size_override("font_size", 11)
	_creds_fields_box.add_child(_stale_secret_label)
	_update_stale_secret_warning()

	# Below App Credentials (outside the collapsible box, so it stays visible even
	# when that section is collapsed) — hidden until logged in, see _refresh_account_section().
	_logout_btn = Button.new()
	_logout_btn.text                  = "Log out"
	_logout_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_logout_btn.custom_minimum_size   = Vector2(0, 24)
	_logout_btn.visible               = false
	var on_logout_pressed := func():
		_show_create_app = false
		_login_flow.logout()
	_logout_btn.pressed.connect(on_logout_pressed)
	cvbox.add_child(_logout_btn)

	root.add_child(_horiz_sep())

	# ── Resources ─────────────────────────────────────────────────────────
	var res_margin := MarginContainer.new()
	for s in ["left", "right", "top", "bottom"]:
		res_margin.add_theme_constant_override("margin_" + s, 8)
	root.add_child(res_margin)

	var rvbox := VBoxContainer.new()
	rvbox.add_theme_constant_override("separation", 4)
	res_margin.add_child(rvbox)

	rvbox.add_child(_section_lbl("Resources"))

	for link in _LINKS:
		rvbox.add_child(_link_btn(link["label"], link["url"]))

	# Apply initial logo + warning colour for the current theme
	_update_panel_theme()

	return scroll


# ── brainCloud Account (OAuth + Builder API) ────────────────────────────────────

func _refresh_account_section() -> void:
	if not is_instance_valid(_account_container):
		return
	for child in _account_container.get_children():
		_account_container.remove_child(child)
		child.queue_free()

	if _login_flow == null:
		return

	if _login_flow.is_logging_in():
		_build_logging_in_view()
	elif _login_flow.is_logged_in():
		_build_logged_in_view()
	else:
		_build_login_view()

	if is_instance_valid(_logout_btn):
		_logout_btn.visible = _login_flow.is_logged_in()

	_update_synced_app_name()
	_refresh_child_apps()


# Shows the read-only App Name row in App Credentials whenever the current App
# ID matches an app from the login flow's list — i.e. it was synced from the
# cloud rather than typed in by hand. Every live match is cached to disk
# (_save_app_name) so the name still displays "offline" — logged out, or a
# background team/app refresh failed (see _has_configured_app) — as long as
# the App ID hasn't since changed to something the cache wasn't captured for.
# Hidden entirely for manual entry with no cache, or an App ID that matches
# neither a synced app nor the cache.
func _update_synced_app_name() -> void:
	if not is_instance_valid(_app_name_row) or _login_flow == null:
		return
	var current_app_id: String = (_cred_fields["app_id"] as LineEdit).text.strip_edges() \
		if _cred_fields.has("app_id") else ""
	if current_app_id.is_empty():
		_app_name_row.visible = false
		return

	var live_name := ""
	for a in _login_flow.apps:
		if a["id"] == current_app_id:
			live_name = a["name"]
			break

	if not live_name.is_empty():
		_app_name_edit.text = live_name
		_app_name_hint.text = "Read only"
		_app_name_row.visible = true
		_save_app_name(current_app_id, live_name)
		return

	# No live match (logged out, or the app list just hasn't loaded yet) — fall
	# back to the last name cached for this exact App ID rather than hiding.
	var cached: Dictionary = BrainCloudNative.new().resolve_app_name(_CREDS_PATH)
	if str(cached.get("app_id", "")) == current_app_id:
		var cached_name := str(cached.get("app_name", ""))
		if not cached_name.is_empty():
			_app_name_edit.text = cached_name
			_app_name_hint.text = "Read only"
			_app_name_row.visible = true
			return

	_app_name_row.visible = false


# Persisted alongside App ID/Secret in braincloud.cfg (encoded, like app_id/app_secret)
# so _update_synced_app_name can still show a name while offline. Keyed to the App ID
# it was captured for so a manually-changed App ID never displays a stale cached name.
func _save_app_name(app_id: String, name: String) -> void:
	if app_id.is_empty() or name.is_empty():
		return
	var cached: Dictionary = BrainCloudNative.new().resolve_app_name(_CREDS_PATH)
	if str(cached.get("app_id", "")) == app_id and str(cached.get("app_name", "")) == name:
		return
	BrainCloudNative.new().save_app_name(_CREDS_PATH, app_id, name)


func _collapse_credentials() -> void:
	if is_instance_valid(_creds_fields_box):
		_creds_fields_box.visible = false
	if is_instance_valid(_creds_header):
		_creds_header.text = "▸ APP CREDENTIALS"


func _expand_credentials() -> void:
	if is_instance_valid(_creds_fields_box):
		_creds_fields_box.visible = true
	if is_instance_valid(_creds_header):
		_creds_header.text = "▾ APP CREDENTIALS"


# True once App ID + App Secret are already on disk — e.g. a session that was
# logged in yesterday but whose access token has since expired: refresh_teams()
# treats that as a login failure and drops back to State.LOGGED_OUT (see
# BrainCloudLoginFlow._on_login_error), even though the saved credentials are
# still valid and the SDK autoload keeps working fine with them.
func _has_configured_app() -> bool:
	return _cred_fields.has("app_id") and _cred_fields.has("app_secret") \
		and not (_cred_fields["app_id"] as LineEdit).text.strip_edges().is_empty() \
		and not (_cred_fields["app_secret"] as LineEdit).text.strip_edges().is_empty()


func _build_login_view() -> void:
	var has_app := _has_configured_app()

	# A configured app keeps working with its saved credentials whether or not
	# the brainCloud Account above is logged in — show them instead of hiding
	# behind the collapsed section, so it's obvious nothing is actually broken.
	if has_app:
		_expand_credentials()
	else:
		_collapse_credentials()

	_account_container.add_child(_section_lbl("brainCloud Account"))

	if has_app:
		var configured := Label.new()
		configured.text          = "This project's app credentials (below) are already configured and in use. Log in only if you want to switch to a different app."
		configured.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		configured.add_theme_font_size_override("font_size", 11)
		_account_container.add_child(configured)
	else:
		var desc := Label.new()
		desc.text          = "Go to the brainCloud portal to view more advanced configurations of your project and to find additional resources."
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc.add_theme_font_size_override("font_size", 11)
		_account_container.add_child(desc)

	var portal_link := LinkButton.new()
	portal_link.text = "brainCloud Portal"
	portal_link.add_theme_font_size_override("font_size", 11)
	portal_link.add_theme_color_override("font_color", _BC_BLUE)
	portal_link.pressed.connect(func(): OS.shell_open(_portal_url()))
	_account_container.add_child(portal_link)

	# Suppressed until the user actually clicks Log in/Change App — an expired
	# session's automatic background refresh_teams() (see _has_configured_app)
	# fails silently here instead of greeting a working project with red text.
	if _user_triggered_login and not _login_flow.error_message.is_empty():
		_account_container.add_child(_error_lbl(_login_flow.error_message))

	# "Change App" is the same login flow as "Log in with brainCloud" — logging
	# back in lands on _build_logged_in_view()'s team/app dropdown either way.
	# Only the label changes, so a project that's already working doesn't read
	# as "log in or nothing here works."
	var login_btn := Button.new()
	login_btn.text                  = "Change App" if has_app else "Log in with brainCloud"
	login_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	login_btn.custom_minimum_size   = Vector2(0, 28)
	_style_primary(login_btn)
	login_btn.pressed.connect(_on_login_pressed)
	_account_container.add_child(login_btn)


func _build_logging_in_view() -> void:
	_account_container.add_child(_section_lbl("brainCloud Account"))

	var status := Label.new()
	status.text                  = "Waiting for browser login…"
	status.horizontal_alignment  = HORIZONTAL_ALIGNMENT_CENTER
	status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status.add_theme_font_size_override("font_size", 11)
	_account_container.add_child(status)

	var cancel_btn := Button.new()
	cancel_btn.text                  = "Cancel"
	cancel_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cancel_btn.custom_minimum_size   = Vector2(0, 28)
	cancel_btn.pressed.connect(_login_flow.cancel_login)
	_account_container.add_child(cancel_btn)


func _build_logged_in_view() -> void:
	_account_container.add_child(_section_lbl("brainCloud Account"))

	if not _login_flow.email.is_empty():
		var who := Label.new()
		who.text = _login_flow.email
		who.add_theme_font_size_override("font_size", 10)
		_account_container.add_child(who)

	if not _login_flow.error_message.is_empty():
		_account_container.add_child(_error_lbl(_login_flow.error_message))

	# Team picker
	var team_lbl := Label.new()
	team_lbl.text = "Team"
	team_lbl.add_theme_font_size_override("font_size", 11)
	_account_container.add_child(team_lbl)

	var team_row := HBoxContainer.new()
	team_row.add_theme_constant_override("separation", 4)
	_account_container.add_child(team_row)

	var team_option := OptionButton.new()
	team_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	team_option.add_theme_font_size_override("font_size", 11)
	for i in _login_flow.teams.size():
		var t: Dictionary = _login_flow.teams[i]
		team_option.add_item(t["name"])
		if t["id"] == _login_flow.team_id:
			team_option.select(i)
	var on_team_selected := func(idx: int):
		_show_create_app = false
		_login_flow.select_team(_login_flow.teams[idx]["id"])
		_refresh_account_section()
	team_option.item_selected.connect(on_team_selected)
	team_row.add_child(team_option)
	team_row.add_child(_refresh_btn(_login_flow.refresh_teams))

	# App picker
	var app_lbl := Label.new()
	app_lbl.text = "App"
	app_lbl.add_theme_font_size_override("font_size", 11)
	_account_container.add_child(app_lbl)

	var app_row := HBoxContainer.new()
	app_row.add_theme_constant_override("separation", 4)
	_account_container.add_child(app_row)

	var app_option := OptionButton.new()
	app_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	app_option.add_theme_font_size_override("font_size", 11)
	var current_app_id: String = (_cred_fields["app_id"] as LineEdit).text.strip_edges() if _cred_fields.has("app_id") else ""
	var selected_idx := 0
	for i in _login_flow.apps.size():
		var listed: Dictionary = _login_flow.apps[i]
		var parent_label := ""
		if listed.get("is_parent", false):
			parent_label = "  Parent: " + listed["level_name"] if not str(listed.get("level_name", "")).is_empty() else "  Parent"
		app_option.add_item(listed["name"] + parent_label)
		if not _show_create_app and _login_flow.apps[i]["id"] == current_app_id and not current_app_id.is_empty():
			selected_idx = i
	if app_option.item_count > 0:
		app_option.select(selected_idx)
	var is_create_selected: bool = app_option.item_count > 0 and _login_flow.apps[selected_idx]["id"] == BrainCloudLoginFlow.CREATE_NEW_APP_ID
	_show_create_app = is_create_selected

	var on_app_selected_ui := func(idx: int):
		var a: Dictionary = _login_flow.apps[idx]
		# Only ever show Create New App / template UI when that sentinel is the
		# active dropdown choice — rebuild immediately either way so picking a
		# real app hides it right away instead of lingering from before.
		_show_create_app = a["id"] == BrainCloudLoginFlow.CREATE_NEW_APP_ID
		if not _show_create_app:
			_login_flow.select_app(a["id"])
		_refresh_account_section()
	app_option.item_selected.connect(on_app_selected_ui)
	app_row.add_child(app_option)
	app_row.add_child(_refresh_btn(_login_flow.download_app_list.bind(true)))

	if is_create_selected:
		_account_container.add_child(_build_create_app_fields())


func _build_create_app_fields() -> Control:
	if _new_app_platform_state.is_empty():
		for p in _CREATE_APP_PLATFORMS:
			_new_app_platform_state[p["id"]] = p["default"]

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)

	var name_lbl := Label.new()
	name_lbl.text = "App Name"
	name_lbl.add_theme_font_size_override("font_size", 11)
	box.add_child(name_lbl)

	_new_app_name_edit = LineEdit.new()
	_new_app_name_edit.placeholder_text        = "New brainCloud App Name"
	_new_app_name_edit.text                    = _new_app_name
	_new_app_name_edit.size_flags_horizontal   = Control.SIZE_EXPAND_FILL
	_new_app_name_edit.add_theme_font_size_override("font_size", 11)
	var on_name_changed := func(new_text: String): _new_app_name = new_text
	_new_app_name_edit.text_changed.connect(on_name_changed)
	box.add_child(_new_app_name_edit)

	var template_check := CheckBox.new()
	template_check.text           = "Create using Tutorial template"
	template_check.button_pressed = _create_with_template
	template_check.add_theme_font_size_override("font_size", 11)
	var on_template_toggled := func(pressed: bool):
		_create_with_template = pressed
		if pressed:
			_login_flow.download_template_list()
		_refresh_account_section()
	template_check.toggled.connect(on_template_toggled)
	box.add_child(template_check)

	# Template replaces the platform list.
	if _create_with_template:
		box.add_child(_build_template_picker())
	else:
		box.add_child(_build_platform_checks())

	var create_btn := Button.new()
	create_btn.text                  = "Create App"
	create_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	create_btn.custom_minimum_size   = Vector2(0, 28)
	_style_primary(create_btn)
	create_btn.pressed.connect(_on_create_app_pressed)
	box.add_child(create_btn)

	return box


func _build_platform_checks() -> Control:
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)

	var plat_lbl := Label.new()
	plat_lbl.text = "Platforms"
	plat_lbl.add_theme_font_size_override("font_size", 11)
	vbox.add_child(plat_lbl)

	var grid := GridContainer.new()
	grid.columns = 2
	for p in _CREATE_APP_PLATFORMS:
		var cb := CheckBox.new()
		cb.text                  = p["label"]
		cb.button_pressed        = bool(_new_app_platform_state.get(p["id"], p["default"]))
		cb.add_theme_font_size_override("font_size", 10)
		var platform_id: String = p["id"]
		var on_platform_toggled := func(pressed: bool): _new_app_platform_state[platform_id] = pressed
		cb.toggled.connect(on_platform_toggled)
		grid.add_child(cb)
	vbox.add_child(grid)

	return vbox


func _build_template_picker() -> Control:
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)

	var lbl := Label.new()
	lbl.text = "Template"
	lbl.add_theme_font_size_override("font_size", 11)
	vbox.add_child(lbl)

	if _login_flow.templates.is_empty():
		var row_empty := HBoxContainer.new()
		row_empty.add_theme_constant_override("separation", 4)
		var loading := Label.new()
		loading.text = "Loading templates…" if _login_flow.templates_loading else "No templates are available yet."
		loading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		loading.add_theme_font_size_override("font_size", 10)
		row_empty.add_child(loading)
		if not _login_flow.templates_loading:
			row_empty.add_child(_refresh_btn(_login_flow.download_template_list.bind(true)))
		vbox.add_child(row_empty)
		return vbox

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	vbox.add_child(row)

	var option := OptionButton.new()
	option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	option.add_theme_font_size_override("font_size", 11)
	var selected_idx := -1
	for i in _login_flow.templates.size():
		var t: Dictionary = _login_flow.templates[i]
		option.add_item(t["name"])
		if t["id"] == _selected_template_id:
			selected_idx = i
	# Default to the first; add_item auto-selects it without updating the id.
	if selected_idx == -1:
		selected_idx = 0
		_selected_template_id = _login_flow.templates[0]["id"]
	option.select(selected_idx)
	var on_template_selected := func(idx: int):
		_selected_template_id = _login_flow.templates[idx]["id"]
	option.item_selected.connect(on_template_selected)
	row.add_child(option)
	row.add_child(_refresh_btn(_login_flow.download_template_list.bind(true)))

	return vbox


func _refresh_btn(callback: Callable) -> Button:
	var btn := Button.new()
	btn.text                  = "⟳"
	btn.tooltip_text          = "Refresh"
	btn.custom_minimum_size   = Vector2(28, 0)
	btn.flat                  = true
	btn.focus_mode            = Control.FOCUS_NONE
	btn.add_theme_font_size_override("font_size", 12)
	btn.pressed.connect(callback)
	return btn


func _error_lbl(text: String) -> Label:
	var lbl := Label.new()
	lbl.text          = text
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.add_theme_font_size_override("font_size", 11)
	lbl.add_theme_color_override("font_color", Color("#dd5555"))
	return lbl


func _current_server_url() -> String:
	var server_url := ""
	if _cred_fields.has("server_url"):
		server_url = (_cred_fields["server_url"] as LineEdit).text.strip_edges()
	if server_url.is_empty():
		server_url = _read_setting("server_url")
	return server_url


func _portal_url() -> String:
	return BrainCloudBuilderApi.portal_host(_current_server_url())


func _on_login_pressed() -> void:
	_user_triggered_login = true
	_login_flow.set_base_host(BrainCloudBuilderApi.base_host(_current_server_url()))
	_login_flow.login()


func _on_create_app_pressed() -> void:
	var platforms: Array = []
	for p in _CREATE_APP_PLATFORMS:
		if bool(_new_app_platform_state.get(p["id"], p["default"])):
			platforms.append(p["id"])
	var template_id := _selected_template_id if _create_with_template else ""
	if _create_with_template and template_id.is_empty():
		_login_flow.error_message = "Select a template, or uncheck Create using Tutorial template."
		_refresh_account_section()
		return
	_login_flow.create_app(_new_app_name, platforms, template_id)


func _on_app_selected(app_id: String, app_secret: String) -> void:
	(_cred_fields["app_id"] as LineEdit).text     = app_id
	(_cred_fields["app_secret"] as LineEdit).text = app_secret
	_on_save(_cred_fields, _log_check, _status_label)
	_recall_child_apps(app_id)
	# Rebuild so the App dropdown actually shows the newly created/selected app instead of
	# lingering on "-- Create New App --" with no visible feedback that anything happened.
	_show_create_app = false
	_refresh_account_section()


# ── Child apps ─────────────────────────────────────────────────────────────────

# Untyped so an older native build without the child app methods still loads the dock.
func _native_call(method: String, args: Array = []) -> Variant:
	var native: Object = BrainCloudNative.new()
	return native.callv(method, args) if native.has_method(method) else null


func _configured_app_id() -> String:
	var resolved: Dictionary = BrainCloudNative.new().resolve_app_name(_CREDS_PATH)
	return str(resolved.get("app_id", ""))


func _saved_child_ids() -> PackedStringArray:
	var ids = _native_call("resolve_child_ids", [_CREDS_PATH])
	return ids if ids is PackedStringArray else PackedStringArray()


func _refresh_child_apps() -> void:
	if not is_instance_valid(_children_box) or _login_flow == null:
		return
	for child in _children_box.get_children():
		_children_box.remove_child(child)
		child.queue_free()

	_refresh_child_list()

	var parent_id := _configured_app_id()
	if parent_id != _child_rows_for:
		_child_rows = []
		_child_rows_for = parent_id
		_child_error = ""

	# Saved children first (in file order), then rows still being filled in.
	var saved := _saved_child_ids()
	var rows: Array = []
	for id in saved:
		var row := _child_row(id)
		if row.is_empty():
			row = {"id": id, "manual": not _login_flow.is_child_of(id, parent_id), "draft_id": id, "draft_value": ""}
		rows.append(row)
	for row in _child_rows:
		if str(row["id"]).is_empty():
			rows.append(row)
	_child_rows = rows

	var parent: Dictionary = _login_flow.find_app(parent_id)
	var is_parent: bool = parent.get("is_parent", false)
	# Editing needs a login; logged out, the list under App Credentials is enough.
	_children_box.visible = _login_flow.is_logged_in() and not parent_id.is_empty() \
		and (not parent.is_empty() or not _child_rows.is_empty())
	if not _children_box.visible:
		return

	# Set in the portal; the plugin's Builder access can't change it.
	var flag := CheckBox.new()
	flag.text           = "Parent app (set in the brainCloud portal)"
	flag.button_pressed = is_parent
	flag.disabled       = true
	flag.add_theme_font_size_override("font_size", 11)
	_children_box.add_child(flag)

	# Hidden for non-parents unless the config already has child apps.
	if not is_parent and _child_rows.is_empty():
		return

	var children: Array = _login_flow.child_apps_of(parent_id)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 4)
	_children_box.add_child(header)
	var title := Label.new()
	title.text                  = "Child Apps"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 11)
	header.add_child(title)
	var add_btn := Button.new()
	add_btn.text                = "+"
	add_btn.tooltip_text        = "Add a child app to the project."
	add_btn.flat                = true
	add_btn.focus_mode          = Control.FOCUS_NONE
	add_btn.custom_minimum_size = Vector2(28, 0)
	add_btn.pressed.connect(func():
		_child_rows.append({"id": "", "manual": children.is_empty(), "draft_id": "", "draft_value": ""})
		_refresh_child_apps())
	header.add_child(add_btn)

	if is_parent and children.is_empty():
		var hint := Label.new()
		hint.text          = "No child apps visible. Link children in the brainCloud portal (or ask a team admin)."
		hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		hint.add_theme_font_size_override("font_size", 10)
		_children_box.add_child(hint)

	if not _child_error.is_empty():
		_children_box.add_child(_error_lbl(_child_error))

	for row in _child_rows:
		_children_box.add_child(_build_child_row(row, children, saved.find(row["id"])))


# Read-only "[index] id Name" lines, in get_child_app_id_list() order.
func _refresh_child_list() -> void:
	if not is_instance_valid(_child_list_box):
		return
	for child in _child_list_box.get_children():
		_child_list_box.remove_child(child)
		child.queue_free()
	var ids := _saved_child_ids()
	_child_list_box.visible = not ids.is_empty()
	if ids.is_empty():
		return

	var title := Label.new()
	title.text = "Child Apps"
	title.add_theme_font_size_override("font_size", 11)
	_child_list_box.add_child(title)
	for i in ids.size():
		var app_name := str(_login_flow.find_app(ids[i]).get("name", ""))
		var line := Label.new()
		line.text = "[%d] %s" % [i, ids[i]] + ("  " + app_name if not app_name.is_empty() else "")
		line.add_theme_font_size_override("font_size", 11)
		_child_list_box.add_child(line)


func _child_row(id: String) -> Dictionary:
	for row in _child_rows:
		if row["id"] == id:
			return row
	return {}


# index: position in the config (= get_child_app_id_list() order), -1 while pending.
func _build_child_row(row: Dictionary, children: Array, index: int) -> Control:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)

	# Children not already used by another row.
	var options: Array = []
	for child in children:
		var used := false
		for other in _child_rows:
			if not is_same(other, row) and other["id"] == child["id"]:
				used = true
				break
		if not used:
			options.append(child)

	var pick := OptionButton.new()
	pick.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pick.add_theme_font_size_override("font_size", 11)
	pick.add_item(_CHILD_PLACEHOLDER)
	var selected := 0
	for i in options.size():
		pick.add_item("%s (%s)" % [options[i]["name"], options[i]["id"]])
		if not row["manual"] and options[i]["id"] == row["id"]:
			selected = i + 1
	pick.add_item(_CHILD_MANUAL)
	var manual_index := pick.item_count - 1
	if row["manual"] or (selected == 0 and not str(row["id"]).is_empty()):
		row["manual"] = true
		selected = manual_index
	pick.select(selected)
	pick.item_selected.connect(func(idx: int):
		_child_error = ""
		if idx == manual_index:
			row["manual"] = true
			row["draft_id"] = row["id"]
			_refresh_child_apps()
		elif idx == 0:
			row["manual"] = false
			_remove_child_app(row, false)
		else:
			_pick_child_app(row, options[idx - 1]["id"]))

	var remove := Button.new()
	remove.text       = "Delete"
	remove.flat       = true
	remove.focus_mode = Control.FOCUS_NONE
	remove.add_theme_font_size_override("font_size", 10)
	remove.pressed.connect(func():
		_child_error = ""
		_remove_child_app(row, true))

	var line := HBoxContainer.new()
	line.add_theme_constant_override("separation", 4)
	if index >= 0:
		var index_lbl := Label.new()
		index_lbl.text         = "[%d]" % index
		index_lbl.tooltip_text = "Index in get_child_app_id_list()"
		index_lbl.mouse_filter = Control.MOUSE_FILTER_PASS
		index_lbl.add_theme_font_size_override("font_size", 11)
		line.add_child(index_lbl)
	line.add_child(pick)
	line.add_child(remove)
	box.add_child(line)

	if row["manual"]:
		var id_edit := LineEdit.new()
		id_edit.placeholder_text      = "Child App ID"
		id_edit.text                  = row["draft_id"]
		id_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		id_edit.add_theme_font_size_override("font_size", 11)
		id_edit.text_changed.connect(func(text: String): row["draft_id"] = text)
		box.add_child(id_edit)

		var value_edit := LineEdit.new()
		value_edit.placeholder_text      = "Saved (enter to replace)" if not str(row["id"]).is_empty() else "Child App Secret"
		value_edit.text                  = row["draft_value"]
		value_edit.secret                = true
		value_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		value_edit.add_theme_font_size_override("font_size", 11)
		value_edit.text_changed.connect(func(text: String): row["draft_value"] = text)
		box.add_child(value_edit)

		var save := Button.new()
		save.text                  = "Save Child App"
		save.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		save.add_theme_font_size_override("font_size", 11)
		save.pressed.connect(func(): _save_manual_child_app(row))
		box.add_child(save)

	return box


# Fetches the child's profile into braincloud.cfg.
func _pick_child_app(row: Dictionary, child_id: String) -> void:
	var parent_id := _child_rows_for
	_login_flow.fetch_app_secret(child_id, func(secret: String):
		if _configured_app_id() != parent_id:
			return  # switched apps while fetching
		if not str(row["id"]).is_empty() and row["id"] != child_id:
			_native_call("remove_child_config", [_CREDS_PATH, row["id"]])
		if _native_call("add_child_config", [_CREDS_PATH, child_id, secret]) == true:
			row["id"] = child_id
			row["manual"] = false
		else:
			_child_error = "Failed to save child app."
		_remember_child_apps()
		_refresh_child_apps())


func _save_manual_child_app(row: Dictionary) -> void:
	var id := str(row["draft_id"]).strip_edges()
	var value := str(row["draft_value"]).strip_edges()
	_child_error = ""
	if id.is_empty() or (value.is_empty() and id != row["id"]):
		_child_error = "Child App ID and Secret are required."
	elif id == _child_rows_for:
		_child_error = "A child app can't be the configured app."
	elif not _child_row(id).is_empty() and not is_same(_child_row(id), row):
		_child_error = "That child app is already added."
	elif value.is_empty():
		pass  # same id, nothing to replace
	else:
		if not str(row["id"]).is_empty() and row["id"] != id:
			_native_call("remove_child_config", [_CREDS_PATH, row["id"]])
		if _native_call("add_child_config", [_CREDS_PATH, id, value]) == true:
			row["id"] = id
			row["draft_value"] = ""
		else:
			_child_error = "Failed to save child app."
		_remember_child_apps()
	_refresh_child_apps()


func _remove_child_app(row: Dictionary, drop_row: bool) -> void:
	if not str(row["id"]).is_empty():
		_native_call("remove_child_config", [_CREDS_PATH, row["id"]])
	row["id"] = ""
	row["draft_id"] = ""
	row["draft_value"] = ""
	if drop_row:
		_child_rows = _child_rows.filter(func(other): return not is_same(other, row))
	_remember_child_apps()
	_refresh_child_apps()


# Manual rows aren't remembered; their profile can't be fetched again.
func _remember_child_apps() -> void:
	var parent_id := _child_rows_for
	if parent_id.is_empty() or _login_flow.apps.is_empty():
		return
	var ids: Array = []
	for id in _saved_child_ids():
		if _login_flow.is_child_of(id, parent_id):
			ids.append(id)
	var es := get_editor_interface().get_editor_settings()
	var remembered: Dictionary = es.get_project_metadata(_CHILD_META_SECTION, _CHILD_META_KEY, {})
	if ids.is_empty():
		remembered.erase(parent_id)
	else:
		remembered[parent_id] = ids
	es.set_project_metadata(_CHILD_META_SECTION, _CHILD_META_KEY, remembered)


# Rebuilds a reselected parent's children and fetches their profiles again.
func _recall_child_apps(parent_id: String) -> void:
	if not _saved_child_ids().is_empty():
		return
	var es := get_editor_interface().get_editor_settings()
	var remembered: Dictionary = es.get_project_metadata(_CHILD_META_SECTION, _CHILD_META_KEY, {})
	for id in remembered.get(parent_id, []):
		var child_id := str(id)
		if not _login_flow.is_child_of(child_id, parent_id):
			continue
		_login_flow.fetch_app_secret(child_id, func(secret: String):
			if _configured_app_id() != parent_id:
				return
			_native_call("add_child_config", [_CREDS_PATH, child_id, secret])
			_refresh_child_apps())


# ── Style helpers ──────────────────────────────────────────────────────────────

func _horiz_sep() -> HSeparator:
	var sep   := HSeparator.new()
	var style := StyleBoxLine.new()
	style.color     = _BC_BLUE
	style.thickness = 1
	sep.add_theme_stylebox_override("separator", style)
	return sep


func _section_lbl(text: String) -> Label:
	var lbl := Label.new()
	lbl.text = text.to_upper()
	lbl.add_theme_font_size_override("font_size", 10)
	lbl.add_theme_color_override("font_color", _BC_BLUE)
	return lbl


func _style_primary(btn: Button) -> void:
	for state in ["normal", "hover", "pressed"]:
		var s := StyleBoxFlat.new()
		s.bg_color = _BC_BLUE if state == "normal" else \
					 _BC_BLUE.lightened(0.12) if state == "hover" else \
					 _BC_BLUE.darkened(0.12)
		s.corner_radius_top_left     = 3
		s.corner_radius_top_right    = 3
		s.corner_radius_bottom_left  = 3
		s.corner_radius_bottom_right = 3
		s.content_margin_top         = 5
		s.content_margin_bottom      = 5
		btn.add_theme_stylebox_override(state, s)
	btn.add_theme_color_override("font_color",         Color.WHITE)
	btn.add_theme_color_override("font_hover_color",   Color.WHITE)
	btn.add_theme_color_override("font_pressed_color", Color.WHITE)


func _link_btn(text: String, url: String) -> Button:
	var btn := Button.new()
	btn.text                  = text
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.custom_minimum_size   = Vector2(0, 28)
	for state in ["normal", "hover", "pressed"]:
		var s := StyleBoxFlat.new()
		s.bg_color     = Color(0,0,0,0) if state == "normal" else Color(_BC_BLUE, 0.15 if state == "hover" else 0.25)
		s.border_color = Color(_BC_BLUE, 0.5 if state == "normal" else 1.0)
		for side in ["top", "bottom", "left", "right"]:
			s.set("border_width_" + side, 1)
		s.corner_radius_top_left     = 3
		s.corner_radius_top_right    = 3
		s.corner_radius_bottom_left  = 3
		s.corner_radius_bottom_right = 3
		s.content_margin_top         = 3
		s.content_margin_bottom      = 3
		btn.add_theme_stylebox_override(state, s)
	btn.add_theme_font_size_override("font_size", 11)
	var bold_font := get_editor_interface().get_editor_theme().get_font("bold", "EditorFonts")
	if bold_font:
		btn.add_theme_font_override("font", bold_font)
	btn.add_theme_color_override("font_color",         _BC_BLUE)
	btn.add_theme_color_override("font_hover_color",   _BC_BLUE.lightened(0.15))
	btn.add_theme_color_override("font_pressed_color", _BC_BLUE.darkened(0.1))
	btn.pressed.connect(func(): OS.shell_open(url))
	return btn


func _try_load_logo(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	return null


func _get_plugin_version() -> String:
	var cfg := ConfigFile.new()
	if cfg.load("res://addons/braincloud/plugin.cfg") == OK:
		return cfg.get_value("plugin", "version", "?")
	return "?"


# ── Data helpers ───────────────────────────────────────────────────────────────

func _read_setting(key: String) -> String:
	if key == "app_secret":
		return _read_stored_secret()
	if key in ["app_id", "app_name"]:
		var resolved: Dictionary = BrainCloudNative.new().resolve_app_name(_CREDS_PATH)
		return str(resolved.get(key, ""))
	var full_key := "braincloud/config/" + key
	if ProjectSettings.has_setting(full_key):
		var v = ProjectSettings.get_setting(full_key)
		return str(v) if v != null else ""
	return ""


func _read_stored_secret() -> String:
	var resolved: Dictionary = BrainCloudNative.new().resolve_config_sync(_CREDS_PATH)
	return str(resolved.get("secret", ""))


func _on_save(fields: Dictionary, log_check: CheckBox, status: Label) -> void:
	var app_id     := (fields["app_id"]      as LineEdit).text.strip_edges()
	var app_secret := (fields["app_secret"]  as LineEdit).text.strip_edges()
	var server_url := (fields["server_url"]  as LineEdit).text.strip_edges()
	var app_ver    := (fields["app_version"] as LineEdit).text.strip_edges()

	if app_id.is_empty() or app_secret.is_empty() or server_url.is_empty():
		status.add_theme_color_override("font_color", Color("#dd5555"))
		status.text = "App ID, Secret and URL are required."
		return

	if not BrainCloudNative.new().prepare_config(_CREDS_PATH, app_id, app_secret):
		status.add_theme_color_override("font_color", Color("#dd5555"))
		status.text = "Failed to save credentials."
		return
	_ensure_gitignore()

	var web_settings := BrainCloudWebConfig.encode(app_secret)
	ProjectSettings.set_setting("braincloud/config/app_id.web", app_id)
	ProjectSettings.set_setting("braincloud/config/app_a.web", web_settings["a"])
	ProjectSettings.set_setting("braincloud/config/app_b.web", web_settings["b"])
	for old_key in ["braincloud/config/app_share.web", "braincloud/config/app_pad.web"]:
		if ProjectSettings.has_setting(old_key):
			ProjectSettings.set_setting(old_key, null)

	ProjectSettings.set_setting("braincloud/config/server_url",    server_url)
	ProjectSettings.set_setting("braincloud/config/app_version",   app_ver if not app_ver.is_empty() else "1.0.0")
	ProjectSettings.set_setting("braincloud/debug/enable_logging", log_check.button_pressed)
	ProjectSettings.save()

	status.add_theme_color_override("font_color", Color("#44bb66"))
	status.text = "✓  Saved"
	_update_stale_secret_warning()
	_refresh_child_apps()


func _ensure_gitignore() -> void:
	var path    := "res://.gitignore"
	var entry   := "addons/braincloud/braincloud.cfg"
	var content := ""

	if FileAccess.file_exists(path):
		var f := FileAccess.open(path, FileAccess.READ)
		if f:
			content = f.get_as_text()

	if entry in content:
		return

	if content.length() > 0 and not content.ends_with("\n"):
		content += "\n"
	content += entry + "\n"

	var f := FileAccess.open(path, FileAccess.WRITE)
	if f:
		f.store_string(content)


# An app_id with no readable secret looks configured but can't authenticate -- most
# often because it was saved before this addon's current encoding scheme (that path
# is a clean break, not an auto-migration; see BrainCloudNative.resolve_config).
# Surface that explicitly instead of leaving the App Secret field blank with no
# explanation of why a previously-working project stopped authenticating.
func _update_stale_secret_warning() -> void:
	if not is_instance_valid(_stale_secret_label):
		return
	var app_id     := (_cred_fields["app_id"]     as LineEdit).text.strip_edges()
	var app_secret := (_cred_fields["app_secret"] as LineEdit).text.strip_edges()
	_stale_secret_label.visible = not app_id.is_empty() and app_secret.is_empty()
