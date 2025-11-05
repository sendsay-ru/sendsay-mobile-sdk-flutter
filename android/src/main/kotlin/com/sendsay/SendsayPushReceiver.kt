package com.sendsay

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.sendsay.data.OpenedPush
import com.sendsay.data.PushAction
import com.sendsay.sdk.SendsayExtras
import com.sendsay.sdk.models.NotificationAction
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken

class SendsayPushReceiver : BroadcastReceiver() {
    /**
     * We respond to all push notification actions and pass the push notification information to SendsayPlugin.
     * For default "open app" action, we also start the application.
     * For "deeplink" action, Sendsay SDK will generate intent and it's up to the developer to implement Intent handler.
     * For "web" action, Sendsay SDK will generate intent that will be handled by the browser.
     */
    override fun onReceive(context: Context, intent: Intent) {
        val action = when (intent.action) {
            SendsayExtras.ACTION_CLICKED -> PushAction.APP
            SendsayExtras.ACTION_DEEPLINK_CLICKED -> PushAction.DEEPLINK
            SendsayExtras.ACTION_URL_CLICKED -> PushAction.WEB
            else -> throw RuntimeException("Unknown push notification action ${intent.action}")
        }

        val actionInfo = intent.getSerializableExtra(SendsayExtras.EXTRA_ACTION_INFO) as? NotificationAction
        val url = actionInfo?.url
        val pushData = intent.getSerializableExtra(SendsayExtras.EXTRA_CUSTOM_DATA) as? Map<String, String>
        val additionalData = pushData?.let {
            val additionalDataType = object : TypeToken<Map<String, Any?>?>() {}.getType()
            Gson().fromJson(it["attributes"], additionalDataType) as? Map<String, Any?>
        }
        OpenedPushStreamHandler.handle(OpenedPush(action, url, additionalData))
    }
}
