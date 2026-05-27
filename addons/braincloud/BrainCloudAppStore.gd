# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudAppStore
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

## Verifies that a purchase was properly made at the store.
##
## Service Name - AppStore[br]
## Service Operation - VerifyPurchase
##
## @param store_id The store platform (e.g. "itunes", "googlePlay", "steam")
## @param receipt_data The specific store receipt data required for verification
func verify_purchase(store_id: String, receipt_data: Dictionary) -> Dictionary:
	var data := {
		OperationParam.APP_STORE_STORE_ID: store_id,
		OperationParam.APP_STORE_RECEIPT_DATA: receipt_data
	}
	return await _send(ServiceOperation.APP_STORE_VERIFY_PURCHASE, data)

## Returns the eligible promotions for the player.
##
## Service Name - AppStore[br]
## Service Operation - EligiblePromotions
func get_eligible_promotions() -> Dictionary:
	return await _send(ServiceOperation.APP_STORE_GET_ELIGIBLE_PROMOTIONS, {})

## Returns up-to-date eligible promotions for the user and a promotionsRefreshed flag
## indicating whether the user's promotion info required refreshing.
##
## Service Name - AppStore[br]
## Service Operation - RefreshPromotions
func refresh_promotions() -> Dictionary:
	return await _send(ServiceOperation.APP_STORE_REFRESH_PROMOTIONS, {})

## Starts a two-staged purchase transaction.
##
## Service Name - AppStore[br]
## Service Operation - StartPurchase
##
## @param store_id The store platform (e.g. "itunes", "googlePlay", "steam")
## @param purchased_item_id The item identifier to purchase
func start_purchase(store_id: String, purchased_item_id: String) -> Dictionary:
	var data := {
		OperationParam.APP_STORE_STORE_ID: store_id,
		OperationParam.APP_STORE_PURCHASED_ITEM_ID: purchased_item_id
	}
	return await _send(ServiceOperation.APP_STORE_START_PURCHASE, data)

## Finalizes a two-staged purchase transaction.
##
## Service Name - AppStore[br]
## Service Operation - FinalizePurchase
##
## @param store_id The store platform (e.g. "itunes", "googlePlay", "steam")
## @param transaction_id The transaction id returned from start_purchase
## @param transaction_data Specific data for the two-staged purchase
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
