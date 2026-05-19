# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name ACL
extends RefCounted

enum Access { NONE = 0, READ_ONLY = 1, READ_WRITE = 2 }

var other: int = Access.NONE

func _init(p_other: int = Access.NONE) -> void:
	other = p_other

static func none() -> Dictionary:
	return {"other": Access.NONE}

static func read_only() -> Dictionary:
	return {"other": Access.READ_ONLY}

static func read_write() -> Dictionary:
	return {"other": Access.READ_WRITE}

func to_dict() -> Dictionary:
	return {"other": other}

class ACLs:
	static var none: Dictionary = {"other": 0}
	static var read_only: Dictionary = {"other": 1}
	static var read_write: Dictionary = {"other": 2}
