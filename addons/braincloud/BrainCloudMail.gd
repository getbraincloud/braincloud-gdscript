# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudMail
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

func send_basic_email(profile_id: String, subject: String, body: String) -> Dictionary:
	var data := {
		OperationParam.MAIL_PROFILE_ID: profile_id,
		OperationParam.MAIL_SUBJECT: subject,
		OperationParam.MAIL_BODY: body
	}
	return await _send(ServiceOperation.MAIL_SEND_BASIC_EMAIL, data)

func send_advanced_email(profile_id: String, json_service_params: Dictionary) -> Dictionary:
	var data := {
		OperationParam.MAIL_PROFILE_ID: profile_id,
		OperationParam.MAIL_SERVICE_PARAMS: json_service_params
	}
	return await _send(ServiceOperation.MAIL_SEND_ADVANCED_EMAIL, data)

func send_advanced_email_by_address(email_address: String, json_service_params: Dictionary) -> Dictionary:
	var data := {
		OperationParam.MAIL_TO_ADDRESS: email_address,
		OperationParam.MAIL_SERVICE_PARAMS: json_service_params
	}
	return await _send(ServiceOperation.MAIL_SEND_ADVANCED_EMAIL_BY_ADDRESS, data)

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.MAIL, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
