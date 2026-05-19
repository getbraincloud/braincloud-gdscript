# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudGroup
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

func accept_group_invitation(group_id: String) -> Dictionary:
	var data := {OperationParam.GROUP_ID: group_id}
	return await _send(ServiceOperation.GROUP_ACCEPT_INVITATION, data)

func add_group_member(group_id: String, profile_id: String, role: String, json_attributes: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GROUP_ID: group_id,
		OperationParam.GROUP_PROFILE_ID: profile_id,
		OperationParam.GROUP_ROLE: role,
		OperationParam.GROUP_ATTRIBUTES: json_attributes
	}
	return await _send(ServiceOperation.GROUP_ADD_MEMBER, data)

func approve_group_join_request(group_id: String, profile_id: String, role: String, json_attributes: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GROUP_ID: group_id,
		OperationParam.GROUP_PROFILE_ID: profile_id,
		OperationParam.GROUP_ROLE: role,
		OperationParam.GROUP_ATTRIBUTES: json_attributes
	}
	return await _send(ServiceOperation.GROUP_ACCEPT_INVITATION, data)

func auto_join_group(group_type: String, auto_join_strategy: String, data_query: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GROUP_TYPE: group_type,
		OperationParam.GROUP_AUTO_JOIN_STRATEGY: auto_join_strategy,
		OperationParam.GROUP_WHERE: data_query
	}
	return await _send(ServiceOperation.GROUP_AUTO_JOIN, data)

func auto_join_group_multi(group_types: Array, auto_join_strategy: String, data_query: Dictionary) -> Dictionary:
	var data := {
		"groupTypes": group_types,
		OperationParam.GROUP_AUTO_JOIN_STRATEGY: auto_join_strategy,
		OperationParam.GROUP_WHERE: data_query
	}
	return await _send(ServiceOperation.GROUP_AUTO_JOIN, data)

func cancel_group_invitation(group_id: String, profile_id: String) -> Dictionary:
	var data := {
		OperationParam.GROUP_ID: group_id,
		OperationParam.GROUP_PROFILE_ID: profile_id
	}
	return await _send(ServiceOperation.GROUP_CANCEL_INVITATION, data)

func create_group(name: String, group_type: String, is_open_group: bool, acl: Dictionary, json_data: Dictionary, json_owner_attributes: Dictionary, json_default_member_attributes: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GROUP_NAME: name,
		OperationParam.GROUP_TYPE: group_type,
		OperationParam.GROUP_IS_OPEN_GROUP: is_open_group,
		OperationParam.GROUP_ACL: acl,
		OperationParam.GROUP_DATA: json_data,
		OperationParam.GROUP_OWNER_ATTRIBUTES: json_owner_attributes,
		OperationParam.GROUP_DEFAULT_MEMBER_ATTRIBUTES: json_default_member_attributes
	}
	return await _send(ServiceOperation.GROUP_CREATE, data)

func create_group_with_summary_data(name: String, group_type: String, is_open_group: bool, acl: Dictionary, json_data: Dictionary, json_owner_attributes: Dictionary, json_default_member_attributes: Dictionary, json_summary_data: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GROUP_NAME: name,
		OperationParam.GROUP_TYPE: group_type,
		OperationParam.GROUP_IS_OPEN_GROUP: is_open_group,
		OperationParam.GROUP_ACL: acl,
		OperationParam.GROUP_DATA: json_data,
		OperationParam.GROUP_OWNER_ATTRIBUTES: json_owner_attributes,
		OperationParam.GROUP_DEFAULT_MEMBER_ATTRIBUTES: json_default_member_attributes,
		OperationParam.GROUP_SUMMARY_DATA: json_summary_data
	}
	return await _send(ServiceOperation.GROUP_CREATE, data)

func create_group_entity(group_id: String, entity_type: String, is_public_membership: bool, json_entity_acl: Dictionary, json_entity_data: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GROUP_ID: group_id,
		OperationParam.GROUP_ENTITY_TYPE: entity_type,
		"isPublicMembership": is_public_membership,
		OperationParam.GROUP_ENTITY_ACL: json_entity_acl,
		OperationParam.GROUP_ENTITY_DATA: json_entity_data
	}
	return await _send(ServiceOperation.GROUP_CREATE_ENTITY, data)

func delete_group(group_id: String, version: int) -> Dictionary:
	var data := {
		OperationParam.GROUP_ID: group_id,
		OperationParam.GROUP_VERSION: version
	}
	return await _send(ServiceOperation.GROUP_DELETE, data)

func delete_group_entity(group_id: String, entity_id: String, version: int) -> Dictionary:
	var data := {
		OperationParam.GROUP_ID: group_id,
		OperationParam.GROUP_ENTITY_ID: entity_id,
		OperationParam.GROUP_ENTITY_VERSION: version
	}
	return await _send(ServiceOperation.GROUP_DELETE_ENTITY, data)

func delete_member(group_id: String, profile_id: String) -> Dictionary:
	var data := {
		OperationParam.GROUP_ID: group_id,
		OperationParam.GROUP_PROFILE_ID: profile_id
	}
	return await _send(ServiceOperation.GROUP_DELETE_MEMBER, data)

func get_my_groups() -> Dictionary:
	return await _send(ServiceOperation.GROUP_GET_MY_GROUPS, {})

func invite_group_member(group_id: String, profile_id: String, role: String, json_attributes: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GROUP_ID: group_id,
		OperationParam.GROUP_PROFILE_ID: profile_id,
		OperationParam.GROUP_ROLE: role,
		OperationParam.GROUP_ATTRIBUTES: json_attributes
	}
	return await _send(ServiceOperation.GROUP_INVITE, data)

func join_group(group_id: String) -> Dictionary:
	var data := {OperationParam.GROUP_ID: group_id}
	return await _send(ServiceOperation.GROUP_JOIN, data)

func leave_group(group_id: String) -> Dictionary:
	var data := {OperationParam.GROUP_ID: group_id}
	return await _send(ServiceOperation.GROUP_LEAVE, data)

func list_groups(group_type: String) -> Dictionary:
	var context := {
		"pagination": {"rowsPerPage": 50, "pageNumber": 1},
		"searchCriteria": {"groupType": group_type},
		"sortCriteria": {}
	}
	var data := {OperationParam.GROUP_CONTEXT: context}
	return await _send(ServiceOperation.GROUP_LIST_GROUPS_PAGE, data)

func list_groups_page(context: Dictionary) -> Dictionary:
	var data := {OperationParam.GROUP_CONTEXT: context}
	return await _send(ServiceOperation.GROUP_LIST_GROUPS_PAGE, data)

func list_groups_page_by_offset(context: String, page_offset: int) -> Dictionary:
	var data := {
		OperationParam.GROUP_CONTEXT: context,
		OperationParam.GROUP_PAGE_OFFSET: page_offset
	}
	return await _send(ServiceOperation.GROUP_LIST_GROUPS_PAGE_BY_OFFSET, data)

func list_groups_with_member(profile_id: String) -> Dictionary:
	var data := {OperationParam.GROUP_PROFILE_ID: profile_id}
	return await _send(ServiceOperation.GROUP_LIST_GROUPS_WITH_MEMBER, data)

func read_group(group_id: String) -> Dictionary:
	var data := {OperationParam.GROUP_ID: group_id}
	return await _send(ServiceOperation.GROUP_GET, data)

func read_group_data(group_id: String) -> Dictionary:
	var data := {OperationParam.GROUP_ID: group_id}
	return await _send(ServiceOperation.GROUP_READ_DATA, data)

func read_group_entities(group_id: String) -> Dictionary:
	var data := {OperationParam.GROUP_ID: group_id}
	return await _send(ServiceOperation.GROUP_GET_ENTITIES, data)

func read_group_entity(group_id: String, entity_id: String) -> Dictionary:
	var data := {
		OperationParam.GROUP_ID: group_id,
		OperationParam.GROUP_ENTITY_ID: entity_id
	}
	return await _send(ServiceOperation.GROUP_READ_ENTITY, data)

func read_group_members(group_id: String) -> Dictionary:
	var data := {OperationParam.GROUP_ID: group_id}
	return await _send(ServiceOperation.GROUP_READ_MEMBERS, data)

func reject_group_invitation(group_id: String) -> Dictionary:
	var data := {OperationParam.GROUP_ID: group_id}
	return await _send(ServiceOperation.GROUP_REJECT_INVITATION, data)

func remove_group_member(group_id: String, profile_id: String) -> Dictionary:
	var data := {
		OperationParam.GROUP_ID: group_id,
		OperationParam.GROUP_PROFILE_ID: profile_id
	}
	return await _send(ServiceOperation.GROUP_DELETE_MEMBER, data)

func update_group_data(group_id: String, version: int, json_data: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GROUP_ID: group_id,
		OperationParam.GROUP_VERSION: version,
		OperationParam.GROUP_DATA: json_data
	}
	return await _send(ServiceOperation.GROUP_UPDATE, data)

func update_group_entity_data(group_id: String, entity_id: String, version: int, json_data: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GROUP_ID: group_id,
		OperationParam.GROUP_ENTITY_ID: entity_id,
		OperationParam.GROUP_ENTITY_VERSION: version,
		OperationParam.GROUP_ENTITY_DATA: json_data
	}
	return await _send(ServiceOperation.GROUP_UPDATE_ENTITY, data)

func update_group_member(group_id: String, profile_id: String, role: String, json_attributes: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GROUP_ID: group_id,
		OperationParam.GROUP_PROFILE_ID: profile_id,
		OperationParam.GROUP_ROLE: role,
		OperationParam.GROUP_ATTRIBUTES: json_attributes
	}
	return await _send(ServiceOperation.GROUP_UPDATE_MEMBER, data)

func update_group_name(group_id: String, name: String) -> Dictionary:
	var data := {
		OperationParam.GROUP_ID: group_id,
		OperationParam.GROUP_NAME: name
	}
	return await _send(ServiceOperation.GROUP_UPDATE_NAME, data)

func set_group_open(group_id: String, is_open_group: bool) -> Dictionary:
	var data := {
		OperationParam.GROUP_ID: group_id,
		OperationParam.GROUP_IS_OPEN_GROUP: is_open_group
	}
	return await _send(ServiceOperation.GROUP_SET_GROUP_OPEN, data)

func update_group_summary(group_id: String, version: int, json_summary_data: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GROUP_ID: group_id,
		OperationParam.GROUP_VERSION: version,
		OperationParam.GROUP_SUMMARY_DATA: json_summary_data
	}
	return await _send(ServiceOperation.GROUP_UPDATE_SUMMARY, data)

func get_random_groups_matching(json_query: Dictionary, max_return: int) -> Dictionary:
	var data := {
		OperationParam.GROUP_WHERE: json_query,
		OperationParam.GLOBAL_ENTITY_SERVICE_MAX_RETURN: max_return
	}
	return await _send(ServiceOperation.GROUP_GET_RANDOM_ENTITIES_MATCHING, data)

func get_group_entities_page(context: Dictionary) -> Dictionary:
	var data := {OperationParam.GROUP_CONTEXT: context}
	return await _send(ServiceOperation.GROUP_ENTITIES_PAGE, data)

func get_group_entities_page_by_offset(group_id: String, context: String, page_offset: int) -> Dictionary:
	var data := {
		OperationParam.GROUP_ID: group_id,
		OperationParam.GROUP_CONTEXT: context,
		OperationParam.GROUP_PAGE_OFFSET: page_offset
	}
	return await _send(ServiceOperation.GROUP_ENTITIES_PAGE_BY_OFFSET, data)

func update_group_acl(group_id: String, acl: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GROUP_ID: group_id,
		OperationParam.GROUP_ACL: acl
	}
	return await _send(ServiceOperation.GROUP_UPDATE_ACL, data)

func update_group_entity_acl(group_id: String, entity_id: String, acl: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GROUP_ID: group_id,
		OperationParam.GROUP_ENTITY_ID: entity_id,
		OperationParam.GROUP_ENTITY_ACL: acl
	}
	return await _send(ServiceOperation.GROUP_UPDATE_ENTITY_ACL, data)

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.GROUP, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
