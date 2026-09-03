# Copyright 2026 bitHeads, Inc. All Rights Reserved.
@tool
extends EditorPlugin

const _AUTOLOAD_NAME := "brainCloud"
const _WRAPPER_PATH  := "res://addons/braincloud/BrainCloudWrapper.gd"
const _MENU_ITEM     := "brainCloud"

# Credentials are stored here — add this path to .gitignore
const _CREDS_PATH    := "res://addons/braincloud/braincloud.cfg"

# "Create using Template" is suppressed until we can confirm the list of templates
# available. Flip back on once that's confirmed.
const _TEMPLATES_ENABLED := false

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
	{"label": "Portal",        "url": "https://portal.braincloudservers.com/"},
	{"label": "API Reference", "url": "https://getbraincloud.com/apidocs/apiref/"},
	{"label": "Docs",          "url": "https://getbraincloud.com/apidocs/"},
	{"label": "GDScript SDK",  "url": "https://github.com/getbraincloud/braincloud-gdscript"},
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

var _panel_control: Control = null

# Nodes that need to swap when the editor theme changes
var _logo_png:   TextureRect = null  # swaps between dark-bg and light-bg variant
var _warn_label: Label       = null  # brand orange — cannot inherit from theme

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


func _enter_tree() -> void:
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
	_login_flow.configure(_CREDS_PATH, _panel_control)
	_login_flow.state_changed.connect(_refresh_account_section)
	_login_flow.app_selected.connect(_on_app_selected)
	_refresh_account_section()
	if _login_flow.is_logged_in() and _login_flow.teams.is_empty():
		_login_flow.refresh_teams()


func _exit_tree() -> void:
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

	_account_container = VBoxContainer.new()
	_account_container.add_theme_constant_override("separation", 4)
	acct_margin.add_child(_account_container)

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
	if _read_setting("app_name_id") == current_app_id:
		var cached_name := _read_setting("app_name")
		if not cached_name.is_empty():
			_app_name_edit.text = cached_name
			_app_name_hint.text = "Read only"
			_app_name_row.visible = true
			return

	_app_name_row.visible = false


# Persisted alongside App ID/Secret in braincloud.cfg so _update_synced_app_name
# can still show a name while offline. Keyed to the App ID it was captured for
# so a manually-changed App ID never displays a stale cached name.
func _save_app_name(app_id: String, name: String) -> void:
	if app_id.is_empty() or name.is_empty():
		return
	if _read_setting("app_name_id") == app_id and _read_setting("app_name") == name:
		return
	var creds := ConfigFile.new()
	creds.load(_CREDS_PATH)  # preserve other sections already on disk
	creds.set_value("credentials", "app_name_id", app_id)
	creds.set_value("credentials", "app_name",    name)
	creds.save(_CREDS_PATH)


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
		app_option.add_item(_login_flow.apps[i]["name"])
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

	# "Create using Template" is suppressed until we can confirm the list of templates
	# available — see _build_template_picker(). Re-enable by restoring this checkbox.
	if _TEMPLATES_ENABLED:
		var template_check := CheckBox.new()
		template_check.text           = "Create using Template"
		template_check.button_pressed = _create_with_template
		template_check.add_theme_font_size_override("font_size", 11)
		var on_template_toggled := func(pressed: bool):
			_create_with_template = pressed
			if pressed:
				_login_flow.download_template_list()
			_refresh_account_section()
		template_check.toggled.connect(on_template_toggled)
		box.add_child(template_check)

	if _TEMPLATES_ENABLED and _create_with_template:
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
		var loading := Label.new()
		loading.text = "Loading templates…"
		loading.add_theme_font_size_override("font_size", 10)
		vbox.add_child(loading)
		return vbox

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	vbox.add_child(row)

	var option := OptionButton.new()
	option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	option.add_theme_font_size_override("font_size", 11)
	for i in _login_flow.templates.size():
		var t: Dictionary = _login_flow.templates[i]
		option.add_item(t["name"])
		if t["id"] == _selected_template_id:
			option.select(i)
	if option.selected == -1 and option.item_count > 0:
		option.select(0)
		_selected_template_id = _login_flow.templates[0]["id"]
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
	_login_flow.create_app(_new_app_name, platforms, template_id)


func _on_app_selected(app_id: String, app_secret: String) -> void:
	(_cred_fields["app_id"] as LineEdit).text     = app_id
	(_cred_fields["app_secret"] as LineEdit).text = app_secret
	_on_save(_cred_fields, _log_check, _status_label)
	# Rebuild so the App dropdown actually shows the newly created/selected app instead of
	# lingering on "-- Create New App --" with no visible feedback that anything happened.
	_show_create_app = false
	_refresh_account_section()


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
	if key in ["app_id", "app_secret", "app_name", "app_name_id"]:
		var cfg := ConfigFile.new()
		if cfg.load(_CREDS_PATH) == OK:
			var v = str(cfg.get_value("credentials", key, ""))
			if not v.is_empty():
				return v
		return ""
	var full_key := "braincloud/config/" + key
	if ProjectSettings.has_setting(full_key):
		var v = ProjectSettings.get_setting(full_key)
		return str(v) if v != null else ""
	return ""


func _on_save(fields: Dictionary, log_check: CheckBox, status: Label) -> void:
	var app_id     := (fields["app_id"]      as LineEdit).text.strip_edges()
	var app_secret := (fields["app_secret"]  as LineEdit).text.strip_edges()
	var server_url := (fields["server_url"]  as LineEdit).text.strip_edges()
	var app_ver    := (fields["app_version"] as LineEdit).text.strip_edges()

	if app_id.is_empty() or app_secret.is_empty() or server_url.is_empty():
		status.add_theme_color_override("font_color", Color("#dd5555"))
		status.text = "App ID, Secret and URL are required."
		return

	var creds := ConfigFile.new()
	creds.load(_CREDS_PATH)  # preserve other sections already on disk (e.g. [oauth] session)
	creds.set_value("credentials", "app_id",    app_id)
	creds.set_value("credentials", "app_secret", app_secret)
	creds.save(_CREDS_PATH)
	_ensure_gitignore()

	ProjectSettings.set_setting("braincloud/config/server_url",    server_url)
	ProjectSettings.set_setting("braincloud/config/app_version",   app_ver if not app_ver.is_empty() else "1.0.0")
	ProjectSettings.set_setting("braincloud/debug/enable_logging", log_check.button_pressed)
	ProjectSettings.save()

	status.add_theme_color_override("font_color", Color("#44bb66"))
	status.text = "✓  Saved"


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
