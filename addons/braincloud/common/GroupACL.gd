# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name GroupACL
extends RefCounted

enum Access { NONE = 0, READ_ONLY = 1, READ_WRITE = 2 }

var member: int = Access.NONE
var other: int = Access.NONE

func _init(p_member: int = Access.NONE, p_other: int = Access.NONE) -> void:
	member = p_member
	other = p_other

func to_dict() -> Dictionary:
	return {"member": member, "other": other}
