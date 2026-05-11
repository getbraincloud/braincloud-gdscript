# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudAppStore
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

func verify_purchase(store_id: String, receipt_data: Dictionary) -> Dictionary:
	var data := {
		OperationParam.APP_STORE_STORE_ID: store_id,
		OperationParam.APP_STORE_RECEIPT_DATA: receipt_data
	}
	return await _send(ServiceOperation.APP_STORE_VERIFY_PURCHASE, data)

func get_eligible_promotions() -> Dictionary:
	return await _send(ServiceOperation.APP_STORE_GET_ELIGIBLE_PROMOTIONS, {})

func refresh_promotions() -> Dictionary:
	return await _send(ServiceOperation.APP_STORE_REFRESH_PROMOTIONS, {})

func start_purchase(store_id: String, purchased_item_id: String) -> Dictionary:
	var data := {
		OperationParam.APP_STORE_STORE_ID: store_id,
		OperationParam.APP_STORE_PURCHASED_ITEM_ID: purchased_item_id
	}
	return await _send(ServiceOperation.APP_STORE_START_PURCHASE, data)

func finalize_purchase(store_id: String, transaction_id: String, transaction_data: Dictionary) -> Dictionary:
	var data := {
		OperationParam.APP_STORE_STORE_ID: store_id,
		OperationParam.APP_STORE_TRANSACTION_ID: transaction_id,
		OperationParam.APP_STORE_TRANS_INFO: transaction_data
	}
	return await _send(ServiceOperation.APP_STORE_FINALIZE_PURCHASE, data)

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.APP_STORE, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
