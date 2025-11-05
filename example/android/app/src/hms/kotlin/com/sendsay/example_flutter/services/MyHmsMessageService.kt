package com.sendsay.example_flutter.services

import android.app.NotificationManager
import android.content.Context
import com.sendsay.SendsayPlugin
import com.huawei.hms.push.HmsMessageService
import com.huawei.hms.push.RemoteMessage

class MyHmsMessageService : HmsMessageService() {

    private val notificationManager by lazy {
        getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    }

    override fun onMessageReceived(message: RemoteMessage) {
        super.onMessageReceived(message)
        SendsayPlugin.handleRemoteMessage(applicationContext, message.dataOfMap, notificationManager)
    }

    override fun onNewToken(token: String) {
        super.onNewToken(token)
        SendsayPlugin.handleNewHmsToken(applicationContext, token)
    }
}
