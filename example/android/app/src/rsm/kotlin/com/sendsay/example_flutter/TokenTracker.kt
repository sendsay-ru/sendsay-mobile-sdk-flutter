package com.sendsay.example_flutter

import android.content.Context
import ru.rustore.sdk.pushclient.RuStorePushClient

/** Retrieves a token without tracking it or changing the clipboard. */
class TokenTracker(private val context: Context) {

    fun getToken(complete: (String?, Throwable?) -> Unit) {
        try {
            RuStorePushClient.getToken()
                .addOnSuccessListener { complete(it, null) }
                .addOnFailureListener { complete(null, it) }
        } catch (error: Exception) {
            complete(null, error)
        }
    }

    fun close() {
        // Provider tasks are owned by the push SDK.
    }
}
