# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudMail
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

## Sends a simple text email to the specified player.
##
## Service Name - mail[br]
## Service Operation - SEND_BASIC_EMAIL
##
## @param profile_id The user to send the email to
## @param subject The email subject
## @param body The email body
func send_basic_email(profile_id: String, subject: String, body: String) -> Dictionary:
	var data := {
		OperationParam.MAIL_PROFILE_ID: profile_id,
		OperationParam.MAIL_SUBJECT: subject,
		OperationParam.MAIL_BODY: body
	}
	return await _send(ServiceOperation.MAIL_SEND_BASIC_EMAIL, data)

## Sends an advanced email to the specified player.
##
## Service Name - mail[br]
## Service Operation - SEND_ADVANCED_EMAIL
##
## @param profile_id The user to send the email to
## @param json_service_params Parameters to send to the email service. See the documentation for
## a full list. http://getbraincloud.com/apidocs/apiref/#capi-mail
func send_advanced_email(profile_id: String, json_service_params: Dictionary) -> Dictionary:
	var data := {
		OperationParam.MAIL_PROFILE_ID: profile_id,
		OperationParam.MAIL_SERVICE_PARAMS: json_service_params
	}
	return await _send(ServiceOperation.MAIL_SEND_ADVANCED_EMAIL, data)

## Sends an advanced email to the specified email address.
##
## Service Name - mail[br]
## Service Operation - SEND_ADVANCED_EMAIL_BY_ADDRESS
##
## @param email_address The address to send the email to
## @param json_service_params Parameters to send to the email service. See the documentation for
## a full list. http://getbraincloud.com/apidocs/apiref/#capi-mail
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
