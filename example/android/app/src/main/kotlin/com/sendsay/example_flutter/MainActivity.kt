package com.sendsay.example_flutter

import android.content.Context
import android.content.Intent
import android.os.Bundle
import com.sendsay.SendsayPlugin
import io.flutter.embedding.android.FlutterActivity
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        var APP_CONTEXT: Context? = null
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        // Potential MemoryLeak but still fine
        APP_CONTEXT = applicationContext
        SendsayPlugin.handleCampaignIntent(intent, applicationContext)
        super.onCreate(savedInstanceState)
    }

    override fun onNewIntent(intent: Intent) {
        SendsayPlugin.handleCampaignIntent(intent, applicationContext)
        super.onNewIntent(intent)
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
//        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.sendsay.example_flutter/utils").setMethodCallHandler { call, result ->
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.sendsay/utils").setMethodCallHandler { call, result ->
            if (call.method == "getAndroidPushIcon") {
                result.success(R.mipmap.ic_notification)
            } else {
                result.notImplemented()
            }
        }
    }
}
