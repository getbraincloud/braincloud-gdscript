# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudGlobalEntity
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

func create_entity(entity_type: String, indexed_id: String, time_to_live: int, json_entity_acl: Dictionary, json_entity_data: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GLOBAL_ENTITY_SERVICE_ENTITY_TYPE: entity_type,
		OperationParam.GLOBAL_ENTITY_SERVICE_INDEXED_ID: indexed_id,
		OperationParam.GLOBAL_ENTITY_SERVICE_TIME_TO_LIVE: time_to_live,
		OperationParam.GLOBAL_ENTITY_SERVICE_ACL: json_entity_acl,
		OperationParam.GLOBAL_ENTITY_SERVICE_DATA: json_entity_data
	}
	return await _send(ServiceOperation.CREATE, data)

func create_entity_with_indexed_id(entity_type: String, indexed_id: String, time_to_live: int, json_entity_acl: Dictionary, json_entity_data: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GLOBAL_ENTITY_SERVICE_ENTITY_TYPE: entity_type,
		OperationParam.GLOBAL_ENTITY_SERVICE_INDEXED_ID: indexed_id,
		OperationParam.GLOBAL_ENTITY_SERVICE_TIME_TO_LIVE: time_to_live,
		OperationParam.GLOBAL_ENTITY_SERVICE_ACL: json_entity_acl,
		OperationParam.GLOBAL_ENTITY_SERVICE_DATA: json_entity_data
	}
	return await _send(ServiceOperation.CREATE_WITH_INDEXED_ID, data)

func read_entity(entity_id: String) -> Dictionary:
	var data := {
		OperationParam.GLOBAL_ENTITY_SERVICE_ENTITY_ID: entity_id
	}
	return await _send(ServiceOperation.READ, data)

func update_entity(entity_id: String, version: int, json_data: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GLOBAL_ENTITY_SERVICE_ENTITY_ID: entity_id,
		OperationParam.GLOBAL_ENTITY_SERVICE_VERSION: version,
		OperationParam.GLOBAL_ENTITY_SERVICE_DATA: json_data
	}
	return await _send(ServiceOperation.UPDATE, data)

func update_entity_acl(entity_id: String, version: int, acl: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GLOBAL_ENTITY_SERVICE_ENTITY_ID: entity_id,
		OperationParam.GLOBAL_ENTITY_SERVICE_VERSION: version,
		OperationParam.GLOBAL_ENTITY_SERVICE_ACL: acl
	}
	return await _send(ServiceOperation.UPDATE_ACL, data)

func update_entity_time_to_live(entity_id: String, version: int, time_to_live: int) -> Dictionary:
	var data := {
		OperationParam.GLOBAL_ENTITY_SERVICE_ENTITY_ID: entity_id,
		OperationParam.GLOBAL_ENTITY_SERVICE_VERSION: version,
		OperationParam.GLOBAL_ENTITY_SERVICE_TIME_TO_LIVE: time_to_live
	}
	return await _send(ServiceOperation.UPDATE_TIME_TO_LIVE, data)

func delete_entity(entity_id: String, version: int) -> Dictionary:
	var data := {
		OperationParam.GLOBAL_ENTITY_SERVICE_ENTITY_ID: entity_id,
		OperationParam.GLOBAL_ENTITY_SERVICE_VERSION: version
	}
	return await _send(ServiceOperation.DELETE, data)

func get_list(where: Dictionary, order_by: Dictionary, max_return: int) -> Dictionary:
	var data := {
		OperationParam.GLOBAL_ENTITY_SERVICE_WHERE: where,
		OperationParam.GLOBAL_ENTITY_SERVICE_ORDER_BY: order_by,
		OperationParam.GLOBAL_ENTITY_SERVICE_MAX_RETURN: max_return
	}
	return await _send(ServiceOperation.GLOBAL_ENTITY_GET_LIST, data)

func get_list_by_indexed_id(entity_type: String, indexed_id: String, max_return: int) -> Dictionary:
	var data := {
		OperationParam.GLOBAL_ENTITY_SERVICE_ENTITY_TYPE: entity_type,
		OperationParam.GLOBAL_ENTITY_SERVICE_ENTITY_INDEX_ID: indexed_id,
		OperationParam.GLOBAL_ENTITY_SERVICE_MAX_RETURN: max_return
	}
	return await _send(ServiceOperation.GLOBAL_ENTITY_GET_LIST_BY_INDEXED_ID, data)

func get_list_count(where: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GLOBAL_ENTITY_SERVICE_WHERE: where
	}
	return await _send(ServiceOperation.GLOBAL_ENTITY_GET_LIST_COUNT, data)

func get_page(context: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GLOBAL_ENTITY_SERVICE_CONTEXT: context
	}
	return await _send(ServiceOperation.GET_PAGE, data)

func get_page_offset(context: String, page_offset: int) -> Dictionary:
	var data := {
		OperationParam.GLOBAL_ENTITY_SERVICE_CONTEXT: context,
		OperationParam.GLOBAL_ENTITY_SERVICE_PAGE_OFFSET: page_offset
	}
	return await _send(ServiceOperation.GET_PAGE_BY_OFFSET, data)

func make_system_entity(entity_id: String, version: int, acl: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GLOBAL_ENTITY_SERVICE_ENTITY_ID: entity_id,
		OperationParam.GLOBAL_ENTITY_SERVICE_VERSION: version,
		OperationParam.GLOBAL_ENTITY_SERVICE_ACL: acl
	}
	return await _send(ServiceOperation.MAKE_SYSTEM_ENTITY, data)

func update_entity_indexed_id(entity_id: String, indexed_id: String, version: int) -> Dictionary:
	var data := {
		OperationParam.GLOBAL_ENTITY_SERVICE_ENTITY_ID: entity_id,
		OperationParam.GLOBAL_ENTITY_SERVICE_INDEXED_ID: indexed_id,
		OperationParam.GLOBAL_ENTITY_SERVICE_VERSION: version
	}
	return await _send(ServiceOperation.UPDATE_INDEXED_ID, data)

func update_entity_owner_and_acl(entity_id: String, version: int, owner_id: String, acl: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GLOBAL_ENTITY_SERVICE_ENTITY_ID: entity_id,
		OperationParam.GLOBAL_ENTITY_SERVICE_VERSION: version,
		"ownerId": owner_id,
		OperationParam.GLOBAL_ENTITY_SERVICE_ACL: acl
	}
	return await _send(ServiceOperation.UPDATE_ENTITY_OWNER_AND_ACL, data)

func increment_global_entity_data(entity_id: String, json_data: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GLOBAL_ENTITY_SERVICE_ENTITY_ID: entity_id,
		OperationParam.GLOBAL_ENTITY_SERVICE_DATA: json_data
	}
	return await _send(ServiceOperation.INCREMENT_GLOBAL_ENTITY_DATA, data)

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.GLOBAL_ENTITY, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
