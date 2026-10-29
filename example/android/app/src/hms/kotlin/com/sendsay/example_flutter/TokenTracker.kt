package com.sendsay.example_flutter

import android.content.Context
import com.huawei.agconnect.config.AGConnectServicesConfig
import com.huawei.hms.aaid.HmsInstanceId
import com.huawei.hms.push.HmsMessaging
import java.util.concurrent.Executors

/** Retrieves a token without tracking it or changing the clipboard. */
class TokenTracker(private val context: Context) {
    private val executor = Executors.newSingleThreadExecutor()

    fun getToken(complete: (String?, Throwable?) -> Unit) {
        executor.execute {
            try {
                val appId = AGConnectServicesConfig.fromContext(context)
                    .getString("client/app_id")
                require(!appId.isNullOrBlank()) { "HMS app ID is missing" }
                val token = HmsInstanceId.getInstance(context)
                    .getToken(appId, HmsMessaging.DEFAULT_TOKEN_SCOPE)
                complete(token, null)
            } catch (error: Exception) {
                complete(null, error)
            }
        }
    }

    fun close() {
        executor.shutdown()
    }
}
