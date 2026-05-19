# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudGlobalApp
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

func read_properties() -> Dictionary:
	return await _send(ServiceOperation.READ_PROPERTIES, {})

func read_selected_properties(property_names: Array) -> Dictionary:
	var data := {
		"propertyNames": property_names
	}
	return await _send("READ_SELECTED_PROPERTIES", data)

func read_properties_in_categories(categories: Array) -> Dictionary:
	var data := {
		"categories": categories
	}
	return await _send("READ_PROPERTIES_IN_CATEGORIES", data)

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.GLOBAL_APP, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
