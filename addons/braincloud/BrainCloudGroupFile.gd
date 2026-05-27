# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudGroupFile
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

## Checks if a filename exists for the provided path and name.
##
## Service Name - GroupFile[br]
## Service Operation - CheckFilenameExists
##
## @param group_id The ID of the group
## @param folder_path The path of the file
## @param filename The filename of the file
func check_filename(group_id: String, folder_path: String, filename: String) -> Dictionary:
	var data := {
		OperationParam.GROUP_FILE_GROUP_ID: group_id,
		OperationParam.GROUP_FILE_FOLDER_PATH: folder_path,
		OperationParam.GROUP_FILE_FILENAME: filename
	}
	return await _send(ServiceOperation.GROUP_FILE_CHECK_FILENAME, data)

## Copies a file.
##
## Service Name - GroupFile[br]
## Service Operation - CopyFile
##
## @param group_id The group ID
## @param file_id The file ID
## @param version The version of the file
## @param new_tree_id The destination tree ID
## @param tree_version The destination tree version
## @param new_filename The new filename
## @param overwrite_if_present Whether to overwrite if a file already exists at the destination
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

## Deletes a file.
##
## Service Name - GroupFile[br]
## Service Operation - DeleteFile
##
## @param group_id The group ID
## @param file_id The file ID
## @param version The version of the file
## @param filename The filename of the file
func delete_file(group_id: String, file_id: String, version: int, filename: String) -> Dictionary:
	var data := {
		OperationParam.GROUP_FILE_GROUP_ID: group_id,
		OperationParam.GROUP_FILE_FILE_ID: file_id,
		OperationParam.GROUP_FILE_VERSION: version,
		OperationParam.GROUP_FILE_FILENAME: filename
	}
	return await _send(ServiceOperation.GROUP_FILE_DELETE, data)

## Returns the CDN url for a file. For clients that cannot handle redirect.
##
## Service Name - GroupFile[br]
## Service Operation - GetCdnUrl
##
## @param group_id The group ID
## @param file_id The file ID
func get_cdn_url(group_id: String, file_id: String) -> Dictionary:
	var data := {
		OperationParam.GROUP_FILE_GROUP_ID: group_id,
		OperationParam.GROUP_FILE_FILE_ID: file_id
	}
	return await _send(ServiceOperation.GROUP_FILE_GET_CDN_URL, data)

## Returns information on a file using fileId.
##
## Service Name - GroupFile[br]
## Service Operation - GetFileInfo
##
## @param group_id The group ID
## @param file_id The file ID
func get_file_info(group_id: String, file_id: String) -> Dictionary:
	var data := {
		OperationParam.GROUP_FILE_GROUP_ID: group_id,
		OperationParam.GROUP_FILE_FILE_ID: file_id
	}
	return await _send(ServiceOperation.GROUP_FILE_GET_FILE_INFO, data)

## Returns a list of files in the given folder path.
##
## Service Name - GroupFile[br]
## Service Operation - GetFileList
##
## @param group_id The group ID
## @param folder_path The folder path to list files from
## @param recurse Whether to recurse into sub-directories
func get_file_list(group_id: String, folder_path: String, recurse: bool) -> Dictionary:
	var data := {
		OperationParam.GROUP_FILE_GROUP_ID: group_id,
		OperationParam.GROUP_FILE_FOLDER_PATH: folder_path,
		"recurse": recurse
	}
	return await _send(ServiceOperation.GROUP_FILE_GET_FILE_LIST, data)

## Moves a file to a new location within group storage.
##
## Service Name - GroupFile[br]
## Service Operation - MoveFile
##
## @param group_id The group ID
## @param file_id The file ID
## @param version The version of the file
## @param new_tree_id The destination tree ID
## @param tree_version The destination tree version
## @param new_filename The new filename
## @param overwrite_if_present Whether to overwrite if a file already exists at the destination
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

## Moves a file from user space to group space.
##
## Service Name - GroupFile[br]
## Service Operation - MoveUserToGroupFile
##
## @param user_cloud_path The user's cloud path of the file
## @param user_cloud_filename The user's cloud filename
## @param group_id The destination group ID
## @param group_folder_path The destination folder path in group storage
## @param group_filename The destination filename in group storage
## @param overwrite_if_present Whether to overwrite if a file already exists at the destination
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

## Updates information on a file given its fileId.
##
## Service Name - GroupFile[br]
## Service Operation - UpdateFileInfo
##
## @param group_id The group ID
## @param file_id The file ID
## @param version The version of the file
## @param new_filename The new filename
## @param new_acl The new access control list
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
