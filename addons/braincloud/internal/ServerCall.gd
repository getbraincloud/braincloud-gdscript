# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name ServerCall
extends RefCounted

signal response_received(response: Dictionary)

var service: String
var operation: String
var data: Dictionary
var is_end_of_bundle: bool = false

func _init(p_service: String = "", p_operation: String = "", p_data: Dictionary = {}) -> void:
	service = p_service
	operation = p_operation
	data = p_data

func on_success(response: Dictionary) -> void:
	response_received.emit(response)

func on_failure(status_code: int, reason_code: int, status_message: String) -> void:
	var error_response: Dictionary = {
		"status": status_code,
		"reason_code": reason_code,
		"status_message": status_message,
		"severity": "ERROR"
	}
	response_received.emit(error_response)
