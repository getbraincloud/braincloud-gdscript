# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name RequestState
extends RefCounted

var packet_id: int = 0
var retries: int = 0
var packet_no_retry: bool = false
var packet_requires_long_timeout: bool = false
var lose_this_packet: bool = false
var message_list: Array = []
var request_string: String = ""
var signature: String = ""
var byte_array: PackedByteArray
var time_sent: float = 0.0
var http_request: HTTPRequest = null
