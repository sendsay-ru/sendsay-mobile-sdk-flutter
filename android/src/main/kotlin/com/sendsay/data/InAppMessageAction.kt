package com.sendsay.data

import com.sendsay.sdk.models.InAppMessage
import com.sendsay.sdk.models.InAppMessageButton

data class InAppMessageAction(
    val type: InAppMessageActionType,
    val message: InAppMessage?,
    val button: InAppMessageButton? = null,
    val interaction: Boolean? = null,
    val errorMessage: String? = null,
) {
    fun toMap(): Map<String, Any?> {
        return mapOf(
            "type" to type.value,
            "message" to message?.let { InAppMessageCoder.encode(it) },
            "button" to button?.let {
                mapOf(
                    "text" to it.text,
                    "url" to it.url
                )
            },
            "interaction" to interaction,
            "errorMessage" to errorMessage
        ).filterValues { it != null }
    }
}
