# Copyright 2026 bitHeads, Inc. All Rights Reserved.
@tool
class_name BrainCloudExportPlugin
extends EditorExportPlugin

## Drops the native library out of Web exports.
##
## BrainCloudNative is a GDExtension with macOS/Windows/Linux builds only — Web has no
## wasm32 build and does not need one, because BrainCloudWrapper.init() falls back to
## _init_from_project_settings() there (the braincloud/config/*.web settings).
##
## Left in, a Web export carries ~21 MB of desktop binaries that no browser can load —
## every player downloads a macOS .dylib and a Linux .so for nothing — and Godot logs
## "No wasm32 library found for GDExtension" while exporting.
##
## Doing this from an export plugin rather than telling each project to add an
## exclude_filter means it just works: nothing to configure per project, and nothing to
## forget when someone adds a new export preset.

const _GDEXTENSION_PATH := "res://addons/braincloud/braincloud_native.gdextension"
const _BIN_DIR          := "res://addons/braincloud/bin/"

func _get_name() -> String:
	return "BrainCloudExportPlugin"

# Called once per file being exported. `features` carries the target's feature tags, so
# "web" is how we know which platform this export is for.
func _export_file(path: String, _type: String, features: PackedStringArray) -> void:
	if not features.has("web"):
		return
	if path == _GDEXTENSION_PATH or path.begins_with(_BIN_DIR):
		# skip() drops the current file from this export only. Desktop exports are
		# untouched and still get the library.
		skip()
