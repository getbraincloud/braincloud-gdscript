# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudGroupFile
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

func check_filename(group_id: String, folder_path: String, filename: String) -> Dictionary:
	var data := {
		OperationParam.GROUP_FILE_GROUP_ID: group_id,
		OperationParam.GROUP_FILE_FOLDER_PATH: folder_path,
		OperationParam.GROUP_FILE_FILENAME: filename
	}
	return await _send(ServiceOperation.GROUP_FILE_CHECK_FILENAME, data)

func copy_file(group_id: String, file_id: String, version: int, new_tree_id: String, tree_version: int, new_filename: String, overwrite_if_present: bool) -> Dictionary:
	var data := {
		OperationParam.GROUP_FILE_GROUP_ID: group_id,
		OperationParam.GROUP_FILE_FILE_ID: file_id,
		OperationParam.GROUP_FILE_VERSION: version,
		OperationParam.GROUP_FILE_NEW_TREE_ID: new_tree_id,
		"treeVersion": tree_version,
		OperationParam.GROUP_FILE_NEW_FILENAME: new_filename,
		OperationParam.GROUP_FILE_OVERWRITE_IF_PRESENT: overwrite_if_present
	}
	return await _send(ServiceOperation.GROUP_FILE_COPY, data)

func delete_file(group_id: String, file_id: String, version: int, filename: String) -> Dictionary:
	var data := {
		OperationParam.GROUP_FILE_GROUP_ID: group_id,
		OperationParam.GROUP_FILE_FILE_ID: file_id,
		OperationParam.GROUP_FILE_VERSION: version,
		OperationParam.GROUP_FILE_FILENAME: filename
	}
	return await _send(ServiceOperation.GROUP_FILE_DELETE, data)

func get_cdn_url(group_id: String, file_id: String) -> Dictionary:
	var data := {
		OperationParam.GROUP_FILE_GROUP_ID: group_id,
		OperationParam.GROUP_FILE_FILE_ID: file_id
	}
	return await _send(ServiceOperation.GROUP_FILE_GET_CDN_URL, data)

func get_file_info(group_id: String, file_id: String) -> Dictionary:
	var data := {
		OperationParam.GROUP_FILE_GROUP_ID: group_id,
		OperationParam.GROUP_FILE_FILE_ID: file_id
	}
	return await _send(ServiceOperation.GROUP_FILE_GET_FILE_INFO, data)

func get_file_list(group_id: String, folder_path: String, recurse: bool) -> Dictionary:
	var data := {
		OperationParam.GROUP_FILE_GROUP_ID: group_id,
		OperationParam.GROUP_FILE_FOLDER_PATH: folder_path,
		"recurse": recurse
	}
	return await _send(ServiceOperation.GROUP_FILE_GET_FILE_LIST, data)

func move_file(group_id: String, file_id: String, version: int, new_tree_id: String, tree_version: int, new_filename: String, overwrite_if_present: bool) -> Dictionary:
	var data := {
		OperationParam.GROUP_FILE_GROUP_ID: group_id,
		OperationParam.GROUP_FILE_FILE_ID: file_id,
		OperationParam.GROUP_FILE_VERSION: version,
		OperationParam.GROUP_FILE_NEW_TREE_ID: new_tree_id,
		"treeVersion": tree_version,
		OperationParam.GROUP_FILE_NEW_FILENAME: new_filename,
		OperationParam.GROUP_FILE_OVERWRITE_IF_PRESENT: overwrite_if_present
	}
	return await _send(ServiceOperation.GROUP_FILE_MOVE, data)

func move_user_file_to_group_file(user_cloud_path: String, user_cloud_filename: String, group_id: String, group_folder_path: String, group_filename: String, overwrite_if_present: bool) -> Dictionary:
	var data := {
		OperationParam.GROUP_FILE_USER_CLOUD_PATH: user_cloud_path,
		OperationParam.GROUP_FILE_USER_CLOUD_FILENAME: user_cloud_filename,
		OperationParam.GROUP_FILE_GROUP_ID: group_id,
		OperationParam.GROUP_FILE_FOLDER_PATH: group_folder_path,
		OperationParam.GROUP_FILE_FILENAME: group_filename,
		OperationParam.GROUP_FILE_OVERWRITE_IF_PRESENT: overwrite_if_present
	}
	return await _send(ServiceOperation.GROUP_FILE_MOVE_USER_FILE_TO_GROUP, data)

func update_file_info(group_id: String, file_id: String, version: int, new_filename: String, new_acl: Dictionary) -> Dictionary:
	var data := {
		OperationParam.GROUP_FILE_GROUP_ID: group_id,
		OperationParam.GROUP_FILE_FILE_ID: file_id,
		OperationParam.GROUP_FILE_VERSION: version,
		OperationParam.GROUP_FILE_NEW_FILENAME: new_filename,
		OperationParam.GROUP_FILE_ACL: new_acl
	}
	return await _send(ServiceOperation.GROUP_FILE_UPDATE, data)

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.GROUP_FILE, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
