package com.sendsay.data

import com.sendsay.getNullSafely
import com.sendsay.getRequired
import com.sendsay.sdk.models.InAppContentBlockAction
import com.sendsay.sdk.models.InAppContentBlockActionType

class InAppContentBlockActionCoder {
    companion object {
        fun encode(source: InAppContentBlockAction): Map<String, Any?> {
            return mapOf(
                "type" to source.type.toString(),
                "name" to source.name,
                "url" to source.url,
            )
        }

        fun decode(source: Map<String, Any?>): InAppContentBlockAction {
            return InAppContentBlockAction(
                type = InAppContentBlockActionType.valueOf(source.getRequired("type")),
                name = source.getNullSafely("name"),
                url = source.getNullSafely("url")
            )
        }
    }
}