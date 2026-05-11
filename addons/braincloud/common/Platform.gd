# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name Platform
extends RefCounted

const APPLE_MAC := "MAC"
const IOS := "IOS"
const ANDROID := "ANG"
const GOOGLE_PLAY_ANDROID := "ANG"
const WINDOWS := "WINDOWS"
const WINDOWS_PHONE := "WINP"
const XBOX_360 := "XBOX360"
const XBOX_ONE := "XBOXONE"
const PS3 := "PS3"
const PS4 := "PS4"
const PS5 := "PS5"
const WII := "WII"
const LINUX := "LINUX"
const WEB := "WEB"
const UNKNOWN := "UNKNOWN"
const GODOT := "Godot"

static func get_platform_name() -> String:
	match OS.get_name():
		"Windows": return WINDOWS
		"macOS": return APPLE_MAC
		"Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD": return LINUX
		"Android": return ANDROID
		"iOS": return IOS
		"Web": return WEB
		_: return GODOT
