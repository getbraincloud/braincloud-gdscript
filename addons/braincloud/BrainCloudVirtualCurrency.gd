# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudVirtualCurrency
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

## Awards currency to the player.
## Method is recommended to be used in Cloud Code only for security.
## If needed client side, enable 'Allow Currency Calls from Client' on the brainCloud dashboard.
##
## Service Name - VirtualCurrency[br]
## Service Operation - AwardCurrency
##
## @param vc_id The currency type id
## @param amount The amount to award
func award_currency(vc_id: String, amount: int) -> Dictionary:
	var data := {
		OperationParam.VIRTUAL_CURRENCY_ID: vc_id,
		OperationParam.VIRTUAL_CURRENCY_AMOUNT: amount
	}
	return await _send(ServiceOperation.VIRTUAL_CURRENCY_AWARD, data)

## Consumes currency from the player.
## Method is recommended to be used in Cloud Code only for security.
## If needed client side, enable 'Allow Currency Calls from Client' on the brainCloud dashboard.
##
## Service Name - VirtualCurrency[br]
## Service Operation - ConsumeCurrency
##
## @param vc_id The currency type id
## @param amount The amount to consume
func consume_currency(vc_id: String, amount: int) -> Dictionary:
	var data := {
		OperationParam.VIRTUAL_CURRENCY_ID: vc_id,
		OperationParam.VIRTUAL_CURRENCY_AMOUNT: amount
	}
	return await _send(ServiceOperation.VIRTUAL_CURRENCY_CONSUME, data)

## Resets the player's currency to zero.
##
## Service Name - VirtualCurrency[br]
## Service Operation - ResetCurrency
func reset_currency() -> Dictionary:
	return await _send(ServiceOperation.VIRTUAL_CURRENCY_RESET, {})

## Retrieves the user's currency account.
##
## Service Name - VirtualCurrency[br]
## Service Operation - GetCurrency
##
## @param vc_id The currency type id, or empty string to retrieve all currencies
func get_currency(vc_id: String) -> Dictionary:
	var data := {
		OperationParam.VIRTUAL_CURRENCY_ID: vc_id
	}
	return await _send(ServiceOperation.VIRTUAL_CURRENCY_GET, data)

## Retrieves the parent user's currency account.
##
## Service Name - VirtualCurrency[br]
## Service Operation - GetParentCurrency
##
## @param level_name The level name of the parent app
func get_parent_currency(level_name: String) -> Dictionary:
	var data := {
		OperationParam.VIRTUAL_CURRENCY_PARENT: level_name
	}
	return await _send(ServiceOperation.VIRTUAL_CURRENCY_GET_PARENT, data)

## Retrieves the peer user's currency account.
##
## Service Name - VirtualCurrency[br]
## Service Operation - GetPeerCurrency
##
## @param peer_code The peer service code
func get_peer_currency(peer_code: String) -> Dictionary:
	var data := {
		OperationParam.VIRTUAL_CURRENCY_PEER: peer_code
	}
	return await _send(ServiceOperation.VIRTUAL_CURRENCY_GET_PEER, data)

## Gets the active sales inventory for the passed-in platform and currency type.
##
## Service Name - VirtualCurrency[br]
## Service Operation - GetSalesInventory
##
## @param platform The store platform (e.g. "itunes", "googlePlay", "steam")
## @param user_currency The currency type to retrieve the sales inventory for
func get_sales_inventory(platform: String, user_currency: String) -> Dictionary:
	var data := {
		"platform": platform,
		"userCurrency": user_currency
	}
	return await _send(ServiceOperation.VIRTUAL_CURRENCY_GET_SALES_INVENTORY, data)

## Gets the active sales inventory filtered by category.
##
## Service Name - VirtualCurrency[br]
## Service Operation - GetSalesInventoryByCategory
##
## @param platform The store platform (e.g. "itunes", "googlePlay", "steam")
## @param user_currency The currency type to retrieve the sales inventory for
## @param category The product category
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
