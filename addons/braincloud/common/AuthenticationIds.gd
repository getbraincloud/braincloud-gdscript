# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name AuthenticationIds
extends RefCounted

var external_id: String = ""
var authentication_token: String = ""
var authentication_type: String = ""

func _init(p_external_id: String = "", p_auth_token: String = "", p_auth_type: String = "") -> void:
	external_id = p_external_id
	authentication_token = p_auth_token
	authentication_type = p_auth_type
