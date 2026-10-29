package com.sendsay.example_flutter

import android.content.Context
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/** Owns the example channel and delegates to native resource/token providers. */
class ExampleNativeChannel(context: Context, messenger: BinaryMessenger) {
    private val channel = MethodChannel(messenger, "com.sendsay.example/native")
    private val handler = Handler(Looper.getMainLooper())
    private val tracker = TokenTracker(context.applicationContext)

    private val resources = ExampleResources(context)
    private var disposed = false

    init {
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getResources" -> result.success(resources.getResources())
                "getPushToken" -> {
                    tracker.getToken { token, error ->
                        handler.post {
                            if (disposed) return@post
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
                else -> result.notImplemented()
            }
        }
    }

    fun dispose() {
        disposed = true
        channel.setMethodCallHandler(null)
        tracker.close()
    }
}
