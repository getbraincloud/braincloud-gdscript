# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudGlobalEntity
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

## Creates a new global entity on the server.
##
## Service Name - GlobalEntity[br]
## Service Operation - Create
##
## @param entity_type The entity type as defined by the user
## @param indexed_id A secondary ID that will be indexed
## @param time_to_live Sets expiry time for entity in milliseconds if > 0
## @param json_entity_acl The entity's access control list
## @param json_entity_data The entity's data as a Dictionary
func create_entity(entity_type: String, indexed_id: String, time_to_live: int, json_entity_acl: Dictionary, json_entity_data: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GLOBAL_ENTITY_SERVICE_ENTITY_TYPE: entity_type,
		OperationParam.GLOBAL_ENTITY_SERVICE_INDEXED_ID: indexed_id,
		OperationParam.GLOBAL_ENTITY_SERVICE_TIME_TO_LIVE: time_to_live,
		OperationParam.GLOBAL_ENTITY_SERVICE_ACL: json_entity_acl,
		OperationParam.GLOBAL_ENTITY_SERVICE_DATA: json_entity_data
	}
	return await _send(ServiceOperation.CREATE, data)

## Creates a new global entity on the server with an indexed id.
##
## Service Name - GlobalEntity[br]
## Service Operation - CreateWithIndexedId
##
## @param entity_type The entity type as defined by the user
## @param indexed_id A secondary ID that will be indexed
## @param time_to_live Sets expiry time for entity in milliseconds if > 0
## @param json_entity_acl The entity's access control list
## @param json_entity_data The entity's data as a Dictionary
func create_entity_with_indexed_id(entity_type: String, indexed_id: String, time_to_live: int, json_entity_acl: Dictionary, json_entity_data: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GLOBAL_ENTITY_SERVICE_ENTITY_TYPE: entity_type,
		OperationParam.GLOBAL_ENTITY_SERVICE_INDEXED_ID: indexed_id,
		OperationParam.GLOBAL_ENTITY_SERVICE_TIME_TO_LIVE: time_to_live,
		OperationParam.GLOBAL_ENTITY_SERVICE_ACL: json_entity_acl,
		OperationParam.GLOBAL_ENTITY_SERVICE_DATA: json_entity_data
	}
	return await _send(ServiceOperation.CREATE_WITH_INDEXED_ID, data)

## Reads an existing global entity from the server.
##
## Service Name - GlobalEntity[br]
## Service Operation - Read
##
## @param entity_id The entity ID
func read_entity(entity_id: String) -> Dictionary:
	var data := {
		OperationParam.GLOBAL_ENTITY_SERVICE_ENTITY_ID: entity_id
	}
	return await _send(ServiceOperation.READ, data)

## Updates an existing global entity on the server.
##
## Service Name - GlobalEntity[br]
## Service Operation - Update
##
## @param entity_id The entity ID
## @param version The version of the entity to update
## @param json_data The entity's data as a Dictionary
func update_entity(entity_id: String, version: int, json_data: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GLOBAL_ENTITY_SERVICE_ENTITY_ID: entity_id,
		OperationParam.GLOBAL_ENTITY_SERVICE_VERSION: version,
		OperationParam.GLOBAL_ENTITY_SERVICE_DATA: json_data
	}
	return await _send(ServiceOperation.UPDATE, data)

## Updates an existing global entity's access control list on the server.
##
## Service Name - GlobalEntity[br]
## Service Operation - UpdateAcl
##
## @param entity_id The entity ID
## @param version The version of the entity to update
## @param acl The entity's access control list
func update_entity_acl(entity_id: String, version: int, acl: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GLOBAL_ENTITY_SERVICE_ENTITY_ID: entity_id,
		OperationParam.GLOBAL_ENTITY_SERVICE_VERSION: version,
		OperationParam.GLOBAL_ENTITY_SERVICE_ACL: acl
	}
	return await _send(ServiceOperation.UPDATE_ACL, data)

## Updates an existing global entity's time to live on the server.
##
## Service Name - GlobalEntity[br]
## Service Operation - UpdateTimeToLive
##
## @param entity_id The entity ID
## @param version The version of the entity to update
## @param time_to_live Sets expiry time for entity in milliseconds if > 0
func update_entity_time_to_live(entity_id: String, version: int, time_to_live: int) -> Dictionary:
	var data := {
		OperationParam.GLOBAL_ENTITY_SERVICE_ENTITY_ID: entity_id,
		OperationParam.GLOBAL_ENTITY_SERVICE_VERSION: version,
		OperationParam.GLOBAL_ENTITY_SERVICE_TIME_TO_LIVE: time_to_live
	}
	return await _send(ServiceOperation.UPDATE_TIME_TO_LIVE, data)

## Deletes an existing global entity on the server.
##
## Service Name - GlobalEntity[br]
## Service Operation - Delete
##
## @param entity_id The entity ID
## @param version The version of the entity to delete
func delete_entity(entity_id: String, version: int) -> Dictionary:
	var data := {
		OperationParam.GLOBAL_ENTITY_SERVICE_ENTITY_ID: entity_id,
		OperationParam.GLOBAL_ENTITY_SERVICE_VERSION: version
	}
	return await _send(ServiceOperation.DELETE, data)

## Gets a list of global entities based on type and/or where clause.
##
## Service Name - GlobalEntity[br]
## Service Operation - GetList
##
## @param where Mongo style query Dictionary
## @param order_by Sort order Dictionary
## @param max_return The maximum number of entities to return
func get_list(where: Dictionary, order_by: Dictionary, max_return: int) -> Dictionary:
	var data := {
		OperationParam.GLOBAL_ENTITY_SERVICE_WHERE: where,
		OperationParam.GLOBAL_ENTITY_SERVICE_ORDER_BY: order_by,
		OperationParam.GLOBAL_ENTITY_SERVICE_MAX_RETURN: max_return
	}
	return await _send(ServiceOperation.GLOBAL_ENTITY_GET_LIST, data)

## Gets a list of global entities based on indexed id.
##
## Service Name - GlobalEntity[br]
## Service Operation - GetListByIndexedId
##
## @param entity_type The entity type
## @param indexed_id The entity indexed id
## @param max_return The maximum number of entities to return
func get_list_by_indexed_id(entity_type: String, indexed_id: String, max_return: int) -> Dictionary:
	var data := {
		OperationParam.GLOBAL_ENTITY_SERVICE_ENTITY_TYPE: entity_type,
		OperationParam.GLOBAL_ENTITY_SERVICE_ENTITY_INDEX_ID: indexed_id,
		OperationParam.GLOBAL_ENTITY_SERVICE_MAX_RETURN: max_return
	}
	return await _send(ServiceOperation.GLOBAL_ENTITY_GET_LIST_BY_INDEXED_ID, data)

## Gets a count of global entities based on the where clause.
##
## Service Name - GlobalEntity[br]
## Service Operation - GetListCount
##
## @param where Mongo style query Dictionary
func get_list_count(where: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GLOBAL_ENTITY_SERVICE_WHERE: where
	}
	return await _send(ServiceOperation.GLOBAL_ENTITY_GET_LIST_COUNT, data)

## Uses a paging system to iterate through global entities.
## After retrieving a page, use get_page_offset to retrieve previous or next pages.
##
## Service Name - GlobalEntity[br]
## Service Operation - GetPage
##
## @param context The json context for the page request
func get_page(context: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GLOBAL_ENTITY_SERVICE_CONTEXT: context
	}
	return await _send(ServiceOperation.GET_PAGE, data)

## Retrieves previous or next pages after calling get_page.
##
## Service Name - GlobalEntity[br]
## Service Operation - GetPageOffset
##
## @param context The context string returned from a previous get_page call
## @param page_offset The positive or negative page offset to fetch
func get_page_offset(context: String, page_offset: int) -> Dictionary:
	var data := {
		OperationParam.GLOBAL_ENTITY_SERVICE_CONTEXT: context,
		OperationParam.GLOBAL_ENTITY_SERVICE_PAGE_OFFSET: page_offset
	}
	return await _send(ServiceOperation.GET_PAGE_BY_OFFSET, data)

## Clears the owner id of an existing entity and sets the ACL on the server.
##
## Service Name - GlobalEntity[br]
## Service Operation - MAKE_SYSTEM_ENTITY
##
## @param entity_id The entity ID
## @param version The version of the entity to update
## @param acl The entity's access control list
func make_system_entity(entity_id: String, version: int, acl: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GLOBAL_ENTITY_SERVICE_ENTITY_ID: entity_id,
		OperationParam.GLOBAL_ENTITY_SERVICE_VERSION: version,
		OperationParam.GLOBAL_ENTITY_SERVICE_ACL: acl
	}
	return await _send(ServiceOperation.MAKE_SYSTEM_ENTITY, data)

## Updates the indexed id of an existing global entity.
##
## Service Name - GlobalEntity[br]
## Service Operation - UPDATE_INDEXED_ID
##
## @param entity_id The entity ID
## @param indexed_id The new indexed id
## @param version The version of the entity to update
func update_entity_indexed_id(entity_id: String, indexed_id: String, version: int) -> Dictionary:
	var data := {
		OperationParam.GLOBAL_ENTITY_SERVICE_ENTITY_ID: entity_id,
		OperationParam.GLOBAL_ENTITY_SERVICE_INDEXED_ID: indexed_id,
		OperationParam.GLOBAL_ENTITY_SERVICE_VERSION: version
	}
	return await _send(ServiceOperation.UPDATE_INDEXED_ID, data)

## Updates an existing global entity's owner and access control list.
##
## Service Name - GlobalEntity[br]
## Service Operation - UPDATE_ENTITY_OWNER_AND_ACL
##
## @param entity_id The entity ID
## @param version The version of the entity to update
## @param owner_id The new owner ID
## @param acl The entity's access control list
func update_entity_owner_and_acl(entity_id: String, version: int, owner_id: String, acl: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GLOBAL_ENTITY_SERVICE_ENTITY_ID: entity_id,
		OperationParam.GLOBAL_ENTITY_SERVICE_VERSION: version,
		"ownerId": owner_id,
		OperationParam.GLOBAL_ENTITY_SERVICE_ACL: acl
	}
	return await _send(ServiceOperation.UPDATE_ENTITY_OWNER_AND_ACL, data)

## Partial increment of global entity data field items.
##
## Service Name - GlobalEntity[br]
## Service Operation - INCREMENT_GLOBAL_ENTITY_DATA
##
## @param entity_id The id of the entity to update
## @param json_data The entity's data fields to increment
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
