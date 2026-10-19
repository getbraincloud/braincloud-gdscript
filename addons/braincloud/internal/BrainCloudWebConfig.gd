# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudWebConfig
extends RefCounted

const _K: PackedByteArray = [
	0x50, 0xe1, 0x72, 0x6d, 0xb1, 0x18, 0x4c, 0x48, 0xad, 0xdd, 0x3f, 0xc1, 0x87, 0x11, 0x1d, 0xd1,
]

static func _apply(data: PackedByteArray, key: PackedByteArray) -> PackedByteArray:
	var out := PackedByteArray()
	out.resize(data.size())
	for i in data.size():
		out[i] = data[i] ^ key[i % key.size()]
	return out

static func encode(value: String) -> Dictionary:
	var v := value.to_utf8_buffer()
	var b := Crypto.new().generate_random_bytes(v.size())
	var a := _apply(_apply(v, b), _K)
	v.fill(0)
	return {"a": Marshalls.raw_to_base64(a), "b": Marshalls.raw_to_base64(b)}

# App profile for initialize(): payload bytes -> request signature.
static func profile(a: String, b: String) -> Callable:
	var x := Marshalls.base64_to_raw(a)
	var y := Marshalls.base64_to_raw(b)
	if x.is_empty() or x.size() != y.size():
		return Callable()
	return func(payload: PackedByteArray) -> String:
		var v := _apply(_apply(x, _K), y)
		var ctx := HashingContext.new()
		ctx.start(HashingContext.HASH_MD5)
		ctx.update(payload)
		ctx.update(v)
		v.fill(0)
		return ctx.finish().hex_encode()
