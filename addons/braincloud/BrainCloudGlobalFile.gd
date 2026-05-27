# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudGlobalFile
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

## Returns the complete info for the specified file given its fileId.
##
## Service Name - GlobalFile[br]
## Service Operation - GetFileInfo
##
## @param file_id The file id
func get_file_info(file_id: String) -> Dictionary:
	var data := {
		OperationParam.GLOBAL_FILE_FILE_ID: file_id
	}
	return await _send(ServiceOperation.GET_FILE_INFO, data)

## Returns the complete info for the specified file, without having to look up the fileId first.
##
## Service Name - GlobalFile[br]
## Service Operation - GetFileInfoSimple
##
## @param folder_path The folder path of the file
## @param filename The filename of the file
func get_file_info_simple(folder_path: String, filename: String) -> Dictionary:
	var data := {
		OperationParam.GLOBAL_FILE_FOLDER_PATH: folder_path,
		OperationParam.GLOBAL_FILE_FILENAME: filename
	}
	return await _send(ServiceOperation.GET_FILE_INFO_SIMPLE, data)

## Returns files at the given folder path.
##
## Service Name - GlobalFile[br]
## Service Operation - GetGlobalFileList
##
## @param folder_path The folder path to list files from
## @param recurse Whether to recurse into sub-directories
func get_global_file_list(folder_path: String, recurse: bool) -> Dictionary:
	var data := {
		OperationParam.GLOBAL_FILE_FOLDER_PATH: folder_path,
		OperationParam.GLOBAL_FILE_RECURSIVE: recurse
	}
	return await _send("GET_GLOBAL_FILE_LIST", data)

## Returns the CDN url of the specified file.
##
## Service Name - GlobalFile[br]
## Service Operation - GetCdnUrl
##
## @param file_id The file id
func get_cdn_url_for_file(file_id: String) -> Dictionary:
	var data := {
		OperationParam.GLOBAL_FILE_FILE_ID: file_id
	}
	return await _send("GET_CDN_URL", data)

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.GLOBAL_FILE, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
