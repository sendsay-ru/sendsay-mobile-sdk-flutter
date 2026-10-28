package com.sendsay.example_flutter

import android.content.Context

/** Resolves resource groups using Android's flavor and locale selection. */
class ExampleResources(private val context: Context) {
    fun getResources(): Map<String, Any> = mapOf(
        "androidNotifications" to mapOf(
            "channelId" to context.getString(
                R.string.pushes_notification_channel_id
            ),
            "channelName" to context.getString(
                R.string.pushes_notification_channel_name
            ),
            "channelDescription" to context.getString(
                R.string.pushes_notification_channel_desc
            ),
            "icon" to R.mipmap.ic_notification
        )
    )
}
