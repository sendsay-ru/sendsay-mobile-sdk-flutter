package com.sendsay.widget

import android.content.Context
import com.sendsay.widget.getRequired
import com.sendsay.widget.getOptional
import com.sendsay.sdk.Sendsay
import com.sendsay.sdk.util.Logger
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugin.platform.PlatformView

class FlutterInAppContentBlockCarouselFactory(private val binding: FlutterPlugin.FlutterPluginBinding) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        val creationParams = args as Map<*, *>
        val placeholderId =  creationParams.getRequired<String>("placeholderId")
        val overrideDefaultBehavior = creationParams.getRequired<Boolean>("overrideDefaultBehavior")
        val trackActions = creationParams.getRequired<Boolean>("trackActions")
        val maxMessagesCount = creationParams.getOptional<Int>("maxMessagesCount")
        val scrollDelay = creationParams.getOptional<Int>("scrollDelay")
        val filtrationSet = creationParams.getRequired<Boolean>("filtrationSet")
        val sortingSet = creationParams.getRequired<Boolean>("sortingSet")
        val inAppContentBlockCarousel = Sendsay.getInAppContentBlocksCarousel(
            context!!,
            placeholderId,
            maxMessagesCount = maxMessagesCount,
            scrollDelay = scrollDelay,
        )

        return FlutterInAppContentBlockCarousel(
            context,
            viewId,
            placeholderId,
            inAppContentBlockCarousel,
            overrideDefaultBehavior,
            trackActions,
            filtrationSet,
            sortingSet,
            binding,
        )
    }
}