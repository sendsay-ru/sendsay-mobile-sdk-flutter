package com.sendsay.example_flutter

import android.content.Context
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/** Example-only bridge to the push provider selected by the Android flavor. */
class TokenChannel(context: Context, messenger: BinaryMessenger) {
    private val channel = MethodChannel(messenger, "com.sendsay.example/tokens")
    private val handler = Handler(Looper.getMainLooper())
    private val tracker = TokenTracker(context.applicationContext)

    init {
        channel.setMethodCallHandler { call, result ->
            if (call.method != "getToken") {
                result.notImplemented()
            } else {
                tracker.getToken { token, error ->
                    handler.post {
                        when {
                            error != null -> result.error(
                                "token_unavailable", error.message, null
                            )
                            token.isNullOrBlank() -> result.error(
                                "token_unavailable",
                                "Provider returned an empty token. Try again shortly.",
                                null
                            )
                            else -> result.success(token)
                        }
                    }
                }
            }
        }
    }

    fun dispose() {
        channel.setMethodCallHandler(null)
        tracker.close()
    }
}
