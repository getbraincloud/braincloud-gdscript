# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudCustomEntity
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

func create_entity(entity_type: String, json_entity_data: Dictionary, json_entity_acl: Dictionary, time_to_live: int, is_owned: bool) -> Dictionary:
	var data := {
		OperationParam.CUSTOM_ENTITY_TYPE_NAME: entity_type,
		OperationParam.CUSTOM_ENTITY_DATA: json_entity_data,
		OperationParam.CUSTOM_ENTITY_ACL: json_entity_acl,
		OperationParam.CUSTOM_ENTITY_TIME_TO_LIVE: time_to_live,
		OperationParam.CUSTOM_ENTITY_IS_OWNED: is_owned
	}
	return await _send(ServiceOperation.CUSTOM_ENTITY_CREATE, data)

func read_singleton(entity_type: String) -> Dictionary:
	var data := {
		OperationParam.CUSTOM_ENTITY_TYPE_NAME: entity_type
	}
	return await _send(ServiceOperation.CUSTOM_ENTITY_READ_SINGLETON, data)

func update_singleton(entity_type: String, version: int, json_entity_data: Dictionary, json_entity_acl: Dictionary, time_to_live: int) -> Dictionary:
	var data := {
		OperationParam.CUSTOM_ENTITY_TYPE_NAME: entity_type,
		OperationParam.CUSTOM_ENTITY_VERSION: version,
		OperationParam.CUSTOM_ENTITY_DATA: json_entity_data,
		OperationParam.CUSTOM_ENTITY_ACL: json_entity_acl,
		OperationParam.CUSTOM_ENTITY_TIME_TO_LIVE: time_to_live
	}
	return await _send(ServiceOperation.CUSTOM_ENTITY_UPDATE_SINGLETON, data)

func delete_singleton(entity_type: String, version: int) -> Dictionary:
	var data := {
		OperationParam.CUSTOM_ENTITY_TYPE_NAME: entity_type,
		OperationParam.CUSTOM_ENTITY_VERSION: version
	}
	return await _send(ServiceOperation.CUSTOM_ENTITY_DELETE_SINGLETON, data)

func get_entity_page(entity_type: String, context: Dictionary) -> Dictionary:
	var data := {
		OperationParam.CUSTOM_ENTITY_TYPE_NAME: entity_type,
		OperationParam.CUSTOM_ENTITY_CONTEXT: context
	}
	return await _send(ServiceOperation.CUSTOM_ENTITY_GET_ENTITY_PAGE, data)

func get_entity_page_offset(entity_type: String, context: String, page_offset: int) -> Dictionary:
	var data := {
		OperationParam.CUSTOM_ENTITY_TYPE_NAME: entity_type,
		OperationParam.CUSTOM_ENTITY_CONTEXT: context,
		OperationParam.CUSTOM_ENTITY_PAGE_OFFSET: page_offset
	}
	return await _send(ServiceOperation.CUSTOM_ENTITY_GET_ENTITY_PAGE_OFFSET, data)

func read_entity(entity_type: String, entity_id: String) -> Dictionary:
	var data := {
		OperationParam.CUSTOM_ENTITY_TYPE_NAME: entity_type,
		OperationParam.CUSTOM_ENTITY_ENTITY_ID: entity_id
	}
	return await _send(ServiceOperation.CUSTOM_ENTITY_READ_ENTITY, data)

func update_entity(entity_type: String, entity_id: String, version: int, json_entity_data: Dictionary, json_entity_acl: Dictionary, time_to_live: int) -> Dictionary:
	var data := {
		OperationParam.CUSTOM_ENTITY_TYPE_NAME: entity_type,
		OperationParam.CUSTOM_ENTITY_ENTITY_ID: entity_id,
		OperationParam.CUSTOM_ENTITY_VERSION: version,
		OperationParam.CUSTOM_ENTITY_DATA: json_entity_data,
		OperationParam.CUSTOM_ENTITY_ACL: json_entity_acl,
		OperationParam.CUSTOM_ENTITY_TIME_TO_LIVE: time_to_live
	}
	return await _send(ServiceOperation.CUSTOM_ENTITY_UPDATE_ENTITY, data)

func update_entity_fields(entity_type: String, entity_id: String, version: int, fields_json: Dictionary) -> Dictionary:
	var data := {
		OperationParam.CUSTOM_ENTITY_TYPE_NAME: entity_type,
		OperationParam.CUSTOM_ENTITY_ENTITY_ID: entity_id,
		OperationParam.CUSTOM_ENTITY_VERSION: version,
		OperationParam.CUSTOM_ENTITY_FIELDS_DATA: fields_json
	}
	return await _send(ServiceOperation.CUSTOM_ENTITY_UPDATE_ENTITY_FIELDS, data)

func increment_entity_data(entity_type: String, entity_id: String, fields_json: Dictionary) -> Dictionary:
	var data := {
		OperationParam.CUSTOM_ENTITY_TYPE_NAME: entity_type,
		OperationParam.CUSTOM_ENTITY_ENTITY_ID: entity_id,
		OperationParam.CUSTOM_ENTITY_INCREMENT_DATA: fields_json
	}
	return await _send(ServiceOperation.CUSTOM_ENTITY_INCREMENT_ENTITY_DATA, data)

func delete_entity(entity_type: String, entity_id: String, version: int) -> Dictionary:
	var data := {
		OperationParam.CUSTOM_ENTITY_TYPE_NAME: entity_type,
		OperationParam.CUSTOM_ENTITY_ENTITY_ID: entity_id,
		OperationParam.CUSTOM_ENTITY_VERSION: version
	}
	return await _send(ServiceOperation.CUSTOM_ENTITY_DELETE_ENTITY, data)

func delete_entities(entity_type: String, json_delete_criteria: Dictionary) -> Dictionary:
	var data := {
		OperationParam.CUSTOM_ENTITY_TYPE_NAME: entity_type,
		"deleteCriteria": json_delete_criteria
	}
	return await _send(ServiceOperation.CUSTOM_ENTITY_DELETE_ENTITIES, data)

func count_entities_where(entity_type: String, where_json: Dictionary) -> Dictionary:
	var data := {
		OperationParam.CUSTOM_ENTITY_TYPE_NAME: entity_type,
		"whereJson": where_json
	}
	return await _send(ServiceOperation.CUSTOM_ENTITY_COUNT_ENTITIES_WHERE, data)

func get_random_entities_matching(entity_type: String, where_json: Dictionary, max_return: int) -> Dictionary:
	var data := {
		OperationParam.CUSTOM_ENTITY_TYPE_NAME: entity_type,
		"where": where_json,
		OperationParam.GLOBAL_ENTITY_SERVICE_MAX_RETURN: max_return
	}
	return await _send(ServiceOperation.CUSTOM_ENTITY_GET_RANDOM_ENTITIES_MATCHING, data)

func update_entity_owner_and_acl(entity_type: String, entity_id: String, version: int, owner_id: String, acl: Dictionary) -> Dictionary:
	var data := {
		OperationParam.CUSTOM_ENTITY_TYPE_NAME: entity_type,
		OperationParam.CUSTOM_ENTITY_ENTITY_ID: entity_id,
		OperationParam.CUSTOM_ENTITY_VERSION: version,
		OperationParam.CUSTOM_ENTITY_NEW_OWNER_ID: owner_id,
		OperationParam.CUSTOM_ENTITY_ACL: acl
	}
	return await _send(ServiceOperation.CUSTOM_ENTITY_UPDATE_ENTITY_OWNER_AND_ACL, data)

func make_system_entity(entity_type: String, entity_id: String, version: int, acl: Dictionary) -> Dictionary:
	var data := {
		OperationParam.CUSTOM_ENTITY_TYPE_NAME: entity_type,
		OperationParam.CUSTOM_ENTITY_ENTITY_ID: entity_id,
		OperationParam.CUSTOM_ENTITY_VERSION: version,
		OperationParam.CUSTOM_ENTITY_ACL: acl
	}
	return await _send(ServiceOperation.CUSTOM_ENTITY_MAKE_SYSTEM_ENTITY, data)

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.CUSTOM_ENTITY, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
