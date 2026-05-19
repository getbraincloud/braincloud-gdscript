# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudUserItems
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

func award_user_item(def_id: String, quantity: int, include_def: bool) -> Dictionary:
	var data := {
		OperationParam.USER_ITEMS_ITEM_DEF_ID: def_id,
		OperationParam.USER_ITEMS_QUANTITY: quantity,
		OperationParam.USER_ITEMS_INCLUDE_DEF: include_def
	}
	return await _send(ServiceOperation.USER_ITEMS_AWARD_USER_ITEM, data)

func drop_user_item(user_item_id: String, quantity: int, include_def: bool) -> Dictionary:
	var data := {
		OperationParam.USER_ITEMS_USER_ITEM_ID: user_item_id,
		OperationParam.USER_ITEMS_QUANTITY: quantity,
		OperationParam.USER_ITEMS_INCLUDE_DEF: include_def
	}
	return await _send(ServiceOperation.USER_ITEMS_DROP_USER_ITEM, data)

func get_user_items_page(context: Dictionary, include_def: bool) -> Dictionary:
	var data := {
		OperationParam.USER_ITEMS_CONTEXT: context,
		OperationParam.USER_ITEMS_INCLUDE_DEF: include_def
	}
	return await _send(ServiceOperation.USER_ITEMS_GET_USER_ITEMS_PAGE, data)

func get_user_items_page_offset(context: String, page_offset: int, include_def: bool) -> Dictionary:
	var data := {
		OperationParam.USER_ITEMS_CONTEXT: context,
		OperationParam.USER_ITEMS_PAGE_OFFSET: page_offset,
		OperationParam.USER_ITEMS_INCLUDE_DEF: include_def
	}
	return await _send(ServiceOperation.USER_ITEMS_GET_USER_ITEMS_PAGE_OFFSET, data)

func get_user_item(user_item_id: String, include_def: bool) -> Dictionary:
	var data := {
		OperationParam.USER_ITEMS_USER_ITEM_ID: user_item_id,
		OperationParam.USER_ITEMS_INCLUDE_DEF: include_def
	}
	return await _send(ServiceOperation.USER_ITEMS_GET_USER_ITEM, data)

func give_user_item_to(profile_id: String, user_item_id: String, quantity: int, trade_in_item_id: String, trade_in_quantity: int, version: int = -1, immediate: bool = true) -> Dictionary:
	var data := {
		OperationParam.USER_ITEMS_TO_PROFILE_ID: profile_id,
		OperationParam.USER_ITEMS_USER_ITEM_ID: user_item_id,
		OperationParam.USER_ITEMS_QUANTITY: quantity,
		OperationParam.USER_ITEMS_VERSION: version,
		OperationParam.USER_ITEMS_IMMEDIATE: immediate,
		"tradeInItemId": trade_in_item_id,
		"tradeInQuantity": trade_in_quantity
	}
	return await _send(ServiceOperation.USER_ITEMS_GIVE_USER_ITEM_TO, data)

func purchase_user_item(def_id: String, quantity: int, shop_id: String, include_def: bool) -> Dictionary:
	var data := {
		OperationParam.USER_ITEMS_ITEM_DEF_ID: def_id,
		OperationParam.USER_ITEMS_QUANTITY: quantity,
		OperationParam.USER_ITEMS_SHOP_ID: shop_id,
		OperationParam.USER_ITEMS_INCLUDE_DEF: include_def
	}
	return await _send(ServiceOperation.USER_ITEMS_PURCHASE_USER_ITEM, data)

func redeem_user_item(user_item_id: String, quantity: int, include_def: bool) -> Dictionary:
	var data := {
		OperationParam.USER_ITEMS_USER_ITEM_ID: user_item_id,
		OperationParam.USER_ITEMS_QUANTITY: quantity,
		OperationParam.USER_ITEMS_INCLUDE_DEF: include_def
	}
	return await _send(ServiceOperation.USER_ITEMS_REDEEM_USER_ITEM, data)

func sell_user_item(user_item_id: String, quantity: int, shop_id: String, include_def: bool) -> Dictionary:
	var data := {
		OperationParam.USER_ITEMS_USER_ITEM_ID: user_item_id,
		OperationParam.USER_ITEMS_QUANTITY: quantity,
		OperationParam.USER_ITEMS_SHOP_ID: shop_id,
		OperationParam.USER_ITEMS_INCLUDE_DEF: include_def
	}
	return await _send(ServiceOperation.USER_ITEMS_SELL_USER_ITEM, data)

func update_user_item_data(user_item_id: String, new_item_data: Dictionary, version: int = -1) -> Dictionary:
	var data := {
		OperationParam.USER_ITEMS_USER_ITEM_ID: user_item_id,
		OperationParam.USER_ITEMS_VERSION: version,
		"newItemData": new_item_data
	}
	return await _send(ServiceOperation.USER_ITEMS_UPDATE_USER_ITEM_DATA, data)

func use_user_item(user_item_id: String, quantity: int, new_item_data: Dictionary, include_def: bool) -> Dictionary:
	var data := {
		OperationParam.USER_ITEMS_USER_ITEM_ID: user_item_id,
		OperationParam.USER_ITEMS_QUANTITY: quantity,
		"newItemData": new_item_data,
		OperationParam.USER_ITEMS_INCLUDE_DEF: include_def
	}
	return await _send(ServiceOperation.USER_ITEMS_USE_USER_ITEM, data)

func publish_user_item_to_blockchain(user_item_id: String, blockchain_config: String) -> Dictionary:
	var data := {
		OperationParam.USER_ITEMS_USER_ITEM_ID: user_item_id,
		OperationParam.BLOCK_CHAIN_CONFIG: blockchain_config
	}
	return await _send(ServiceOperation.USER_ITEMS_PUBLISH_USER_ITEM_TO_BLOCKCHAIN, data)

func refresh_blockchain_user_items(blockchain_config: String) -> Dictionary:
	var data := {
		OperationParam.BLOCK_CHAIN_CONFIG: blockchain_config
	}
	return await _send(ServiceOperation.USER_ITEMS_REFRESH_BLOCKCHAIN_USER_ITEMS, data)

func remove_user_item_from_blockchain(user_item_id: String, blockchain_config: String) -> Dictionary:
	var data := {
		OperationParam.USER_ITEMS_USER_ITEM_ID: user_item_id,
		OperationParam.BLOCK_CHAIN_CONFIG: blockchain_config
	}
	return await _send(ServiceOperation.USER_ITEMS_REMOVE_USER_ITEM_FROM_BLOCKCHAIN, data)

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.USER_ITEMS, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
