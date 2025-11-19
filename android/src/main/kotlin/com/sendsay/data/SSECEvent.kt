package com.sendsay.data

import com.sendsay.sdk.models.TrackSSECData
import com.sendsay.sdk.models.TrackingSSECType

data class SSECEvent(val type: TrackingSSECType, val data: TrackSSECData) {
    companion object {
        fun fromMap(map: Map<String, Any?>): SSECEvent {
            return SSECEvent(
                type = map["type"] as TrackingSSECType? ?: throw IllegalStateException("SSECEvent.type is required!"),
                data = map["data"] as TrackSSECData? ?: throw IllegalStateException("SSECEvent.data is required!")
            )
        }
    }
}
