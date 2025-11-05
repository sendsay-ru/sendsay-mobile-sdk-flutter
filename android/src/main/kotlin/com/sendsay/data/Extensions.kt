package com.sendsay.data

import com.sendsay.exception.SendsayDataException

internal fun <T> Map<String, Any?>.getRequired(key: String): T {
    val value = this[key] ?: throw SendsayDataException.missingProperty(key)
    try {
        return value as T
    } catch (e: Exception) {
        throw SendsayDataException.invalidType(key)
    }
}

internal fun <T> Map<String, Any?>.getOptional(key: String): T? {
    val value = this[key]
    if (value == null) {
        return null
    }
    try {
        return value as T
    } catch (e: Exception) {
        throw SendsayDataException.invalidType(key)
    }
}
