# Copyright 2026 bitHeads, Inc. All Rights Reserved.
# Shared status enum for the relay transport wrappers (RelayWSSocket/RelayTCPSocket/
# RelayUDPSocket) so BrainCloudRelayComms can treat all three uniformly.
class_name RelayTransportStatus
extends RefCounted

enum Status { CONNECTING, CONNECTED, ERROR, CLOSED }
