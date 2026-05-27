# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudItemCatalog
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

## Reads an existing item definition from the server, with language fields
## limited to the current or default language.
##
## Service Name - ItemCatalog[br]
## Service Operation - GET_CATALOG_ITEM_DEFINITION
##
## @param def_id The item definition id
func get_catalog_item_definition(def_id: String) -> Dictionary:
	var data := {
		OperationParam.ITEM_CATALOG_DEF_ID: def_id
	}
	return await _send(ServiceOperation.ITEM_CATALOG_GET_ITEM_DEFN, data)

## Retrieves a page of catalog items from the server, with language fields limited
## to the text for the current or default language.
##
## Service Name - ItemCatalog[br]
## Service Operation - GET_CATALOG_ITEMS_PAGE
##
## @param context The pagination context Dictionary
func get_catalog_items_page(context: Dictionary) -> Dictionary:
	var data := {
		OperationParam.ITEM_CATALOG_CONTEXT: context
	}
	return await _send(ServiceOperation.ITEM_CATALOG_GET_ITEM_DEFNS_PAGE, data)

## Gets the page of catalog items based on the encoded context and specified page offset,
## with language fields limited to the text for the current or default language.
##
## Service Name - ItemCatalog[br]
## Service Operation - GET_CATALOG_ITEMS_PAGE_OFFSET
##
## @param context The encoded context string from a previous page request
## @param page_offset The number of pages to offset
func get_catalog_items_page_offset(context: String, page_offset: int) -> Dictionary:
	var data := {
		OperationParam.ITEM_CATALOG_CONTEXT: context,
		OperationParam.ITEM_CATALOG_PAGE_OFFSET: page_offset
	}
	return await _send(ServiceOperation.ITEM_CATALOG_GET_ITEM_DEFNS_PAGE_OFFSET, data)

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.ITEM_CATALOG, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
