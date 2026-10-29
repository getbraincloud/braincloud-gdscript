# Copyright 2026 bitHeads, Inc. All Rights Reserved.
@tool
class_name BrainCloudExportPlugin
extends EditorExportPlugin

## Drops the native library out of Web exports and adds the Web app config in its place.
##
## BrainCloudNative is a GDExtension with macOS/Windows/Linux/iOS/Android builds. Web has no
## wasm32 build and does not need one, because BrainCloudWrapper.init() falls back to
## _init_from_project_settings() there, which reads the config added below.
##
## Left in, a Web export carries ~21 MB of desktop binaries that no browser can load.
## every player downloads a macOS .dylib and a Linux .so for nothing and Godot logs
## "No wasm32 library found for GDExtension" while exporting.
##
## Doing this from an export plugin rather than telling each project to add an
## exclude_filter means it just works: nothing to configure per project, and nothing to
## forget when someone adds a new export preset.

const _GDEXTENSION_PATH := "res://addons/braincloud/braincloud_native.gdextension"
const _BIN_DIR          := "res://addons/braincloud/bin/"
const _CREDS_PATH       := "res://addons/braincloud/braincloud.cfg"
const _WEB_CONFIG_PATH  := "res://addons/braincloud/braincloud_web.cfg"

func _get_name() -> String:
	return "BrainCloudExportPlugin"

# Native platforms get braincloud.cfg; Web gets the web config,
# built from braincloud.cfg at export time so it never lives in project.godot.
func _export_begin(features: PackedStringArray, _is_debug: bool, _path: String, _flags: int) -> void:
	if _has_native(features):
		# A plain .cfg isn't a resource, so desktop exports silently drop it unless added here.
		if FileAccess.file_exists(_CREDS_PATH):
			add_file(_CREDS_PATH, FileAccess.get_file_as_bytes(_CREDS_PATH), false)
		else:
			push_warning("brainCloud: no app saved in the brainCloud dock, export has no app config.")
		return
	if not ClassDB.class_exists("BrainCloudNative"):
		push_warning("brainCloud: BrainCloudNative unavailable, export has no app config.")
		return
	var resolved: Dictionary = ClassDB.instantiate("BrainCloudNative").resolve_config_sync(_CREDS_PATH)
	var value := str(resolved.get("secret", ""))
	if value.is_empty():
		push_warning("brainCloud: no app saved in the brainCloud dock, export has no app config.")
		return
	var encoded := BrainCloudWebConfig.encode(value)
	value = ""
	var web := ConfigFile.new()
	web.set_value("app", "app_id", str(resolved.get("app_id", "")))
	web.set_value("app", "a", encoded["a"])
	web.set_value("app", "b", encoded["b"])
	add_file(_WEB_CONFIG_PATH, web.encode_to_text().to_utf8_buffer(), false)

# Called once per file being exported. `features` carries the target's feature tags, so
# that's how we know which platform this export is for.
func _export_file(path: String, _type: String, features: PackedStringArray) -> void:
	if _has_native(features):
		return
	if path == _GDEXTENSION_PATH or path.begins_with(_BIN_DIR):
		# skip() drops the current file from this export only. Desktop exports are
		# untouched and still get the library.
		skip()

# BrainCloudNative ships for every platform except Web.
func _has_native(features: PackedStringArray) -> bool:
	return not features.has("web")
