# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudVirtualCurrency
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

func award_currency(vc_id: String, amount: int) -> Dictionary:
	var data := {
		OperationParam.VIRTUAL_CURRENCY_ID: vc_id,
		OperationParam.VIRTUAL_CURRENCY_AMOUNT: amount
	}
	return await _send(ServiceOperation.VIRTUAL_CURRENCY_AWARD, data)

func consume_currency(vc_id: String, amount: int) -> Dictionary:
	var data := {
		OperationParam.VIRTUAL_CURRENCY_ID: vc_id,
		OperationParam.VIRTUAL_CURRENCY_AMOUNT: amount
	}
	return await _send(ServiceOperation.VIRTUAL_CURRENCY_CONSUME, data)

func reset_currency() -> Dictionary:
	return await _send(ServiceOperation.VIRTUAL_CURRENCY_RESET, {})

func get_currency(vc_id: String) -> Dictionary:
	var data := {
		OperationParam.VIRTUAL_CURRENCY_ID: vc_id
	}
	return await _send(ServiceOperation.VIRTUAL_CURRENCY_GET, data)

func get_parent_currency(level_name: String) -> Dictionary:
	var data := {
		OperationParam.VIRTUAL_CURRENCY_PARENT: level_name
	}
	return await _send(ServiceOperation.VIRTUAL_CURRENCY_GET_PARENT, data)

func get_peer_currency(peer_code: String) -> Dictionary:
	var data := {
		OperationParam.VIRTUAL_CURRENCY_PEER: peer_code
	}
	return await _send(ServiceOperation.VIRTUAL_CURRENCY_GET_PEER, data)

func get_sales_inventory(platform: String, user_currency: String) -> Dictionary:
	var data := {
		"platform": platform,
		"userCurrency": user_currency
	}
	return await _send(ServiceOperation.VIRTUAL_CURRENCY_GET_SALES_INVENTORY, data)

func get_sales_inventory_by_category(platform: String, user_currency: String, category: String) -> Dictionary:
	var data := {
		"platform": platform,
		"userCurrency": user_currency,
		"category": category
	}
	return await _send(ServiceOperation.VIRTUAL_CURRENCY_GET_SALES_INVENTORY_BY_CATEGORY, data)

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.VIRTUAL_CURRENCY, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
