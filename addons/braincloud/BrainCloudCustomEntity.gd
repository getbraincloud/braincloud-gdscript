# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudCustomEntity
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

## Creates a new custom entity.
##
## Service Name - CustomEntity[br]
## Service Operation - CreateEntity
##
## @param entity_type The entity type as defined by the user
## @param json_entity_data The entity's data as a Dictionary
## @param json_entity_acl The entity's access control list. A null acl implies default permissions
## @param time_to_live Sets expiry time for entity in milliseconds if > 0
## @param is_owned Whether this entity is owned by the current user
func create_entity(entity_type: String, json_entity_data: Dictionary, json_entity_acl: Dictionary, time_to_live: int, is_owned: bool) -> Dictionary:
	var data := {
		OperationParam.CUSTOM_ENTITY_TYPE_NAME: entity_type,
		OperationParam.CUSTOM_ENTITY_DATA: json_entity_data,
		OperationParam.CUSTOM_ENTITY_ACL: json_entity_acl,
		OperationParam.CUSTOM_ENTITY_TIME_TO_LIVE: time_to_live,
		OperationParam.CUSTOM_ENTITY_IS_OWNED: is_owned
	}
	return await _send(ServiceOperation.CUSTOM_ENTITY_CREATE, data)

## Reads the custom entity singleton owned by the session's user.
##
## Service Name - CustomEntity[br]
## Service Operation - ReadSingleton
##
## @param entity_type The entity type as defined by the user
func read_singleton(entity_type: String) -> Dictionary:
	var data := {
		OperationParam.CUSTOM_ENTITY_TYPE_NAME: entity_type
	}
	return await _send(ServiceOperation.CUSTOM_ENTITY_READ_SINGLETON, data)

## Updates the singleton owned by the user for the specified custom entity type on the server,
## creating the singleton if it does not exist. The owned singleton's data is completely replaced.
##
## Service Name - CustomEntity[br]
## Service Operation - UpdateSingleton
##
## @param entity_type The entity type as defined by the user
## @param version The version of the entity (-1 to bypass version check)
## @param json_entity_data The entity's data as a Dictionary
## @param json_entity_acl The entity's access control list
## @param time_to_live Sets expiry time for entity in milliseconds if > 0
func update_singleton(entity_type: String, version: int, json_entity_data: Dictionary, json_entity_acl: Dictionary, time_to_live: int) -> Dictionary:
	var data := {
		OperationParam.CUSTOM_ENTITY_TYPE_NAME: entity_type,
		OperationParam.CUSTOM_ENTITY_VERSION: version,
		OperationParam.CUSTOM_ENTITY_DATA: json_entity_data,
		OperationParam.CUSTOM_ENTITY_ACL: json_entity_acl,
		OperationParam.CUSTOM_ENTITY_TIME_TO_LIVE: time_to_live
	}
	return await _send(ServiceOperation.CUSTOM_ENTITY_UPDATE_SINGLETON, data)

## Deletes the specified custom entity singleton, owned by the session's user, for the specified entity type.
##
## Service Name - CustomEntity[br]
## Service Operation - DeleteSingleton
##
## @param entity_type The entity type as defined by the user
## @param version The version of the entity (-1 to bypass version check)
func delete_singleton(entity_type: String, version: int) -> Dictionary:
	var data := {
		OperationParam.CUSTOM_ENTITY_TYPE_NAME: entity_type,
		OperationParam.CUSTOM_ENTITY_VERSION: version
	}
	return await _send(ServiceOperation.CUSTOM_ENTITY_DELETE_SINGLETON, data)

## Uses a paging system to iterate through custom entities.
## After retrieving a page, use get_entity_page_offset to retrieve previous or next pages.
##
## Service Name - CustomEntity[br]
## Service Operation - GetCustomEntityPage
##
## @param entity_type The entity type as defined by the user
## @param context The json context for the page request
func get_entity_page(entity_type: String, context: Dictionary) -> Dictionary:
	var data := {
		OperationParam.CUSTOM_ENTITY_TYPE_NAME: entity_type,
		OperationParam.CUSTOM_ENTITY_CONTEXT: context
	}
	return await _send(ServiceOperation.CUSTOM_ENTITY_GET_ENTITY_PAGE, data)

## Gets the page of custom entities from the server based on the encoded context and specified page offset.
##
## Service Name - CustomEntity[br]
## Service Operation - GetEntityPageOffset
##
## @param entity_type The entity type as defined by the user
## @param context The encoded context string returned from a previous get_entity_page call
## @param page_offset The positive or negative page offset to fetch
func get_entity_page_offset(entity_type: String, context: String, page_offset: int) -> Dictionary:
	var data := {
		OperationParam.CUSTOM_ENTITY_TYPE_NAME: entity_type,
		OperationParam.CUSTOM_ENTITY_CONTEXT: context,
		OperationParam.CUSTOM_ENTITY_PAGE_OFFSET: page_offset
	}
	return await _send(ServiceOperation.CUSTOM_ENTITY_GET_ENTITY_PAGE_OFFSET, data)

## Reads the specified custom entity from the server.
##
## Service Name - CustomEntity[br]
## Service Operation - ReadEntity
##
## @param entity_type The entity type as defined by the user
## @param entity_id The entity id as defined by the system
func read_entity(entity_type: String, entity_id: String) -> Dictionary:
	var data := {
		OperationParam.CUSTOM_ENTITY_TYPE_NAME: entity_type,
		OperationParam.CUSTOM_ENTITY_ENTITY_ID: entity_id
	}
	return await _send(ServiceOperation.CUSTOM_ENTITY_READ_ENTITY, data)

## Replaces the specified custom entity's data, and optionally updates the acl and expiry, on the server.
##
## Service Name - CustomEntity[br]
## Service Operation - UpdateEntity
##
## @param entity_type The entity type as defined by the user
## @param entity_id The entity id as defined by the system
## @param version The version of the entity (-1 to bypass version check)
## @param json_entity_data The entity's data as a Dictionary
## @param json_entity_acl The entity's access control list
## @param time_to_live Sets expiry time for entity in milliseconds if > 0
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

## Sets the specified fields within custom entity data on the server.
##
## Service Name - CustomEntity[br]
## Service Operation - UpdateEntityFields
##
## @param entity_type The entity type as defined by the user
## @param entity_id The entity id as defined by the system
## @param version The version of the entity (-1 to bypass version check)
## @param fields_json Specific fields, as a Dictionary, within entity's custom data to update
func update_entity_fields(entity_type: String, entity_id: String, version: int, fields_json: Dictionary) -> Dictionary:
	var data := {
		OperationParam.CUSTOM_ENTITY_TYPE_NAME: entity_type,
		OperationParam.CUSTOM_ENTITY_ENTITY_ID: entity_id,
		OperationParam.CUSTOM_ENTITY_VERSION: version,
		OperationParam.CUSTOM_ENTITY_FIELDS_DATA: fields_json
	}
	return await _send(ServiceOperation.CUSTOM_ENTITY_UPDATE_ENTITY_FIELDS, data)

## Increments the specified fields on the custom entity owned by the user on the server.
##
## Service Name - CustomEntity[br]
## Service Operation - IncrementData
##
## @param entity_type The entity type as defined by the user
## @param entity_id The entity id as defined by the system
## @param fields_json Specific fields, as a Dictionary, within entity's custom data with respective increment amounts
func increment_entity_data(entity_type: String, entity_id: String, fields_json: Dictionary) -> Dictionary:
	var data := {
		OperationParam.CUSTOM_ENTITY_TYPE_NAME: entity_type,
		OperationParam.CUSTOM_ENTITY_ENTITY_ID: entity_id,
		OperationParam.CUSTOM_ENTITY_INCREMENT_DATA: fields_json
	}
	return await _send(ServiceOperation.CUSTOM_ENTITY_INCREMENT_ENTITY_DATA, data)

## Deletes the specified custom entity on the server.
##
## Service Name - CustomEntity[br]
## Service Operation - DeleteEntity
##
## @param entity_type The entity type as defined by the user
## @param entity_id The entity id as defined by the system
## @param version The version of the entity (-1 to bypass version check)
func delete_entity(entity_type: String, entity_id: String, version: int) -> Dictionary:
	var data := {
		OperationParam.CUSTOM_ENTITY_TYPE_NAME: entity_type,
		OperationParam.CUSTOM_ENTITY_ENTITY_ID: entity_id,
		OperationParam.CUSTOM_ENTITY_VERSION: version
	}
	return await _send(ServiceOperation.CUSTOM_ENTITY_DELETE_ENTITY, data)

## Deletes entities based on the specified delete criteria.
##
## Service Name - CustomEntity[br]
## Service Operation - DeleteEntities
##
## @param entity_type The entity type as defined by the user
## @param json_delete_criteria The criteria specifying which entities to delete
func delete_entities(entity_type: String, json_delete_criteria: Dictionary) -> Dictionary:
	var data := {
		OperationParam.CUSTOM_ENTITY_TYPE_NAME: entity_type,
		"deleteCriteria": json_delete_criteria
	}
	return await _send(ServiceOperation.CUSTOM_ENTITY_DELETE_ENTITIES, data)

## Gets a count of custom entities matching the specified where clause.
##
## Service Name - CustomEntity[br]
## Service Operation - GetCount
##
## @param entity_type The entity type as defined by the user
## @param where_json The where clause as a Dictionary
func count_entities_where(entity_type: String, where_json: Dictionary) -> Dictionary:
	var data := {
		OperationParam.CUSTOM_ENTITY_TYPE_NAME: entity_type,
		"whereJson": where_json
	}
	return await _send(ServiceOperation.CUSTOM_ENTITY_COUNT_ENTITIES_WHERE, data)

## Gets a set of random entities matching the specified where clause.
##
## Service Name - CustomEntity[br]
## Service Operation - GetRandomEntitiesMatching
##
## @param entity_type The entity type as defined by the user
## @param where_json The where clause as a Dictionary
## @param max_return The maximum number of entities to return
func get_random_entities_matching(entity_type: String, where_json: Dictionary, max_return: int) -> Dictionary:
	var data := {
		OperationParam.CUSTOM_ENTITY_TYPE_NAME: entity_type,
		"where": where_json,
		OperationParam.GLOBAL_ENTITY_SERVICE_MAX_RETURN: max_return
	}
	return await _send(ServiceOperation.CUSTOM_ENTITY_GET_RANDOM_ENTITIES_MATCHING, data)

## Updates the owner and access control list of the specified custom entity.
##
## Service Name - CustomEntity[br]
## Service Operation - UpdateEntityOwnerAndAcl
##
## @param entity_type The entity type as defined by the user
## @param entity_id The entity id as defined by the system
## @param version The version of the entity (-1 to bypass version check)
## @param owner_id The new owner's profile id
## @param acl The entity's access control list
func update_entity_owner_and_acl(entity_type: String, entity_id: String, version: int, owner_id: String, acl: Dictionary) -> Dictionary:
	var data := {
		OperationParam.CUSTOM_ENTITY_TYPE_NAME: entity_type,
		OperationParam.CUSTOM_ENTITY_ENTITY_ID: entity_id,
		OperationParam.CUSTOM_ENTITY_VERSION: version,
		OperationParam.CUSTOM_ENTITY_NEW_OWNER_ID: owner_id,
		OperationParam.CUSTOM_ENTITY_ACL: acl
	}
	return await _send(ServiceOperation.CUSTOM_ENTITY_UPDATE_ENTITY_OWNER_AND_ACL, data)

## Converts the specified custom entity to a system entity, clearing its owner.
##
## Service Name - CustomEntity[br]
## Service Operation - MakeSystemEntity
##
## @param entity_type The entity type as defined by the user
## @param entity_id The entity id as defined by the system
## @param version The version of the entity (-1 to bypass version check)
## @param acl The entity's access control list
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
