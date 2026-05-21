# Copyright 2026 bitHeads, Inc. All Rights Reserved.
@tool
extends EditorPlugin

const _AUTOLOAD_NAME := "BrainCloud"
const _WRAPPER_PATH := "res://addons/braincloud/BrainCloudWrapper.gd"

const _SETTINGS: Array[Dictionary] = [
	{"name": "braincloud/config/server_url",    "type": TYPE_STRING, "default": "https://api.braincloudservers.com/dispatcherv2"},
	{"name": "braincloud/config/app_id",        "type": TYPE_STRING, "default": ""},
	{"name": "braincloud/config/app_secret",    "type": TYPE_STRING, "default": ""},
	{"name": "braincloud/config/app_version",   "type": TYPE_STRING, "default": "1.0.0"},
	{"name": "braincloud/debug/enable_logging", "type": TYPE_BOOL,   "default": false},
]

func _enter_tree() -> void:
	_register_project_settings()
	if not ProjectSettings.has_setting("autoload/" + _AUTOLOAD_NAME):
		add_autoload_singleton(_AUTOLOAD_NAME, _WRAPPER_PATH)
	ProjectSettings.save()

func _exit_tree() -> void:
	if ProjectSettings.has_setting("autoload/" + _AUTOLOAD_NAME):
		remove_autoload_singleton(_AUTOLOAD_NAME)

func _register_project_settings() -> void:
	for entry in _SETTINGS:
		if not ProjectSettings.has_setting(entry["name"]):
			ProjectSettings.set_setting(entry["name"], entry["default"])
		ProjectSettings.set_initial_value(entry["name"], entry["default"])
		ProjectSettings.add_property_info({"name": entry["name"], "type": entry["type"]})
