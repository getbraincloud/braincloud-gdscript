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

# Nodes that need to swap when the editor theme changes
var _logo_png:   TextureRect = null  # swaps between dark-bg and light-bg variant
var _warn_label: Label       = null  # brand orange — cannot inherit from theme


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

	# PNG logo — texture swapped by _update_panel_theme between dark-bg and light-bg variants
	_logo_png = TextureRect.new()
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
		# No font_color override — inherits correctly from the editor theme
		var flbl := Label.new()
		flbl.text = fd[0]
		flbl.add_theme_font_size_override("font_size", 11)
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

	_warn_label = Label.new()
	_warn_label.text          = "⚠  braincloud.cfg is gitignored"
	_warn_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_warn_label.add_theme_font_size_override("font_size", 11)
	cvbox.add_child(_warn_label)

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
	if key in ["app_id", "app_secret"]:
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
