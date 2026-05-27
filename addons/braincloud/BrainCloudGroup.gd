# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudGroup
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

## Accepts an invitation to join the group.
##
## Service Name - Group[br]
## Service Operation - AcceptGroupInvitation
##
## @param group_id The id of the group
func accept_group_invitation(group_id: String) -> Dictionary:
	var data := {OperationParam.GROUP_ID: group_id}
	return await _send(ServiceOperation.GROUP_ACCEPT_INVITATION, data)

## Adds a member to the group.
##
## Service Name - Group[br]
## Service Operation - AddGroupMember
##
## @param group_id The id of the group
## @param profile_id Profile id of the member to add
## @param role Role of the member being added
## @param json_attributes Attributes of the member being added
func add_group_member(group_id: String, profile_id: String, role: String, json_attributes: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GROUP_ID: group_id,
		OperationParam.GROUP_PROFILE_ID: profile_id,
		OperationParam.GROUP_ROLE: role,
		OperationParam.GROUP_ATTRIBUTES: json_attributes
	}
	return await _send(ServiceOperation.GROUP_ADD_MEMBER, data)

## Approves an application to join the group.
##
## Service Name - Group[br]
## Service Operation - ApproveGroupJoinRequest
##
## @param group_id The id of the group
## @param profile_id Profile id of the applicant to approve
## @param role Role to assign the approved member
## @param json_attributes Attributes to assign the approved member
func approve_group_join_request(group_id: String, profile_id: String, role: String, json_attributes: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GROUP_ID: group_id,
		OperationParam.GROUP_PROFILE_ID: profile_id,
		OperationParam.GROUP_ROLE: role,
		OperationParam.GROUP_ATTRIBUTES: json_attributes
	}
	return await _send(ServiceOperation.GROUP_ACCEPT_INVITATION, data)

## Automatically joins an open group that matches the search criteria and group type.
##
## Service Name - Group[br]
## Service Operation - AutoJoinGroup
##
## @param group_type The type of group to search for
## @param auto_join_strategy The strategy to use when selecting a group to join
## @param data_query Optional search criteria
func auto_join_group(group_type: String, auto_join_strategy: String, data_query: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GROUP_TYPE: group_type,
		OperationParam.GROUP_AUTO_JOIN_STRATEGY: auto_join_strategy,
		OperationParam.GROUP_WHERE: data_query
	}
	return await _send(ServiceOperation.GROUP_AUTO_JOIN, data)

## Automatically joins an open group of one of the specified types that matches the search criteria.
##
## Service Name - Group[br]
## Service Operation - AutoJoinGroupMulti
##
## @param group_types Array of group types to search for
## @param auto_join_strategy The strategy to use when selecting a group to join
## @param data_query Optional search criteria
func auto_join_group_multi(group_types: Array, auto_join_strategy: String, data_query: Dictionary) -> Dictionary:
	var data := {
		"groupTypes": group_types,
		OperationParam.GROUP_AUTO_JOIN_STRATEGY: auto_join_strategy,
		OperationParam.GROUP_WHERE: data_query
	}
	return await _send(ServiceOperation.GROUP_AUTO_JOIN, data)

## Cancels an outstanding invitation to the specified user.
##
## Service Name - Group[br]
## Service Operation - CancelGroupInvitation
##
## @param group_id The id of the group
## @param profile_id Profile id of the invited user
func cancel_group_invitation(group_id: String, profile_id: String) -> Dictionary:
	var data := {
		OperationParam.GROUP_ID: group_id,
		OperationParam.GROUP_PROFILE_ID: profile_id
	}
	return await _send(ServiceOperation.GROUP_CANCEL_INVITATION, data)

## Creates a new group.
##
## Service Name - Group[br]
## Service Operation - CreateGroup
##
## @param name The name of the group
## @param group_type The type of group
## @param is_open_group Whether non-members can join without an invitation
## @param acl The group's access control list
## @param json_data The group's initial data
## @param json_owner_attributes Attributes for the owner member
## @param json_default_member_attributes Default attributes for new members
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

## Creates a new group with summary data.
##
## Service Name - Group[br]
## Service Operation - CreateGroup
##
## @param name The name of the group
## @param group_type The type of group
## @param is_open_group Whether non-members can join without an invitation
## @param acl The group's access control list
## @param json_data The group's initial data
## @param json_owner_attributes Attributes for the owner member
## @param json_default_member_attributes Default attributes for new members
## @param json_summary_data Summary data to include with the group
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

## Creates an entity in the context of the group.
##
## Service Name - Group[br]
## Service Operation - CreateGroupEntity
##
## @param group_id The id of the group
## @param entity_type The entity type
## @param is_public_membership Whether the entity is public to non-members
## @param json_entity_acl The entity's access control list
## @param json_entity_data The entity's data
func create_group_entity(group_id: String, entity_type: String, is_public_membership: bool, json_entity_acl: Dictionary, json_entity_data: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GROUP_ID: group_id,
		OperationParam.GROUP_ENTITY_TYPE: entity_type,
		"isPublicMembership": is_public_membership,
		OperationParam.GROUP_ENTITY_ACL: json_entity_acl,
		OperationParam.GROUP_ENTITY_DATA: json_entity_data
	}
	return await _send(ServiceOperation.GROUP_CREATE_ENTITY, data)

## Deletes a group.
##
## Service Name - Group[br]
## Service Operation - DeleteGroup
##
## @param group_id The id of the group to delete
## @param version The version of the group to delete
func delete_group(group_id: String, version: int) -> Dictionary:
	var data := {
		OperationParam.GROUP_ID: group_id,
		OperationParam.GROUP_VERSION: version
	}
	return await _send(ServiceOperation.GROUP_DELETE, data)

## Deletes a group entity.
##
## Service Name - Group[br]
## Service Operation - DeleteGroupEntity
##
## @param group_id The id of the group
## @param entity_id The id of the entity to delete
## @param version The version of the entity to delete
func delete_group_entity(group_id: String, entity_id: String, version: int) -> Dictionary:
	var data := {
		OperationParam.GROUP_ID: group_id,
		OperationParam.GROUP_ENTITY_ID: entity_id,
		OperationParam.GROUP_ENTITY_VERSION: version
	}
	return await _send(ServiceOperation.GROUP_DELETE_ENTITY, data)

## Deletes a member from the group.
##
## Service Name - Group[br]
## Service Operation - DeleteGroupMember
##
## @param group_id The id of the group
## @param profile_id Profile id of the member to delete
func delete_member(group_id: String, profile_id: String) -> Dictionary:
	var data := {
		OperationParam.GROUP_ID: group_id,
		OperationParam.GROUP_PROFILE_ID: profile_id
	}
	return await _send(ServiceOperation.GROUP_DELETE_MEMBER, data)

## Returns a list of groups the current user belongs to.
##
## Service Name - Group[br]
## Service Operation - GetMyGroups
func get_my_groups() -> Dictionary:
	return await _send(ServiceOperation.GROUP_GET_MY_GROUPS, {})

## Invites a user to join the group.
##
## Service Name - Group[br]
## Service Operation - InviteGroupMember
##
## @param group_id The id of the group
## @param profile_id Profile id of the user to invite
## @param role Role to assign the invited member upon joining
## @param json_attributes Attributes to assign the invited member upon joining
func invite_group_member(group_id: String, profile_id: String, role: String, json_attributes: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GROUP_ID: group_id,
		OperationParam.GROUP_PROFILE_ID: profile_id,
		OperationParam.GROUP_ROLE: role,
		OperationParam.GROUP_ATTRIBUTES: json_attributes
	}
	return await _send(ServiceOperation.GROUP_INVITE, data)

## Joins an open group or submits a request to join a closed group.
##
## Service Name - Group[br]
## Service Operation - JoinGroup
##
## @param group_id The id of the group to join
func join_group(group_id: String) -> Dictionary:
	var data := {OperationParam.GROUP_ID: group_id}
	return await _send(ServiceOperation.GROUP_JOIN, data)

## Leaves a group the current user is a member of.
##
## Service Name - Group[br]
## Service Operation - LeaveGroup
##
## @param group_id The id of the group to leave
func leave_group(group_id: String) -> Dictionary:
	var data := {OperationParam.GROUP_ID: group_id}
	return await _send(ServiceOperation.GROUP_LEAVE, data)

## Returns a page of groups of the specified type using default pagination.
##
## Service Name - Group[br]
## Service Operation - ListGroupsPage
##
## @param group_type The type of groups to list
func list_groups(group_type: String) -> Dictionary:
	var context := {
		"pagination": {"rowsPerPage": 50, "pageNumber": 1},
		"searchCriteria": {"groupType": group_type},
		"sortCriteria": {}
	}
	var data := {OperationParam.GROUP_CONTEXT: context}
	return await _send(ServiceOperation.GROUP_LIST_GROUPS_PAGE, data)

## Returns a page of groups using the specified context.
##
## Service Name - Group[br]
## Service Operation - ListGroupsPage
##
## @param context The context for the page request
func list_groups_page(context: Dictionary) -> Dictionary:
	var data := {OperationParam.GROUP_CONTEXT: context}
	return await _send(ServiceOperation.GROUP_LIST_GROUPS_PAGE, data)

## Returns a page of groups based on the encoded context and specified page offset.
##
## Service Name - Group[br]
## Service Operation - ListGroupsPageByOffset
##
## @param context The encoded context string returned from a previous list_groups_page call
## @param page_offset The positive or negative page offset to fetch
func list_groups_page_by_offset(context: String, page_offset: int) -> Dictionary:
	var data := {
		OperationParam.GROUP_CONTEXT: context,
		OperationParam.GROUP_PAGE_OFFSET: page_offset
	}
	return await _send(ServiceOperation.GROUP_LIST_GROUPS_PAGE_BY_OFFSET, data)

## Returns a list of groups the specified user is a member of.
##
## Service Name - Group[br]
## Service Operation - ListGroupsWithMember
##
## @param profile_id Profile id of the user to look up
func list_groups_with_member(profile_id: String) -> Dictionary:
	var data := {OperationParam.GROUP_PROFILE_ID: profile_id}
	return await _send(ServiceOperation.GROUP_LIST_GROUPS_WITH_MEMBER, data)

## Reads information on the specified group.
##
## Service Name - Group[br]
## Service Operation - GetGroup
##
## @param group_id The id of the group
func read_group(group_id: String) -> Dictionary:
	var data := {OperationParam.GROUP_ID: group_id}
	return await _send(ServiceOperation.GROUP_GET, data)

## Reads the data of the specified group.
##
## Service Name - Group[br]
## Service Operation - ReadGroupData
##
## @param group_id The id of the group
func read_group_data(group_id: String) -> Dictionary:
	var data := {OperationParam.GROUP_ID: group_id}
	return await _send(ServiceOperation.GROUP_READ_DATA, data)

## Reads all entities in the specified group.
##
## Service Name - Group[br]
## Service Operation - GetGroupEntities
##
## @param group_id The id of the group
func read_group_entities(group_id: String) -> Dictionary:
	var data := {OperationParam.GROUP_ID: group_id}
	return await _send(ServiceOperation.GROUP_GET_ENTITIES, data)

## Reads a specific entity in the specified group.
##
## Service Name - Group[br]
## Service Operation - ReadGroupEntity
##
## @param group_id The id of the group
## @param entity_id The id of the entity to read
func read_group_entity(group_id: String, entity_id: String) -> Dictionary:
	var data := {
		OperationParam.GROUP_ID: group_id,
		OperationParam.GROUP_ENTITY_ID: entity_id
	}
	return await _send(ServiceOperation.GROUP_READ_ENTITY, data)

## Reads the members of the specified group.
##
## Service Name - Group[br]
## Service Operation - ReadGroupMembers
##
## @param group_id The id of the group
func read_group_members(group_id: String) -> Dictionary:
	var data := {OperationParam.GROUP_ID: group_id}
	return await _send(ServiceOperation.GROUP_READ_MEMBERS, data)

## Rejects an invitation to join the group.
##
## Service Name - Group[br]
## Service Operation - RejectGroupInvitation
##
## @param group_id The id of the group
func reject_group_invitation(group_id: String) -> Dictionary:
	var data := {OperationParam.GROUP_ID: group_id}
	return await _send(ServiceOperation.GROUP_REJECT_INVITATION, data)

## Removes a member from the group.
##
## Service Name - Group[br]
## Service Operation - DeleteGroupMember
##
## @param group_id The id of the group
## @param profile_id Profile id of the member to remove
func remove_group_member(group_id: String, profile_id: String) -> Dictionary:
	var data := {
		OperationParam.GROUP_ID: group_id,
		OperationParam.GROUP_PROFILE_ID: profile_id
	}
	return await _send(ServiceOperation.GROUP_DELETE_MEMBER, data)

## Updates the group data.
##
## Service Name - Group[br]
## Service Operation - UpdateGroup
##
## @param group_id The id of the group
## @param version The version of the group to update
## @param json_data The new data for the group
func update_group_data(group_id: String, version: int, json_data: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GROUP_ID: group_id,
		OperationParam.GROUP_VERSION: version,
		OperationParam.GROUP_DATA: json_data
	}
	return await _send(ServiceOperation.GROUP_UPDATE, data)

## Updates the data in a specific group entity.
##
## Service Name - Group[br]
## Service Operation - UpdateGroupEntity
##
## @param group_id The id of the group
## @param entity_id The id of the entity to update
## @param version The version of the entity to update
## @param json_data The new data for the entity
func update_group_entity_data(group_id: String, entity_id: String, version: int, json_data: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GROUP_ID: group_id,
		OperationParam.GROUP_ENTITY_ID: entity_id,
		OperationParam.GROUP_ENTITY_VERSION: version,
		OperationParam.GROUP_ENTITY_DATA: json_data
	}
	return await _send(ServiceOperation.GROUP_UPDATE_ENTITY, data)

## Updates a member of the group.
##
## Service Name - Group[br]
## Service Operation - UpdateGroupMember
##
## @param group_id The id of the group
## @param profile_id Profile id of the member to update
## @param role New role of the member
## @param json_attributes New attributes of the member
func update_group_member(group_id: String, profile_id: String, role: String, json_attributes: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GROUP_ID: group_id,
		OperationParam.GROUP_PROFILE_ID: profile_id,
		OperationParam.GROUP_ROLE: role,
		OperationParam.GROUP_ATTRIBUTES: json_attributes
	}
	return await _send(ServiceOperation.GROUP_UPDATE_MEMBER, data)

## Updates the name of the group.
##
## Service Name - Group[br]
## Service Operation - UpdateGroupName
##
## @param group_id The id of the group
## @param name The new name for the group
func update_group_name(group_id: String, name: String) -> Dictionary:
	var data := {
		OperationParam.GROUP_ID: group_id,
		OperationParam.GROUP_NAME: name
	}
	return await _send(ServiceOperation.GROUP_UPDATE_NAME, data)

## Sets whether the group is open (anyone can join) or closed (invitation required).
##
## Service Name - Group[br]
## Service Operation - SetGroupOpen
##
## @param group_id The id of the group
## @param is_open_group Whether the group should be open
func set_group_open(group_id: String, is_open_group: bool) -> Dictionary:
	var data := {
		OperationParam.GROUP_ID: group_id,
		OperationParam.GROUP_IS_OPEN_GROUP: is_open_group
	}
	return await _send(ServiceOperation.GROUP_SET_GROUP_OPEN, data)

## Updates the summary data for the group.
##
## Service Name - Group[br]
## Service Operation - UpdateGroupSummary
##
## @param group_id The id of the group
## @param version The version of the group to update
## @param json_summary_data The new summary data for the group
func update_group_summary(group_id: String, version: int, json_summary_data: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GROUP_ID: group_id,
		OperationParam.GROUP_VERSION: version,
		OperationParam.GROUP_SUMMARY_DATA: json_summary_data
	}
	return await _send(ServiceOperation.GROUP_UPDATE_SUMMARY, data)

## Gets a random subset of groups matching the specified criteria.
##
## Service Name - Group[br]
## Service Operation - GetRandomGroupsMatching
##
## @param json_query The query criteria
## @param max_return The maximum number of groups to return
func get_random_groups_matching(json_query: Dictionary, max_return: int) -> Dictionary:
	var data := {
		OperationParam.GROUP_WHERE: json_query,
		OperationParam.GLOBAL_ENTITY_SERVICE_MAX_RETURN: max_return
	}
	return await _send(ServiceOperation.GROUP_GET_RANDOM_ENTITIES_MATCHING, data)

## Uses a paging system to iterate through group entities.
##
## Service Name - Group[br]
## Service Operation - GetGroupEntitiesPage
##
## @param context The context for the page request
func get_group_entities_page(context: Dictionary) -> Dictionary:
	var data := {OperationParam.GROUP_CONTEXT: context}
	return await _send(ServiceOperation.GROUP_ENTITIES_PAGE, data)

## Gets the page of group entities based on the encoded context and specified page offset.
##
## Service Name - Group[br]
## Service Operation - GetGroupEntitiesPageByOffset
##
## @param group_id The id of the group
## @param context The encoded context string returned from a previous get_group_entities_page call
## @param page_offset The positive or negative page offset to fetch
func get_group_entities_page_by_offset(group_id: String, context: String, page_offset: int) -> Dictionary:
	var data := {
		OperationParam.GROUP_ID: group_id,
		OperationParam.GROUP_CONTEXT: context,
		OperationParam.GROUP_PAGE_OFFSET: page_offset
	}
	return await _send(ServiceOperation.GROUP_ENTITIES_PAGE_BY_OFFSET, data)

## Updates the access control list for the group.
##
## Service Name - Group[br]
## Service Operation - UpdateGroupAcl
##
## @param group_id The id of the group
## @param acl The new access control list for the group
func update_group_acl(group_id: String, acl: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GROUP_ID: group_id,
		OperationParam.GROUP_ACL: acl
	}
	return await _send(ServiceOperation.GROUP_UPDATE_ACL, data)

## Updates the access control list for a group entity.
##
## Service Name - Group[br]
## Service Operation - UpdateGroupEntityAcl
##
## @param group_id The id of the group
## @param entity_id The id of the entity to update
## @param acl The new access control list for the entity
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
