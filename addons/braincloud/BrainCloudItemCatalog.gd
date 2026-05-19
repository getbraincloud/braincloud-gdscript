# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudItemCatalog
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

func get_catalog_item_definition(def_id: String) -> Dictionary:
	var data := {
		OperationParam.ITEM_CATALOG_DEF_ID: def_id
	}
	return await _send(ServiceOperation.ITEM_CATALOG_GET_ITEM_DEFN, data)

func get_catalog_items_page(context: Dictionary) -> Dictionary:
	var data := {
		OperationParam.ITEM_CATALOG_CONTEXT: context
	}
	return await _send(ServiceOperation.ITEM_CATALOG_GET_ITEM_DEFNS_PAGE, data)

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
