# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudBlockchain
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

func get_blockchain_items(integration_id: String, context_json: Dictionary) -> Dictionary:
	var data := {
		OperationParam.BLOCK_CHAIN_INTEGRATION_ID: integration_id,
		OperationParam.BLOCK_CHAIN_CONTEXT: context_json
	}
	return await _send(ServiceOperation.GET_BLOCKCHAIN_ITEMS, data)

func get_uniqs(integration_id: String, context_json: Dictionary) -> Dictionary:
	var data := {
		OperationParam.BLOCK_CHAIN_INTEGRATION_ID: integration_id,
		OperationParam.BLOCK_CHAIN_CONTEXT: context_json
	}
	return await _send(ServiceOperation.GET_UNIQS, data)

func attach_blockchain_identity(integration_id: String, public_key: String) -> Dictionary:
	var data := {
		OperationParam.BLOCK_CHAIN_INTEGRATION_ID: integration_id,
		OperationParam.PUBLIC_KEY: public_key
	}
	return await _send(ServiceOperation.ATTACH_BLOCKCHAIN_IDENTITY, data)

func detach_blockchain_identity(integration_id: String) -> Dictionary:
	var data := {
		OperationParam.BLOCK_CHAIN_INTEGRATION_ID: integration_id
	}
	return await _send(ServiceOperation.DETACH_BLOCKCHAIN_IDENTITY, data)

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.BLOCKCHAIN, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
