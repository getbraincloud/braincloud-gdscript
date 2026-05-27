# Copyright 2026 bitHeads, Inc. All Rights Reserved.
class_name BrainCloudProfanity
extends RefCounted

var _client_ref: BrainCloudClient

func _init(client_ref: BrainCloudClient) -> void:
	_client_ref = client_ref

## Checks supplied text for profanity.
##
## Service Name - Profanity[br]
## Service Operation - ProfanityCheck
##
## @param text The text to check
## @param languages Array of two-character language codes (e.g. ["en", "fr"])
## @param flag_email Whether to process email addresses
## @param flag_phone Whether to process phone numbers
## @param flag_urls Whether to process URLs
##
## Significant error codes:[br]
## 40421 - WebPurify not configured[br]
## 40422 - General exception occurred[br]
## 40423 - WebPurify returned an error (Http status != 200)[br]
## 40424 - WebPurify not enabled
func profanity_check(text: String, languages: Array, flag_email: bool, flag_phone: bool, flag_urls: bool) -> Dictionary:
	var data := {
		OperationParam.PROFANITY_TEXT: text,
		OperationParam.PROFANITY_LANGUAGE: ",".join(languages),
		OperationParam.PROFANITY_FLAG_EMAIL: flag_email,
		OperationParam.PROFANITY_FLAG_PHONE: flag_phone,
		OperationParam.PROFANITY_FLAG_URLS: flag_urls
	}
	return await _send(ServiceOperation.PROFANITY_CHECK, data)

## Replaces the characters of profanity text with a passed character(s).
##
## Service Name - Profanity[br]
## Service Operation - ProfanityReplaceText
##
## @param text The text to check
## @param replace_symbol The text to replace individual profanity characters with
## @param languages Array of two-character language codes (e.g. ["en", "fr"])
## @param flag_email Whether to process email addresses
## @param flag_phone Whether to process phone numbers
## @param flag_urls Whether to process URLs
##
## Significant error codes:[br]
## 40421 - WebPurify not configured[br]
## 40422 - General exception occurred[br]
## 40423 - WebPurify returned an error (Http status != 200)[br]
## 40424 - WebPurify not enabled
func profanity_replace_text(text: String, replace_symbol: String, languages: Array, flag_email: bool, flag_phone: bool, flag_urls: bool) -> Dictionary:
	var data := {
		OperationParam.PROFANITY_TEXT: text,
		OperationParam.PROFANITY_REPLACE_SYMBOL: replace_symbol,
		OperationParam.PROFANITY_LANGUAGE: ",".join(languages),
		OperationParam.PROFANITY_FLAG_EMAIL: flag_email,
		OperationParam.PROFANITY_FLAG_PHONE: flag_phone,
		OperationParam.PROFANITY_FLAG_URLS: flag_urls
	}
	return await _send(ServiceOperation.PROFANITY_REPLACE_TEXT, data)

## Checks supplied text for profanity and returns a list of bad words.
##
## Service Name - Profanity[br]
## Service Operation - ProfanityIdentifyBadWords
##
## @param text The text to check
## @param languages Array of two-character language codes (e.g. ["en", "fr"])
## @param flag_email Whether to process email addresses
## @param flag_phone Whether to process phone numbers
## @param flag_urls Whether to process URLs
##
## Significant error codes:[br]
## 40421 - WebPurify not configured[br]
## 40422 - General exception occurred[br]
## 40423 - WebPurify returned an error (Http status != 200)[br]
## 40424 - WebPurify not enabled
func profanity_identify_bad_words(text: String, languages: Array, flag_email: bool, flag_phone: bool, flag_urls: bool) -> Dictionary:
	var data := {
		OperationParam.PROFANITY_TEXT: text,
		OperationParam.PROFANITY_LANGUAGE: ",".join(languages),
		OperationParam.PROFANITY_FLAG_EMAIL: flag_email,
		OperationParam.PROFANITY_FLAG_PHONE: flag_phone,
		OperationParam.PROFANITY_FLAG_URLS: flag_urls
	}
	return await _send(ServiceOperation.PROFANITY_IDENTIFY_BAD_WORDS, data)

func _send(operation: String, data: Dictionary) -> Dictionary:
	var sc := ServerCall.new(ServiceName.PROFANITY, operation, data)
	_client_ref.comms.add_to_queue(sc)
	return await sc.response_received
