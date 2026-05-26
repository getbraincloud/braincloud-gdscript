# Copyright 2026 bitHeads, Inc. All Rights Reserved.
@tool
extends EditorPlugin

const _AUTOLOAD_NAME := "brainCloud"
const _WRAPPER_PATH  := "res://addons/braincloud/BrainCloudWrapper.gd"
const _MENU_ITEM     := "brainCloud"

# Credentials are stored here — add this path to .gitignore
const _CREDS_PATH    := "res://addons/braincloud/braincloud.cfg"

# ── Brand colours ──────────────────────────────────────────────────────────────
const _BC_BLUE   := Color("#29a8e0")
const _BC_DARK   := Color("#0f1923")
const _BC_PANEL  := Color("#141e2b")
const _BC_WARN   := Color("#e8c93a")
const _BC_MUTED  := Color(0.52, 0.60, 0.68)

const _LOGO_PATH := "res://addons/braincloud/braincloud_logo.png"

# Only non-sensitive settings live in project.godot
const _SETTINGS := [
	{"name": "braincloud/config/server_url",    "type": TYPE_STRING, "default": "https://api.braincloudservers.com/dispatcherv2"},
	{"name": "braincloud/config/app_version",   "type": TYPE_STRING, "default": "1.0.0"},
	{"name": "braincloud/debug/enable_logging", "type": TYPE_BOOL,   "default": false},
]

const _LINKS := [
	{"label": "Portal",        "url": "https://portal.braincloudservers.com/"},
	{"label": "API Reference", "url": "https://getbraincloud.com/apidocs/apiref/"},
	{"label": "Docs",          "url": "https://getbraincloud.com/apidocs/"},
	{"label": "GDScript SDK",  "url": "https://github.com/getbraincloud/braincloud-gdscript"},
]

var _panel_control: Control = null


func _enter_tree() -> void:
	_register_project_settings()
	if not ProjectSettings.has_setting("autoload/" + _AUTOLOAD_NAME):
		add_autoload_singleton(_AUTOLOAD_NAME, _WRAPPER_PATH)
	ProjectSettings.save()
	_panel_control = _build_panel()
	_panel_control.name = "brainCloud"
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_UL, _panel_control)
	add_tool_menu_item(_MENU_ITEM, _focus_panel)


func _exit_tree() -> void:
	remove_tool_menu_item(_MENU_ITEM)
	if ProjectSettings.has_setting("autoload/" + _AUTOLOAD_NAME):
		remove_autoload_singleton(_AUTOLOAD_NAME)
	if is_instance_valid(_panel_control):
		remove_control_from_docks(_panel_control)
		_panel_control.queue_free()
	_panel_control = null


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

	# ── Header: logo + versions ───────────────────────────────────────────
	var header := PanelContainer.new()
	var hs := StyleBoxFlat.new()
	hs.bg_color              = _BC_DARK
	hs.content_margin_left   = 12
	hs.content_margin_right  = 12
	hs.content_margin_top    = 10
	hs.content_margin_bottom = 10
	header.add_theme_stylebox_override("panel", hs)
	root.add_child(header)

	var hvbox := VBoxContainer.new()
	hvbox.add_theme_constant_override("separation", 4)
	hvbox.alignment = BoxContainer.ALIGNMENT_CENTER
	header.add_child(hvbox)

	var logo_tex := _try_load_logo()
	if logo_tex:
		var logo := TextureRect.new()
		logo.texture               = logo_tex
		logo.expand_mode           = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		logo.stretch_mode          = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		logo.custom_minimum_size   = Vector2(0, 28)
		logo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hvbox.add_child(logo)
	else:
		var nr := HBoxContainer.new()
		nr.alignment = BoxContainer.ALIGNMENT_CENTER
		nr.add_theme_constant_override("separation", 2)
		_add_label(nr, "brain", 16, Color.WHITE)
		_add_label(nr, "Cloud", 16, _BC_BLUE)
		hvbox.add_child(nr)

	var ver_row := HBoxContainer.new()
	ver_row.alignment = BoxContainer.ALIGNMENT_CENTER
	ver_row.add_theme_constant_override("separation", 6)
	hvbox.add_child(ver_row)
	_add_label(ver_row, "SDK " + _get_sdk_version(), 9, _BC_MUTED)
	_add_label(ver_row, "·", 9, _BC_MUTED)
	_add_label(ver_row, "Plugin " + _get_plugin_version(), 9, _BC_MUTED)

	root.add_child(_horiz_sep())

	# ── Credentials ───────────────────────────────────────────────────────
	var cred_margin := MarginContainer.new()
	for s in ["left", "right", "top", "bottom"]:
		cred_margin.add_theme_constant_override("margin_" + s, 8)
	root.add_child(cred_margin)

	var cvbox := VBoxContainer.new()
	cvbox.add_theme_constant_override("separation", 4)
	cred_margin.add_child(cvbox)

	cvbox.add_child(_section_lbl("App Credentials"))

	var field_defs := [
		["App ID",      "app_id",      false],
		["App Secret",  "app_secret",  true ],
		["Server URL",  "server_url",  false],
		["App Version", "app_version", false],
	]
	var fields: Dictionary = {}

	for fd in field_defs:
		var flbl := Label.new()
		flbl.text = fd[0]
		flbl.add_theme_font_size_override("font_size", 11)
		flbl.add_theme_color_override("font_color", _BC_MUTED)
		cvbox.add_child(flbl)

		var edit_row := HBoxContainer.new()
		edit_row.add_theme_constant_override("separation", 4)
		cvbox.add_child(edit_row)

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
			eye.toggle_mode         = true   # required — toggled signal won't fire without this
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

	var log_check := CheckBox.new()
	log_check.text                  = "Debug Logging"
	log_check.button_pressed        = bool(ProjectSettings.get_setting(
		"braincloud/debug/enable_logging", false))
	log_check.add_theme_font_size_override("font_size", 11)
	log_check.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cvbox.add_child(log_check)

	var status := Label.new()
	status.text                  = ""
	status.horizontal_alignment  = HORIZONTAL_ALIGNMENT_CENTER
	status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status.add_theme_font_size_override("font_size", 11)
	status.autowrap_mode         = TextServer.AUTOWRAP_WORD_SMART
	cvbox.add_child(status)

	var save_btn := Button.new()
	save_btn.text                  = "Save"
	save_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_btn.custom_minimum_size   = Vector2(0, 28)
	_style_primary(save_btn)
	save_btn.pressed.connect(_on_save.bind(fields, log_check, status))
	cvbox.add_child(save_btn)

	var warn := Label.new()
	warn.text          = "⚠  braincloud.cfg is gitignored"
	warn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	warn.add_theme_font_size_override("font_size", 10)
	warn.add_theme_color_override("font_color", _BC_WARN)
	cvbox.add_child(warn)

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

	return scroll


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


func _add_label(parent: Node, text: String, size: int, color: Color) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", size)
	lbl.add_theme_color_override("font_color", color)
	parent.add_child(lbl)
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
	btn.custom_minimum_size   = Vector2(0, 22)
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
	btn.add_theme_color_override("font_color",         _BC_BLUE)
	btn.add_theme_color_override("font_hover_color",   _BC_BLUE.lightened(0.15))
	btn.add_theme_color_override("font_pressed_color", _BC_BLUE.darkened(0.1))
	btn.pressed.connect(func(): OS.shell_open(url))
	return btn


func _try_load_logo() -> Texture2D:
	if ResourceLoader.exists(_LOGO_PATH):
		return load(_LOGO_PATH) as Texture2D
	return null


func _get_plugin_version() -> String:
	var cfg := ConfigFile.new()
	if cfg.load("res://addons/braincloud/plugin.cfg") == OK:
		return cfg.get_value("plugin", "version", "?")
	return "?"


func _get_sdk_version() -> String:
	var f := FileAccess.open("res://addons/braincloud/BrainCloudClient.gd", FileAccess.READ)
	if not f:
		return _get_plugin_version()
	while not f.eof_reached():
		var line := f.get_line()
		if "BRAINCLOUD_VERSION" in line and ":=" in line:
			var parts := line.split('"')
			if parts.size() >= 2:
				return parts[1]
	return _get_plugin_version()


# ── Data helpers ───────────────────────────────────────────────────────────────

func _read_setting(key: String) -> String:
	# Credentials come from the separate gitignored file
	if key in ["app_id", "app_secret"]:
		var cfg := ConfigFile.new()
		if cfg.load(_CREDS_PATH) == OK:
			var v = str(cfg.get_value("credentials", key, ""))
			if not v.is_empty():
				return v
		return ""
	# Non-sensitive settings from ProjectSettings
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
		status.modulate = Color(1.0, 0.45, 0.45)
		status.text     = "App ID, Secret and URL are required."
		return

	# Credentials → separate gitignored file (never project.godot)
	var creds := ConfigFile.new()
	creds.set_value("credentials", "app_id",     app_id)
	creds.set_value("credentials", "app_secret",  app_secret)
	creds.save(_CREDS_PATH)
	_ensure_gitignore()

	# Non-sensitive settings → ProjectSettings
	ProjectSettings.set_setting("braincloud/config/server_url",    server_url)
	ProjectSettings.set_setting("braincloud/config/app_version",   app_ver if not app_ver.is_empty() else "1.0.0")
	ProjectSettings.set_setting("braincloud/debug/enable_logging", log_check.button_pressed)
	ProjectSettings.save()

	status.modulate = Color(0.45, 1.0, 0.55)
	status.text     = "✓  Saved"


func _ensure_gitignore() -> void:
	var path  := "res://.gitignore"
	var entry := "addons/braincloud/braincloud.cfg"
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
