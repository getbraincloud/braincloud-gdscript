# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudWebConfig
extends RefCounted

const _MIX_KEY: PackedByteArray = [
	0x50, 0xe1, 0x72, 0x6d, 0xb1, 0x18, 0x4c, 0x48, 0xad, 0xdd, 0x3f, 0xc1, 0x87, 0x11, 0x1d, 0xd1,
]

static func _xor_repeat(data: PackedByteArray, key: PackedByteArray) -> PackedByteArray:
	var out := PackedByteArray()
	out.resize(data.size())
	for i in data.size():
		out[i] = data[i] ^ key[i % key.size()]
	return out

static func encode(plaintext: String) -> Dictionary:
	var value_bytes := plaintext.to_utf8_buffer()
	var pad := Crypto.new().generate_random_bytes(value_bytes.size())
	var share := _xor_repeat(_xor_repeat(value_bytes, pad), _MIX_KEY)
	return {
		"share": Marshalls.raw_to_base64(share),
		"pad": Marshalls.raw_to_base64(pad),
	}

static func decode(share_b64: String, pad_b64: String) -> String:
	var share := Marshalls.base64_to_raw(share_b64)
	var pad := Marshalls.base64_to_raw(pad_b64)
	var value_bytes := _xor_repeat(_xor_repeat(share, _MIX_KEY), pad)
	return value_bytes.get_string_from_utf8()
