# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudEntity
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

func create_entity(entity_type: String, json_entity_data: Dictionary, json_entity_acl: Dictionary) -> Dictionary:
	var data := {
		OperationParam.ENTITY_SERVICE_ENTITY_TYPE: entity_type,
		OperationParam.ENTITY_SERVICE_ENTITY_DATA: json_entity_data,
		OperationParam.ENTITY_SERVICE_ACL: json_entity_acl
	}
	return await _send(ServiceOperation.CREATE, data)

func create_entity_with_indexed_id(entity_type: String, indexed_id: String, json_entity_data: Dictionary, json_entity_acl: Dictionary) -> Dictionary:
	var data := {
		OperationParam.ENTITY_SERVICE_ENTITY_TYPE: entity_type,
		OperationParam.ENTITY_SERVICE_ENTITY_DATA: json_entity_data,
		OperationParam.ENTITY_SERVICE_ACL: json_entity_acl,
		"entityIndexedId": indexed_id
	}
	return await _send(ServiceOperation.CREATE_WITH_INDEXED_ID, data)

func update_entity(entity_id: String, entity_type: String, json_entity_data: Dictionary, json_entity_acl: Dictionary, version: int) -> Dictionary:
	var data := {
		OperationParam.ENTITY_SERVICE_ENTITY_ID: entity_id,
		OperationParam.ENTITY_SERVICE_ENTITY_TYPE: entity_type,
		OperationParam.ENTITY_SERVICE_ENTITY_DATA: json_entity_data,
		OperationParam.ENTITY_SERVICE_ACL: json_entity_acl,
		OperationParam.ENTITY_SERVICE_ENTITY_VERSION: version
	}
	return await _send(ServiceOperation.UPDATE, data)

func update_shared_entity(entity_id: String, target_profile_id: String, entity_type: String, json_entity_data: Dictionary, version: int) -> Dictionary:
	var data := {
		OperationParam.ENTITY_SERVICE_ENTITY_ID: entity_id,
		OperationParam.ENTITY_SERVICE_FRIEND_ID: target_profile_id,
		OperationParam.ENTITY_SERVICE_ENTITY_TYPE: entity_type,
		OperationParam.ENTITY_SERVICE_ENTITY_DATA: json_entity_data,
		OperationParam.ENTITY_SERVICE_ENTITY_VERSION: version
	}
	return await _send(ServiceOperation.UPDATE_SHARED, data)

func delete_entity(entity_id: String, version: int) -> Dictionary:
	var data := {
		OperationParam.ENTITY_SERVICE_ENTITY_ID: entity_id,
		OperationParam.ENTITY_SERVICE_ENTITY_VERSION: version
	}
	return await _send(ServiceOperation.DELETE, data)

func delete_singleton(entity_type: String, version: int) -> Dictionary:
	var data := {
		OperationParam.ENTITY_SERVICE_ENTITY_TYPE: entity_type,
		OperationParam.ENTITY_SERVICE_ENTITY_VERSION: version
	}
	return await _send(ServiceOperation.DELETE_SINGLETON, data)

func get_entity(entity_id: String) -> Dictionary:
	var data := {OperationParam.ENTITY_SERVICE_ENTITY_ID: entity_id}
	return await _send(ServiceOperation.READ, data)

func get_singleton(entity_type: String) -> Dictionary:
	var data := {OperationParam.ENTITY_SERVICE_ENTITY_TYPE: entity_type}
	return await _send(ServiceOperation.READ_SINGLETON, data)

func get_entities_by_type(entity_type: String) -> Dictionary:
	var data := {OperationParam.ENTITY_SERVICE_ENTITY_TYPE: entity_type}
	return await _send(ServiceOperation.READ_BY_TYPE, data)

func get_shared_entity(profile_id: String, entity_id: String) -> Dictionary:
	var data := {
		OperationParam.ENTITY_SERVICE_FRIEND_ID: profile_id,
		OperationParam.ENTITY_SERVICE_ENTITY_ID: entity_id
	}
	return await _send(ServiceOperation.READ_SHARED_ENTITY, data)

func get_shared_entities_for_profile_id(profile_id: String) -> Dictionary:
	var data := {"targetPlayerId": profile_id}
	return await _send(ServiceOperation.READ_SHARED, data)

func get_page(context: Dictionary) -> Dictionary:
	var data := {OperationParam.GLOBAL_ENTITY_SERVICE_CONTEXT: context}
	return await _send(ServiceOperation.GET_PAGE, data)

func get_page_offset(context: String, page_offset: int) -> Dictionary:
	var data := {
		OperationParam.GLOBAL_ENTITY_SERVICE_CONTEXT: context,
		OperationParam.GLOBAL_ENTITY_SERVICE_PAGE_OFFSET: page_offset
	}
	return await _send(ServiceOperation.GET_PAGE_BY_OFFSET, data)

func update_singleton(entity_type: String, json_entity_data: Dictionary, json_entity_acl: Dictionary, version: int) -> Dictionary:
	var data := {
		OperationParam.ENTITY_SERVICE_ENTITY_TYPE: entity_type,
		OperationParam.ENTITY_SERVICE_ENTITY_DATA: json_entity_data,
		OperationParam.ENTITY_SERVICE_ACL: json_entity_acl,
		OperationParam.ENTITY_SERVICE_ENTITY_VERSION: version
	}
	return await _send(ServiceOperation.UPDATE_SINGLETON, data)

func update_entity_indexed_id(entity_id: String, entity_indexed_id: String, version: int) -> Dictionary:
	var data := {
		OperationParam.ENTITY_SERVICE_ENTITY_ID: entity_id,
		"entityIndexedId": entity_indexed_id,
		OperationParam.ENTITY_SERVICE_ENTITY_VERSION: version
	}
	return await _send(ServiceOperation.UPDATE_ENTITY_INDEXED_ID, data)

func update_entity_owner_and_acl(entity_id: String, version: int, profile_id: String, acl: Dictionary) -> Dictionary:
	var data := {
		OperationParam.ENTITY_SERVICE_ENTITY_ID: entity_id,
		OperationParam.ENTITY_SERVICE_ENTITY_VERSION: version,
		"ownerId": profile_id,
		OperationParam.ENTITY_SERVICE_ACL: acl
	}
	return await _send(ServiceOperation.UPDATE_ENTITY_OWNER_AND_ACL, data)

func get_list(where_json: Dictionary, order_by_json: Dictionary, max_return: int) -> Dictionary:
	var data := {
		OperationParam.GLOBAL_ENTITY_SERVICE_WHERE: where_json,
		OperationParam.GLOBAL_ENTITY_SERVICE_ORDER_BY: order_by_json,
		OperationParam.GLOBAL_ENTITY_SERVICE_MAX_RETURN: max_return
	}
	return await _send(ServiceOperation.GET_LIST, data)

func get_list_count(where_json: Dictionary) -> Dictionary:
	var data := {OperationParam.GLOBAL_ENTITY_SERVICE_WHERE: where_json}
	return await _send(ServiceOperation.GET_LIST_COUNT, data)

func get_shared_entities_list_for_profile_id(target_profile_id: String, where_json: Dictionary, order_by_json: Dictionary, max_return: int) -> Dictionary:
	var data := {
		"targetPlayerId": target_profile_id,
		OperationParam.GLOBAL_ENTITY_SERVICE_WHERE: where_json,
		OperationParam.GLOBAL_ENTITY_SERVICE_ORDER_BY: order_by_json,
		OperationParam.GLOBAL_ENTITY_SERVICE_MAX_RETURN: max_return
	}
	return await _send(ServiceOperation.READ_SHARED_ENTITIES_LIST, data)

func increment_user_entity_data(entity_id: String, json_data: Dictionary) -> Dictionary:
	var data := {
		OperationParam.ENTITY_SERVICE_ENTITY_ID: entity_id,
		OperationParam.ENTITY_SERVICE_ENTITY_DATA: json_data
	}
	return await _send(ServiceOperation.INCREMENT_USER_ENTITY_DATA, data)

func increment_shared_user_entity_data(entity_id: String, target_profile_id: String, json_data: Dictionary) -> Dictionary:
	var data := {
		OperationParam.ENTITY_SERVICE_ENTITY_ID: entity_id,
		OperationParam.ENTITY_SERVICE_FRIEND_ID: target_profile_id,
		OperationParam.ENTITY_SERVICE_ENTITY_DATA: json_data
	}
	return await _send(ServiceOperation.INCREMENT_SHARED_USER_ENTITY_DATA, data)

func make_system_entity(entity_id: String, version: int, acl: Dictionary) -> Dictionary:
	var data := {
		OperationParam.ENTITY_SERVICE_ENTITY_ID: entity_id,
		OperationParam.ENTITY_SERVICE_ENTITY_VERSION: version,
		OperationParam.ENTITY_SERVICE_ACL: acl
	}
	return await _send(ServiceOperation.MAKE_SYSTEM_ENTITY, data)

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.ENTITY, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
