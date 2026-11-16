# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudWebConfig
extends RefCounted

const _K: PackedByteArray = [
	0x50, 0xe1, 0x72, 0x6d, 0xb1, 0x18, 0x4c, 0x48, 0xad, 0xdd, 0x3f, 0xc1, 0x87, 0x11, 0x1d, 0xd1,
]

const _MARK := "gDw:"

static func _apply(data: PackedByteArray, key: PackedByteArray) -> PackedByteArray:
	var out := PackedByteArray()
	out.resize(data.size())
	for i in data.size():
		out[i] = data[i] ^ key[i % key.size()]
	return out

# Web config key for this build's tuning value.
static func _key(tuning: PackedByteArray) -> PackedByteArray:
	var h := HMACContext.new()
	h.start(HashingContext.HASH_SHA256, _K)
	h.update(tuning)
	return h.finish()

static func encode(value: String, tuning: PackedByteArray) -> Dictionary:
	var v := (_MARK + value).to_utf8_buffer()
	var b := Crypto.new().generate_random_bytes(v.size())
	var a := _apply(_apply(v, b), _key(tuning))
	v.fill(0)
	return {"a": Marshalls.raw_to_base64(a), "b": Marshalls.raw_to_base64(b)}

# App profile for initialize(): payload bytes -> request signature. Invalid if a/b don't read.
static func profile(a: String, b: String, tuning: PackedByteArray) -> Callable:
	var x := Marshalls.base64_to_raw(a)
	var y := Marshalls.base64_to_raw(b)
	var mark := _MARK.to_utf8_buffer()
	if tuning.is_empty() or x.size() <= mark.size() or x.size() != y.size():
		return Callable()
	var k := _key(tuning)
	var check := _apply(_apply(x, k), y)
	var ok := check.slice(0, mark.size()) == mark
	check.fill(0)
	if not ok:
		return Callable()
	return func(payload: PackedByteArray) -> String:
		var v := _apply(_apply(x, k), y).slice(mark.size())
		var ctx := HashingContext.new()
		ctx.start(HashingContext.HASH_MD5)
		ctx.update(payload)
		ctx.update(v)
		v.fill(0)
		return ctx.finish().hex_encode()
