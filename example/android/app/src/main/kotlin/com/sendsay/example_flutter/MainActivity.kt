package com.sendsay.example_flutter

import android.content.Context
import android.content.Intent
import android.os.Bundle
import com.sendsay.SendsayPlugin
import io.flutter.embedding.android.FlutterActivity
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var nativeChannel: ExampleNativeChannel? = null

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        nativeChannel?.dispose()
        nativeChannel = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

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
        nativeChannel = ExampleNativeChannel(
            applicationContext,
            flutterEngine.dartExecutor.binaryMessenger
        )
    }
}
