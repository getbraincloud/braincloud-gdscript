# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudUserItems
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

## Awards a unique item to the specified player.
##
## Service Name - UserItems[br]
## Service Operation - AwardUserItem
##
## @param def_id The catalog item's definition id
## @param quantity The quantity of the item to award
## @param include_def Whether to include the item definition in the response
func award_user_item(def_id: String, quantity: int, include_def: bool) -> Dictionary:
	var data := {
		OperationParam.USER_ITEMS_ITEM_DEF_ID: def_id,
		OperationParam.USER_ITEMS_QUANTITY: quantity,
		OperationParam.USER_ITEMS_INCLUDE_DEF: include_def
	}
	return await _send(ServiceOperation.USER_ITEMS_AWARD_USER_ITEM, data)

## Allows item(s) to be consumed if the item use flag is set, or returns the associated currencies.
##
## Service Name - UserItems[br]
## Service Operation - DropUserItem
##
## @param user_item_id The unique id of the user item
## @param quantity The quantity of the item to drop
## @param include_def Whether to include the item definition in the response
func drop_user_item(user_item_id: String, quantity: int, include_def: bool) -> Dictionary:
	var data := {
		OperationParam.USER_ITEMS_USER_ITEM_ID: user_item_id,
		OperationParam.USER_ITEMS_QUANTITY: quantity,
		OperationParam.USER_ITEMS_INCLUDE_DEF: include_def
	}
	return await _send(ServiceOperation.USER_ITEMS_DROP_USER_ITEM, data)

## Retrieves a page of the user's inventory from the server based on the context.
##
## Service Name - UserItems[br]
## Service Operation - GetUserItemsPage
##
## @param context The json context for the page request
## @param include_def Whether to include item definitions in the response
func get_user_items_page(context: Dictionary, include_def: bool) -> Dictionary:
	var data := {
		OperationParam.USER_ITEMS_CONTEXT: context,
		OperationParam.USER_ITEMS_INCLUDE_DEF: include_def
	}
	return await _send(ServiceOperation.USER_ITEMS_GET_USER_ITEMS_PAGE, data)

## Retrieves a page of the user's inventory from the server based on the encoded context and specified page offset.
##
## Service Name - UserItems[br]
## Service Operation - GetUserItemsPageOffset
##
## @param context The encoded context string returned from a previous get_user_items_page call
## @param page_offset The positive or negative page offset to fetch
## @param include_def Whether to include item definitions in the response
func get_user_items_page_offset(context: String, page_offset: int, include_def: bool) -> Dictionary:
	var data := {
		OperationParam.USER_ITEMS_CONTEXT: context,
		OperationParam.USER_ITEMS_PAGE_OFFSET: page_offset,
		OperationParam.USER_ITEMS_INCLUDE_DEF: include_def
	}
	return await _send(ServiceOperation.USER_ITEMS_GET_USER_ITEMS_PAGE_OFFSET, data)

## Retrieves the identified user item from the server.
##
## Service Name - UserItems[br]
## Service Operation - GetUserItem
##
## @param user_item_id The unique id of the user item
## @param include_def Whether to include the item definition in the response
func get_user_item(user_item_id: String, include_def: bool) -> Dictionary:
	var data := {
		OperationParam.USER_ITEMS_USER_ITEM_ID: user_item_id,
		OperationParam.USER_ITEMS_INCLUDE_DEF: include_def
	}
	return await _send(ServiceOperation.USER_ITEMS_GET_USER_ITEM, data)

## Gifts an item to the specified player.
##
## Service Name - UserItems[br]
## Service Operation - GiveUserItemTo
##
## @param profile_id The profile id of the recipient player
## @param user_item_id The unique id of the user item to give
## @param quantity The quantity of the item to give
## @param trade_in_item_id The unique id of the item to trade in (if any)
## @param trade_in_quantity The quantity of the trade-in item
## @param version The version of the item (-1 to bypass version check)
## @param immediate Whether to transfer the item immediately
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

## Purchases a specific item from the specified store.
##
## Service Name - UserItems[br]
## Service Operation - PurchaseUserItem
##
## @param def_id The catalog item's definition id
## @param quantity The quantity of the item to purchase
## @param shop_id The id of the shop from which to purchase
## @param include_def Whether to include the item definition in the response
func purchase_user_item(def_id: String, quantity: int, shop_id: String, include_def: bool) -> Dictionary:
	var data := {
		OperationParam.USER_ITEMS_ITEM_DEF_ID: def_id,
		OperationParam.USER_ITEMS_QUANTITY: quantity,
		OperationParam.USER_ITEMS_SHOP_ID: shop_id,
		OperationParam.USER_ITEMS_INCLUDE_DEF: include_def
	}
	return await _send(ServiceOperation.USER_ITEMS_PURCHASE_USER_ITEM, data)

## Redeems the specified item.
##
## Service Name - UserItems[br]
## Service Operation - RedeemUserItem
##
## @param user_item_id The unique id of the user item
## @param quantity The quantity of the item to redeem
## @param include_def Whether to include the item definition in the response
func redeem_user_item(user_item_id: String, quantity: int, include_def: bool) -> Dictionary:
	var data := {
		OperationParam.USER_ITEMS_USER_ITEM_ID: user_item_id,
		OperationParam.USER_ITEMS_QUANTITY: quantity,
		OperationParam.USER_ITEMS_INCLUDE_DEF: include_def
	}
	return await _send(ServiceOperation.USER_ITEMS_REDEEM_USER_ITEM, data)

## Sells a specified amount of a specific user item.
##
## Service Name - UserItems[br]
## Service Operation - SellUserItem
##
## @param user_item_id The unique id of the user item
## @param quantity The quantity of the item to sell
## @param shop_id The id of the shop to sell to
## @param include_def Whether to include the item definition in the response
func sell_user_item(user_item_id: String, quantity: int, shop_id: String, include_def: bool) -> Dictionary:
	var data := {
		OperationParam.USER_ITEMS_USER_ITEM_ID: user_item_id,
		OperationParam.USER_ITEMS_QUANTITY: quantity,
		OperationParam.USER_ITEMS_SHOP_ID: shop_id,
		OperationParam.USER_ITEMS_INCLUDE_DEF: include_def
	}
	return await _send(ServiceOperation.USER_ITEMS_SELL_USER_ITEM, data)

## Updates the item data on the specified user item.
##
## Service Name - UserItems[br]
## Service Operation - UpdateUserItemData
##
## @param user_item_id The unique id of the user item
## @param new_item_data The new item data to set
## @param version The version of the item (-1 to bypass version check)
func update_user_item_data(user_item_id: String, new_item_data: Dictionary, version: int = -1) -> Dictionary:
	var data := {
		OperationParam.USER_ITEMS_USER_ITEM_ID: user_item_id,
		OperationParam.USER_ITEMS_VERSION: version,
		"newItemData": new_item_data
	}
	return await _send(ServiceOperation.USER_ITEMS_UPDATE_USER_ITEM_DATA, data)

## Uses the specified item in the player's inventory.
##
## Service Name - UserItems[br]
## Service Operation - UseUserItem
##
## @param user_item_id The unique id of the user item
## @param quantity The quantity of the item to use
## @param new_item_data The new item data to set after use
## @param include_def Whether to include the item definition in the response
func use_user_item(user_item_id: String, quantity: int, new_item_data: Dictionary, include_def: bool) -> Dictionary:
	var data := {
		OperationParam.USER_ITEMS_USER_ITEM_ID: user_item_id,
		OperationParam.USER_ITEMS_QUANTITY: quantity,
		"newItemData": new_item_data,
		OperationParam.USER_ITEMS_INCLUDE_DEF: include_def
	}
	return await _send(ServiceOperation.USER_ITEMS_USE_USER_ITEM, data)

## Publishes the specified user item to the blockchain.
##
## Service Name - UserItems[br]
## Service Operation - PublishUserItemToBlockchain
##
## @param user_item_id The unique id of the user item
## @param blockchain_config The blockchain configuration identifier
func publish_user_item_to_blockchain(user_item_id: String, blockchain_config: String) -> Dictionary:
	var data := {
		OperationParam.USER_ITEMS_USER_ITEM_ID: user_item_id,
		OperationParam.BLOCK_CHAIN_CONFIG: blockchain_config
	}
	return await _send(ServiceOperation.USER_ITEMS_PUBLISH_USER_ITEM_TO_BLOCKCHAIN, data)

## Retrieves the blockchain items associated with the caller's profile.
##
## Service Name - UserItems[br]
## Service Operation - RefreshBlockchainUserItems
##
## @param blockchain_config The blockchain configuration identifier
func refresh_blockchain_user_items(blockchain_config: String) -> Dictionary:
	var data := {
		OperationParam.BLOCK_CHAIN_CONFIG: blockchain_config
	}
	return await _send(ServiceOperation.USER_ITEMS_REFRESH_BLOCKCHAIN_USER_ITEMS, data)

## Removes the specified user item from the blockchain.
##
## Service Name - UserItems[br]
## Service Operation - RemoveUserItemFromBlockchain
##
## @param user_item_id The unique id of the user item
## @param blockchain_config The blockchain configuration identifier
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
