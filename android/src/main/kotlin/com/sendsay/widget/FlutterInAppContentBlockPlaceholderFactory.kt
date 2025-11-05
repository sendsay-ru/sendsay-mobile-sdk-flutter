package com.sendsay.widget

import android.content.Context
import android.util.Log
import com.sendsay.getRequired
import com.sendsay.sdk.Sendsay
import com.sendsay.sdk.models.InAppContentBlockPlaceholderConfiguration
import com.sendsay.sdk.util.Logger
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugin.platform.PlatformView

class FlutterInAppContentBlockPlaceholderFactory(private val binding: FlutterPlugin.FlutterPluginBinding) :
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        @Suppress("UNCHECKED_CAST")
        val creationParams = args as? Map<String?, Any?>
        val placeholderId =  creationParams?.get("placeholderId") as? String
        val overrideDefaultBehavior = creationParams?.get("overrideDefaultBehavior") as? Boolean
        if(placeholderId == null) {
            Logger.e(this, "InAppCB: Unable to parse placeholder identifier.".trimIndent())
        }
        if(overrideDefaultBehavior == null) {
            Logger.e(this, "InAppCB: Unable to parse overrideDefaultBehavior parameter.".trimIndent())
        }
        val inAppContentBlockPlaceholder = Sendsay.getInAppContentBlocksPlaceholder(
            placeholderId ?: "",
            context!!,
            InAppContentBlockPlaceholderConfiguration(true)
        )

        return FlutterInAppContentBlockPlaceholder(
            context,
            viewId,
            placeholderId ?: "",
            inAppContentBlockPlaceholder,
            overrideDefaultBehavior ?: false,
            binding,
        )
    }
}


