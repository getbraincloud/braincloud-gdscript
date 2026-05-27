# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudEntity
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

## Creates a new entity on the server.
##
## Service Name - Entity[br]
## Service Operation - Create
##
## @param entity_type The entity type as defined by the user
## @param json_entity_data The entity's data as a Dictionary
## @param json_entity_acl The entity's access control list. A null acl implies default permissions
func create_entity(entity_type: String, json_entity_data: Dictionary, json_entity_acl: Dictionary) -> Dictionary:
	var data := {
		OperationParam.ENTITY_SERVICE_ENTITY_TYPE: entity_type,
		OperationParam.ENTITY_SERVICE_ENTITY_DATA: json_entity_data,
		OperationParam.ENTITY_SERVICE_ACL: json_entity_acl
	}
	return await _send(ServiceOperation.CREATE, data)

## Creates a new entity on the server with an indexed id.
##
## Service Name - Entity[br]
## Service Operation - CREATE_WITH_INDEXED_ID
##
## @param entity_type The entity type as defined by the user
## @param indexed_id The indexed id for the entity
## @param json_entity_data The entity's data as a Dictionary
## @param json_entity_acl The entity's access control list
func create_entity_with_indexed_id(entity_type: String, indexed_id: String, json_entity_data: Dictionary, json_entity_acl: Dictionary) -> Dictionary:
	var data := {
		OperationParam.ENTITY_SERVICE_ENTITY_TYPE: entity_type,
		OperationParam.ENTITY_SERVICE_ENTITY_DATA: json_entity_data,
		OperationParam.ENTITY_SERVICE_ACL: json_entity_acl,
		"entityIndexedId": indexed_id
	}
	return await _send(ServiceOperation.CREATE_WITH_INDEXED_ID, data)

## Updates an entity on the server. Results in the entity data being completely replaced.
##
## Service Name - Entity[br]
## Service Operation - Update
##
## @param entity_id The id of the entity to update
## @param entity_type The entity type as defined by the user
## @param json_entity_data The entity's data as a Dictionary
## @param json_entity_acl The entity's access control list
## @param version Current version of the entity. Use -1 to skip version checking
func update_entity(entity_id: String, entity_type: String, json_entity_data: Dictionary, json_entity_acl: Dictionary, version: int) -> Dictionary:
	var data := {
		OperationParam.ENTITY_SERVICE_ENTITY_ID: entity_id,
		OperationParam.ENTITY_SERVICE_ENTITY_TYPE: entity_type,
		OperationParam.ENTITY_SERVICE_ENTITY_DATA: json_entity_data,
		OperationParam.ENTITY_SERVICE_ACL: json_entity_acl,
		OperationParam.ENTITY_SERVICE_ENTITY_VERSION: version
	}
	return await _send(ServiceOperation.UPDATE, data)

## Updates a shared entity owned by another user.
##
## Service Name - Entity[br]
## Service Operation - UpdateShared
##
## @param entity_id The id of the entity to update
## @param target_profile_id The id of the user who owns the shared entity
## @param entity_type The entity type as defined by the user
## @param json_entity_data The entity's data as a Dictionary
## @param version Current version of the entity. Use -1 to skip version checking
func update_shared_entity(entity_id: String, target_profile_id: String, entity_type: String, json_entity_data: Dictionary, version: int) -> Dictionary:
	var data := {
		OperationParam.ENTITY_SERVICE_ENTITY_ID: entity_id,
		OperationParam.ENTITY_SERVICE_FRIEND_ID: target_profile_id,
		OperationParam.ENTITY_SERVICE_ENTITY_TYPE: entity_type,
		OperationParam.ENTITY_SERVICE_ENTITY_DATA: json_entity_data,
		OperationParam.ENTITY_SERVICE_ENTITY_VERSION: version
	}
	return await _send(ServiceOperation.UPDATE_SHARED, data)

## Deletes the given entity on the server.
##
## Service Name - Entity[br]
## Service Operation - Delete
##
## @param entity_id The id of the entity to delete
## @param version Current version of the entity. Use -1 to skip version checking
func delete_entity(entity_id: String, version: int) -> Dictionary:
	var data := {
		OperationParam.ENTITY_SERVICE_ENTITY_ID: entity_id,
		OperationParam.ENTITY_SERVICE_ENTITY_VERSION: version
	}
	return await _send(ServiceOperation.DELETE, data)

## Deletes the given singleton entity on the server.
##
## Service Name - Entity[br]
## Service Operation - DeleteSingleton
##
## @param entity_type The type of the entity to delete
## @param version Current version of the entity. Use -1 to skip version checking
func delete_singleton(entity_type: String, version: int) -> Dictionary:
	var data := {
		OperationParam.ENTITY_SERVICE_ENTITY_TYPE: entity_type,
		OperationParam.ENTITY_SERVICE_ENTITY_VERSION: version
	}
	return await _send(ServiceOperation.DELETE_SINGLETON, data)

## Gets a specific entity.
##
## Service Name - Entity[br]
## Service Operation - Read
##
## @param entity_id The entity id
func get_entity(entity_id: String) -> Dictionary:
	var data := {OperationParam.ENTITY_SERVICE_ENTITY_ID: entity_id}
	return await _send(ServiceOperation.READ, data)

## Retrieves a singleton entity on the server. Returns null if the entity doesn't exist.
##
## Service Name - Entity[br]
## Service Operation - ReadSingleton
##
## @param entity_type The entity type as defined by the user
func get_singleton(entity_type: String) -> Dictionary:
	var data := {OperationParam.ENTITY_SERVICE_ENTITY_TYPE: entity_type}
	return await _send(ServiceOperation.READ_SINGLETON, data)

## Returns all user entities that match the given type.
##
## Service Name - Entity[br]
## Service Operation - ReadByType
##
## @param entity_type The entity type to search for
func get_entities_by_type(entity_type: String) -> Dictionary:
	var data := {OperationParam.ENTITY_SERVICE_ENTITY_TYPE: entity_type}
	return await _send(ServiceOperation.READ_BY_TYPE, data)

## Returns a shared entity for the given user and entity ID.
## An entity is shared if its ACL allows the currently logged in user to read the data.
##
## Service Name - Entity[br]
## Service Operation - READ_SHARED_ENTITY
##
## @param profile_id The profile ID of the user who owns the entity
## @param entity_id The ID of the entity to retrieve
func get_shared_entity(profile_id: String, entity_id: String) -> Dictionary:
	var data := {
		OperationParam.ENTITY_SERVICE_FRIEND_ID: profile_id,
		OperationParam.ENTITY_SERVICE_ENTITY_ID: entity_id
	}
	return await _send(ServiceOperation.READ_SHARED_ENTITY, data)

## Returns all shared entities for the given profile id.
## An entity is shared if its ACL allows the currently logged in user to read the data.
##
## Service Name - Entity[br]
## Service Operation - ReadShared
##
## @param profile_id The profile id to retrieve shared entities for
func get_shared_entities_for_profile_id(profile_id: String) -> Dictionary:
	var data := {"targetPlayerId": profile_id}
	return await _send(ServiceOperation.READ_SHARED, data)

## Uses a paging system to iterate through user entities.
##
## Service Name - Entity[br]
## Service Operation - GetPage
##
## @param context The json context for the page request
func get_page(context: Dictionary) -> Dictionary:
	var data := {OperationParam.GLOBAL_ENTITY_SERVICE_CONTEXT: context}
	return await _send(ServiceOperation.GET_PAGE, data)

## Retrieves previous or next pages after calling get_page.
##
## Service Name - Entity[br]
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

## Updates a singleton entity on the server. Creates it if it doesn't exist.
##
## Service Name - Entity[br]
## Service Operation - UpdateSingleton
##
## @param entity_type The entity type as defined by the user
## @param json_entity_data The entity's data as a Dictionary
## @param json_entity_acl The entity's access control list
## @param version Current version of the entity. Use -1 to skip version checking
func update_singleton(entity_type: String, json_entity_data: Dictionary, json_entity_acl: Dictionary, version: int) -> Dictionary:
	var data := {
		OperationParam.ENTITY_SERVICE_ENTITY_TYPE: entity_type,
		OperationParam.ENTITY_SERVICE_ENTITY_DATA: json_entity_data,
		OperationParam.ENTITY_SERVICE_ACL: json_entity_acl,
		OperationParam.ENTITY_SERVICE_ENTITY_VERSION: version
	}
	return await _send(ServiceOperation.UPDATE_SINGLETON, data)

## Updates the indexed id for an entity.
##
## Service Name - Entity[br]
## Service Operation - UPDATE_ENTITY_INDEXED_ID
##
## @param entity_id The entity id
## @param entity_indexed_id The new indexed id
## @param version Current version of the entity. Use -1 to skip version checking
func update_entity_indexed_id(entity_id: String, entity_indexed_id: String, version: int) -> Dictionary:
	var data := {
		OperationParam.ENTITY_SERVICE_ENTITY_ID: entity_id,
		"entityIndexedId": entity_indexed_id,
		OperationParam.ENTITY_SERVICE_ENTITY_VERSION: version
	}
	return await _send(ServiceOperation.UPDATE_ENTITY_INDEXED_ID, data)

## Updates the owner and ACL of an entity.
##
## Service Name - Entity[br]
## Service Operation - UPDATE_ENTITY_OWNER_AND_ACL
##
## @param entity_id The entity id
## @param version Current version of the entity. Use -1 to skip version checking
## @param profile_id The new owner profile id
## @param acl The new access control list
func update_entity_owner_and_acl(entity_id: String, version: int, profile_id: String, acl: Dictionary) -> Dictionary:
	var data := {
		OperationParam.ENTITY_SERVICE_ENTITY_ID: entity_id,
		OperationParam.ENTITY_SERVICE_ENTITY_VERSION: version,
		"ownerId": profile_id,
		OperationParam.ENTITY_SERVICE_ACL: acl
	}
	return await _send(ServiceOperation.UPDATE_ENTITY_OWNER_AND_ACL, data)

## Gets a list of entities based on type and/or where clause.
##
## Service Name - Entity[br]
## Service Operation - GET_LIST
##
## @param where_json Mongo style query Dictionary
## @param order_by_json Sort order Dictionary
## @param max_return The maximum number of entities to return
func get_list(where_json: Dictionary, order_by_json: Dictionary, max_return: int) -> Dictionary:
	var data := {
		OperationParam.GLOBAL_ENTITY_SERVICE_WHERE: where_json,
		OperationParam.GLOBAL_ENTITY_SERVICE_ORDER_BY: order_by_json,
		OperationParam.GLOBAL_ENTITY_SERVICE_MAX_RETURN: max_return
	}
	return await _send(ServiceOperation.GET_LIST, data)

## Gets a count of entities based on the where clause.
##
## Service Name - Entity[br]
## Service Operation - GET_LIST_COUNT
##
## @param where_json Mongo style query Dictionary
func get_list_count(where_json: Dictionary) -> Dictionary:
	var data := {OperationParam.GLOBAL_ENTITY_SERVICE_WHERE: where_json}
	return await _send(ServiceOperation.GET_LIST_COUNT, data)

## Gets a list of shared entities for the specified user based on type and/or where clause.
##
## Service Name - Entity[br]
## Service Operation - READ_SHARED_ENTITIES_LIST
##
## @param target_profile_id The profile ID to retrieve shared entities for
## @param where_json Mongo style query Dictionary
## @param order_by_json Sort order Dictionary
## @param max_return The maximum number of entities to return
func get_shared_entities_list_for_profile_id(target_profile_id: String, where_json: Dictionary, order_by_json: Dictionary, max_return: int) -> Dictionary:
	var data := {
		"targetPlayerId": target_profile_id,
		OperationParam.GLOBAL_ENTITY_SERVICE_WHERE: where_json,
		OperationParam.GLOBAL_ENTITY_SERVICE_ORDER_BY: order_by_json,
		OperationParam.GLOBAL_ENTITY_SERVICE_MAX_RETURN: max_return
	}
	return await _send(ServiceOperation.READ_SHARED_ENTITIES_LIST, data)

## Partial increment of entity data field items.
##
## Service Name - Entity[br]
## Service Operation - INCREMENT_USER_ENTITY_DATA
##
## @param entity_id The id of the entity to update
## @param json_data The entity's data fields to increment
func increment_user_entity_data(entity_id: String, json_data: Dictionary) -> Dictionary:
	var data := {
		OperationParam.ENTITY_SERVICE_ENTITY_ID: entity_id,
		OperationParam.ENTITY_SERVICE_ENTITY_DATA: json_data
	}
	return await _send(ServiceOperation.INCREMENT_USER_ENTITY_DATA, data)

## Partial increment of shared entity data field items.
##
## Service Name - Entity[br]
## Service Operation - INCREMENT_SHARED_USER_ENTITY_DATA
##
## @param entity_id The id of the entity to update
## @param target_profile_id Profile ID of the entity owner
## @param json_data The entity's data fields to increment
func increment_shared_user_entity_data(entity_id: String, target_profile_id: String, json_data: Dictionary) -> Dictionary:
	var data := {
		OperationParam.ENTITY_SERVICE_ENTITY_ID: entity_id,
		OperationParam.ENTITY_SERVICE_FRIEND_ID: target_profile_id,
		OperationParam.ENTITY_SERVICE_ENTITY_DATA: json_data
	}
	return await _send(ServiceOperation.INCREMENT_SHARED_USER_ENTITY_DATA, data)

## Makes the given entity a system entity.
##
## Service Name - Entity[br]
## Service Operation - MAKE_SYSTEM_ENTITY
##
## @param entity_id The entity id
## @param version Current version of the entity. Use -1 to skip version checking
## @param acl The new access control list
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
