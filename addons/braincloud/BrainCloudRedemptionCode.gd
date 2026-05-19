# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudRedemptionCode
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

func use_redemption_code(scan_code: String, code_type: String, json_custom_redemption_info: Dictionary) -> Dictionary:
	var data := {
		OperationParam.REDEMPTION_CODE_ID: scan_code,
		OperationParam.REDEMPTION_CODE_TYPE: code_type,
		OperationParam.REDEMPTION_CODE_CUSTOM_REDEMPTION_INFO: json_custom_redemption_info
	}
	return await _send(ServiceOperation.REDEMPTION_CODE_USE, data)

func invalidate_redemption_code(scan_code: String, code_type: String, invalid_reason_code: String, extra_json: Dictionary) -> Dictionary:
	var data := {
		OperationParam.REDEMPTION_CODE_ID: scan_code,
		OperationParam.REDEMPTION_CODE_TYPE: code_type,
		"invalidReasonCode": invalid_reason_code,
		"extraJson": extra_json
	}
	return await _send(ServiceOperation.REDEMPTION_CODE_INVALIDATE, data)

func custom_redeem_code(scan_code: String, code_type: String, custom_reward_code: String, json_custom_redemption_info: Dictionary) -> Dictionary:
	var data := {
		OperationParam.REDEMPTION_CODE_ID: scan_code,
		OperationParam.REDEMPTION_CODE_TYPE: code_type,
		"customRewardCode": custom_reward_code,
		OperationParam.REDEMPTION_CODE_CUSTOM_REDEMPTION_INFO: json_custom_redemption_info
	}
	return await _send(ServiceOperation.REDEMPTION_CODE_CUSTOM_REDEEM_CODE, data)

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.REDEMPTION_CODE, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
