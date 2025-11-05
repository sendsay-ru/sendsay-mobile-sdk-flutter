package com.sendsay.widget

import android.content.Context
import android.view.View
import android.widget.Button
import com.sendsay.sdk.Sendsay
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class FlutterAppInboxButton(
    private val context: Context,
    id: Int,
    creationParams: Map<String?, Any?>?
) : PlatformView {

    private val appInboxButton: Button?

    class Factory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
        override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
            @Suppress("UNCHECKED_CAST")
            val creationParams = args as Map<String?, Any?>?
            return FlutterAppInboxButton(context!!, viewId, creationParams)
        }
    }

    init {
        appInboxButton = Sendsay.getAppInboxButton(context = context)
    }

    override fun getView(): Button? {
        return appInboxButton
    }

    override fun dispose() {

    }

}

