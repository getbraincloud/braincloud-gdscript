# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudCampaign
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

## Returns the list of campaigns the current player is participating in,
## providing campaign, campaign scenario, and participation details.
##
## Service Name - Campaign[br]
## Service Operation - GET_MY_CAMPAIGNS
##
## @param options Optional parameters as a Dictionary (reserved for future use)
func get_my_campaigns(options: Dictionary = {}) -> Dictionary:
	var data := {
		OperationParam.USER_ITEMS_SERVICE_OPTIONS_JSON: options
	}
	return await _send(ServiceOperation.GET_MY_CAMPAIGNS, data)

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.CAMPAIGN, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
