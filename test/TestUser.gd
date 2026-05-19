# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name TestUser
extends RefCounted

var name: String = ""
var password: String = ""
var email: String = ""
var profile_id: String = ""

func _init(base_name: String, random_id: String) -> void:
	name = "%s_%s" % [base_name, random_id]
	password = "%s_%s" % [base_name, random_id]
	email = "%s_%s@test.getbraincloud.com" % [base_name.to_lower(), random_id]

static func generate_random_string(length: int) -> String:
	const CHARS := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	var result := ""
	for i in range(length):
		result += CHARS[randi() % CHARS.length()]
	return result
