# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudFile
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

## Initiates a file upload by sending PREPARE_USER_UPLOAD to the server.
## Actual binary upload must be handled separately using the returned uploadId.
func upload_file_from_memory(cloud_path: String, cloud_filename: String, shareable: bool, replace_if_exists: bool, file_data: PackedByteArray) -> Dictionary:
	var data := {
		OperationParam.PREPARE_USER_UPLOAD_CLOUD_PATH: cloud_path,
		OperationParam.PREPARE_USER_UPLOAD_CLOUD_FILENAME: cloud_filename,
		OperationParam.PREPARE_USER_UPLOAD_SHAREABLE: shareable,
		OperationParam.PREPARE_USER_UPLOAD_REPLACE_IF_EXISTS: replace_if_exists,
		OperationParam.PREPARE_USER_UPLOAD_FILE_SIZE: file_data.size()
	}
	return await _send(ServiceOperation.PREPARE_USER_UPLOAD, data)

func delete_user_file(cloud_path: String, cloud_filename: String) -> Dictionary:
	var data := {
		OperationParam.PREPARE_USER_UPLOAD_CLOUD_PATH: cloud_path,
		OperationParam.PREPARE_USER_UPLOAD_CLOUD_FILENAME: cloud_filename
	}
	return await _send(ServiceOperation.DELETE_USER_FILE, data)

func delete_user_files(cloud_path: String, recursive: bool) -> Dictionary:
	var data := {
		OperationParam.PREPARE_USER_UPLOAD_CLOUD_PATH: cloud_path,
		OperationParam.PREPARE_USER_UPLOAD_RECURSIVE_DELETE: recursive
	}
	return await _send(ServiceOperation.DELETE_USER_FILES, data)

func get_file_list(cloud_path: String, recursive: bool) -> Dictionary:
	var data := {
		OperationParam.PREPARE_USER_UPLOAD_CLOUD_PATH: cloud_path,
		OperationParam.PREPARE_USER_UPLOAD_RECURSIVE_DELETE: recursive
	}
	return await _send(ServiceOperation.LIST_USER_FILES, data)

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
