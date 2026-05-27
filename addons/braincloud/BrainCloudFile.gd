# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudFile
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

## Prepares a user file upload. Returns an uploadId that must be used to
## complete the actual binary upload separately.
##
## Service Name - File[br]
## Service Operation - PREPARE_USER_UPLOAD
##
## @param cloud_path The desired cloud path of the file
## @param cloud_filename The desired cloud filename of the file
## @param shareable True if the file is shareable
## @param replace_if_exists Whether to replace file if it exists
## @param file_data The raw file data as a PackedByteArray
##
## Significant error codes:[br]
## 40429 - File maximum file size exceeded[br]
## 40430 - File exists, replaceIfExists not set
func upload_file_from_memory(cloud_path: String, cloud_filename: String, shareable: bool, replace_if_exists: bool, file_data: PackedByteArray) -> Dictionary:
	var data := {
		OperationParam.PREPARE_USER_UPLOAD_CLOUD_PATH: cloud_path,
		OperationParam.PREPARE_USER_UPLOAD_CLOUD_FILENAME: cloud_filename,
		OperationParam.PREPARE_USER_UPLOAD_SHAREABLE: shareable,
		OperationParam.PREPARE_USER_UPLOAD_REPLACE_IF_EXISTS: replace_if_exists,
		OperationParam.PREPARE_USER_UPLOAD_FILE_SIZE: file_data.size()
	}
	return await _send(ServiceOperation.PREPARE_USER_UPLOAD, data)

## Deletes a single user file.
##
## Service Name - File[br]
## Service Operation - DELETE_USER_FILE
##
## @param cloud_path The cloud path of the file
## @param cloud_filename The cloud filename of the file
##
## Significant error codes:[br]
## 40431 - Cloud storage service error[br]
## 40432 - File does not exist
func delete_user_file(cloud_path: String, cloud_filename: String) -> Dictionary:
	var data := {
		OperationParam.PREPARE_USER_UPLOAD_CLOUD_PATH: cloud_path,
		OperationParam.PREPARE_USER_UPLOAD_CLOUD_FILENAME: cloud_filename
	}
	return await _send(ServiceOperation.DELETE_USER_FILE, data)

## Deletes multiple user files at the given cloud path.
##
## Service Name - File[br]
## Service Operation - DELETE_USER_FILES
##
## @param cloud_path The cloud path to delete files from
## @param recursive Whether to recurse into sub-directories
func delete_user_files(cloud_path: String, recursive: bool) -> Dictionary:
	var data := {
		OperationParam.PREPARE_USER_UPLOAD_CLOUD_PATH: cloud_path,
		OperationParam.PREPARE_USER_UPLOAD_RECURSIVE_DELETE: recursive
	}
	return await _send(ServiceOperation.DELETE_USER_FILES, data)

## Lists user files from the given cloud path.
##
## Service Name - File[br]
## Service Operation - LIST_USER_FILES
##
## @param cloud_path The cloud path to list files from
## @param recursive Whether to recurse into sub-directories
func get_file_list(cloud_path: String, recursive: bool) -> Dictionary:
	var data := {
		OperationParam.PREPARE_USER_UPLOAD_CLOUD_PATH: cloud_path,
		OperationParam.PREPARE_USER_UPLOAD_RECURSIVE_DELETE: recursive
	}
	return await _send(ServiceOperation.LIST_USER_FILES, data)

## Returns the CDN url for a file object.
##
## Service Name - File[br]
## Service Operation - GET_CDN_URL
##
## @param cloud_path The cloud path of the file
## @param cloud_filename The cloud filename of the file
func get_cdn_url_for_file(cloud_path: String, cloud_filename: String) -> Dictionary:
	var data := {
		OperationParam.PREPARE_USER_UPLOAD_CLOUD_PATH: cloud_path,
		OperationParam.PREPARE_USER_UPLOAD_CLOUD_FILENAME: cloud_filename
	}
	return await _send("GET_CDN_URL", data)

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.FILE, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
