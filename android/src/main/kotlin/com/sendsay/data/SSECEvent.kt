package com.sendsay.data

import com.sendsay.sdk.models.TrackSSECData

data class SSECEvent(val type: String, val data: Map<String, Any>) {
    companion object {
        fun fromMap(map: Map<String, Any?>): SSECEvent {
            return SSECEvent(
                type = map["type"] as String? ?: throw IllegalStateException("SSECEvent.type is required!"),
                data = (map["data"] as Map<String, Any>?) ?: throw IllegalStateException("SSECEvent.data is required!")
            )
        }

        fun Map<String, Any>.toTrackSSECData(): TrackSSECData {
            return TrackSSECData(
                productId      = this["productId"] as? String,
                productName    = this["productName"] as? String,
                picture        = (this["picture"] as? List<*>)?.map { it as String },
                url            = this["url"] as? String,
                available      = (this["available"] as? Number)?.toLong(),
                categoryPaths  = (this["categoryPaths"] as? List<*>)?.map { it as String },
                categoryId     = (this["categoryId"] as? Number)?.toLong(),
                category       = this["category"] as? String,
                description    = this["description"] as? String,
                vendor         = this["vendor"] as? String,
                model          = this["model"] as? String,
                type           = this["type"] as? String,
                price          = (this["price"] as? Number)?.toDouble(),
                oldPrice       = (this["oldPrice"] as? Number)?.toDouble(),
                updatePerItem  = (this["updatePerItem"] as? Number)?.toInt(),
                // дальше по списку полей из decompiled-класса
            )
        }
    }
}
