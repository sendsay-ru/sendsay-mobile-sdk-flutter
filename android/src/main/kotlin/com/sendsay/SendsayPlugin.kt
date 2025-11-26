package com.sendsay

import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.NonNull
import com.sendsay.data.AppInboxCoder
import com.sendsay.data.ConsentEncoder
import com.sendsay.data.Customer
import com.sendsay.data.Event
import com.sendsay.data.SendsayConfigurationParser
import com.sendsay.data.FlutterSegmentationDataCallback
import com.sendsay.data.InAppContentBlockActionCoder
import com.sendsay.data.OpenedPush
import com.sendsay.data.ReceivedPush
import com.sendsay.data.InAppMessageAction
import com.sendsay.data.InAppMessageActionType
import com.sendsay.data.RecommendationEncoder
import com.sendsay.data.RecommendationOptionsEncoder
import com.sendsay.data.InAppMessageCoder
import com.sendsay.data.NotificationCoder
import com.sendsay.data.PurchasedItemCoder
import com.sendsay.data.SSECEvent
import com.sendsay.data.SSECEvent.Companion.toTrackSSECData
import com.sendsay.data.SegmentationData
import com.sendsay.data.getOptional
import com.sendsay.exception.SendsayException
import com.sendsay.sdk.BuildConfig
import com.sendsay.sdk.Sendsay
import com.sendsay.sdk.models.CustomerIds
import com.sendsay.sdk.models.SendsayConfiguration
import com.sendsay.sdk.models.FlushMode
import com.sendsay.sdk.models.FlushPeriod
import com.sendsay.sdk.models.InAppContentBlock
import com.sendsay.sdk.models.PropertiesList
import com.sendsay.sdk.models.InAppMessage
import com.sendsay.sdk.models.InAppMessageButton
import com.sendsay.sdk.models.InAppMessageCallback
import com.sendsay.sdk.models.TrackSSECData
import com.sendsay.sdk.models.TrackingSSECType
import com.sendsay.sdk.style.appinbox.StyledAppInboxProvider
import com.sendsay.sdk.util.SendsayGson
import com.sendsay.sdk.util.Logger
import com.sendsay.sdk.style.appinbox.AppInboxStyleParser
import com.sendsay.widget.FlutterAppInboxButton
import com.sendsay.widget.FlutterAppInboxDetailView
import com.sendsay.widget.FlutterAppInboxListView
import com.sendsay.widget.FlutterInAppContentBlockCarouselFactory
import com.sendsay.widget.FlutterInAppContentBlockPlaceholderFactory
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.EventChannel.StreamHandler
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.concurrent.CopyOnWriteArrayList
import java.util.concurrent.TimeUnit
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

private const val TAG = "SendsayPlugin"

/**
 * Sendsay Android Plugin
 */
class SendsayPlugin : FlutterPlugin, ActivityAware {
    companion object {
        private const val CHANNEL_NAME = "com.sendsay"
        private const val STREAM_NAME_OPENED_PUSH = "$CHANNEL_NAME/opened_push"
        private const val STREAM_NAME_RECEIVED_PUSH = "$CHANNEL_NAME/received_push"
        private const val STREAM_NAME_IN_APP_MESSAGES = "$CHANNEL_NAME/in_app_messages"
        private const val STREAM_NAME_SEGMENTATION_DATA = "$CHANNEL_NAME/segmentation_data"

        fun handleCampaignIntent(intent: Intent?, applicationContext: Context) {
            Log.d(TAG, "handleCampaignIntent()")
            Sendsay.handleCampaignIntent(intent, applicationContext)
        }

        fun handleRemoteMessage(
            applicationContext: Context,
            messageData: Map<String, String>?,
            manager: NotificationManager,
            showNotification: Boolean = true
        ) {
            Log.d(TAG, "handleRemoteMessage()")
            Sendsay.handleRemoteMessage(applicationContext, messageData, manager, showNotification)
        }

        fun trackGmsPushToken(token: String) {
            Log.d(TAG, "trackGmsPushToken($token)")
            Sendsay.trackPushToken(token)
        }

        fun trackHmsPushToken(token: String) {
            Log.d(TAG, "trackHmsPushToken($token)")
            Sendsay.trackHmsPushToken(token)
        }

        fun handleNewGmsToken(context: Context, token: String) {
            Log.d(TAG, "handleNewGmsToken($token)")
            Sendsay.handleNewToken(context, token)
        }

        fun handleNewHmsToken(context: Context, token: String) {
            Log.d(TAG, "handleNewHmsToken($token)")
            Sendsay.handleNewHmsToken(context, token)
        }
    }

    private var channel: MethodChannel? = null
    private var methodHandler: SendsayMethodHandler? = null
    private var openedPushChannel: EventChannel? = null
    private var openedPushStreamHandler: OpenedPushStreamHandler? = null
    private var receivedPushChannel: EventChannel? = null
    private var inAppMessagesChannel: EventChannel? = null
    private var segmentationDataChannel: EventChannel? = null

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        val context = binding.applicationContext

        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME).apply {
            val handler = SendsayMethodHandler(context)
            setMethodCallHandler(handler)
            methodHandler = handler
        }
        openedPushChannel = EventChannel(binding.binaryMessenger, STREAM_NAME_OPENED_PUSH).apply {
            val handler = OpenedPushStreamHandler()
            setStreamHandler(handler)
            openedPushStreamHandler = handler
        }
        receivedPushChannel = EventChannel(binding.binaryMessenger, STREAM_NAME_RECEIVED_PUSH).apply {
            val handler = ReceivedPushStreamHandler()
            setStreamHandler(handler)
        }
        inAppMessagesChannel = EventChannel(binding.binaryMessenger, STREAM_NAME_IN_APP_MESSAGES).apply {
            val handler = InAppMessageActionStreamHandler.currentInstance
            setStreamHandler(handler)
        }
        segmentationDataChannel = EventChannel(binding.binaryMessenger, STREAM_NAME_SEGMENTATION_DATA).apply {
            val handler = SegmentationDataStreamHandler()
            setStreamHandler(handler)
        }
        binding
            .platformViewRegistry
            .registerViewFactory("FluffView", FlutterAppInboxButton.Factory())
        binding
            .platformViewRegistry
            .registerViewFactory("InAppContentBlockPlaceholder", FlutterInAppContentBlockPlaceholderFactory(binding))
        binding
            .platformViewRegistry
            .registerViewFactory("AppInboxDetailView", FlutterAppInboxDetailView.Factory())
        binding
            .platformViewRegistry
            .registerViewFactory("AppInboxListView", FlutterAppInboxListView.Factory(binding))
        binding
            .platformViewRegistry
            .registerViewFactory("InAppContentBlockCarousel", FlutterInAppContentBlockCarouselFactory(binding))
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
        methodHandler?.activity = null
        methodHandler = null
        openedPushChannel?.setStreamHandler(null)
        openedPushChannel = null
        receivedPushChannel?.setStreamHandler(null)
        receivedPushChannel = null
        inAppMessagesChannel?.setStreamHandler(null)
        inAppMessagesChannel = null
        segmentationDataChannel?.setStreamHandler(null)
        segmentationDataChannel = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        methodHandler?.activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        methodHandler?.activity = null
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }
}

@Suppress("UNCHECKED_CAST")
private class SendsayMethodHandler(private val context: Context) : MethodCallHandler {
    companion object {
        private const val METHOD_CONFIGURE = "configure"
        private const val METHOD_IS_CONFIGURED = "isConfigured"
        private const val METHOD_GET_CUSTOMER_COOKIE = "getCustomerCookie"
        private const val METHOD_IDENTIFY_CUSTOMER = "identifyCustomer"
        private const val METHOD_ANONYMIZE = "anonymize"
        private const val METHOD_GET_DEFAULT_PROPERTIES = "getDefaultProperties"
        private const val METHOD_SET_DEFAULT_PROPERTIES = "setDefaultProperties"
        private const val METHOD_FLUSH = "flush"
        private const val METHOD_GET_FLUSH_MODE = "getFlushMode"
        private const val METHOD_SET_FLUSH_MODE = "setFlushMode"
        private const val METHOD_GET_FLUSH_PERIOD = "getFlushPeriod"
        private const val METHOD_SET_FLUSH_PERIOD = "setFlushPeriod"
        private const val METHOD_TRACK_EVENT = "trackEvent"
        private const val METHOD_TRACK_SSEC = "trackSSEC"
        private const val METHOD_TRACK_SESSION_START = "trackSessionStart"
        private const val METHOD_TRACK_SESSION_END = "trackSessionEnd"
        private const val METHOD_FETCH_CONSENTS = "fetchConsents"
        private const val METHOD_FETCH_RECOMMENDATIONS = "fetchRecommendations"
        private const val METHOD_GET_LOG_LEVEL = "getLogLevel"
        private const val METHOD_SET_LOG_LEVEL = "setLogLevel"
        private const val METHOD_CHECK_PUSH_SETUP = "checkPushSetup"
        private const val METHOD_REQUEST_PUSH_AUTHORIZATION = "requestPushAuthorization"
        private const val METHOD_SET_APP_INBOX_PROVIDER = "setAppInboxProvider"
        private const val METHOD_TRACK_APP_INBOX_OPENED = "trackAppInboxOpened"
        private const val METHOD_TRACK_APP_INBOX_OPENED_WITHOUT_TRACKING_CONSENT = "trackAppInboxOpenedWithoutTrackingConsent"
        private const val METHOD_TRACK_APP_INBOX_CLICK = "trackAppInboxClick"
        private const val METHOD_TRACK_APP_INBOX_CLICK_WITHOUT_TRACKING_CONSENT = "trackAppInboxClickWithoutTrackingConsent"
        private const val METHOD_MARK_APP_INBOX_AS_READ = "markAppInboxAsRead"
        private const val METHOD_FETCH_APP_INBOX = "fetchAppInbox"
        private const val METHOD_FETCH_APP_INBOX_ITEM = "fetchAppInboxItem"
        private const val METHOD_TRACK_IN_APP_CONTENT_BLOCK_CLICK = "trackInAppContentBlockClick"
        private const val METHOD_TRACK_IN_APP_CONTENT_BLOCK_CLICK_WITHOUT_TRACKING_CONSENT = "trackInAppContentBlockClickWithoutTrackingConsent"
        private const val METHOD_TRACK_IN_APP_CONTENT_BLOCK_CLOSE = "trackInAppContentBlockClose"
        private const val METHOD_TRACK_IN_APP_CONTENT_BLOCK_CLOSE_WITHOUT_TRACKING_CONSENT = "trackInAppContentBlockCloseWithoutTrackingConsent"
        private const val METHOD_TRACK_IN_APP_CONTENT_BLOCK_SHOWN = "trackInAppContentBlockShown"
        private const val METHOD_TRACK_IN_APP_CONTENT_BLOCK_SHOWN_WITHOUT_TRACKING_CONSENT = "trackInAppContentBlockShownWithoutTrackingConsent"
        private const val METHOD_TRACK_IN_APP_CONTENT_BLOCK_ERROR = "trackInAppContentBlockError"
        private const val METHOD_TRACK_IN_APP_CONTENT_BLOCK_ERROR_WITHOUT_TRACKING_CONSENT = "trackInAppContentBlockErrorWithoutTrackingConsent"
        private const val METHOD_SET_IN_APP_MESSAGE_ACTION_HANDLER = "setInAppMessageActionHandler"
        private const val METHOD_TRACK_IN_APP_MESSAGE_CLICK = "trackInAppMessageClick"
        private const val METHOD_TRACK_IN_APP_MESSAGE_CLICK_WITHOUT_TRACKING_CONSENT = "trackInAppMessageClickWithoutTrackingConsent"
        private const val METHOD_TRACK_IN_APP_MESSAGE_CLOSE = "trackInAppMessageClose"
        private const val METHOD_TRACK_IN_APP_MESSAGE_CLOSE_WITHOUT_TRACKING_CONSENT = "trackInAppMessageCloseWithoutTrackingConsent"
        private const val METHOD_TRACK_PAYMENT_EVENT = "trackPaymentEvent"
        private const val METHOD_TRACK_PUSH_TOKEN = "trackPushToken"
        private const val METHOD_TRACK_HMS_PUSH_TOKEN = "trackHmsPushToken"
        private const val METHOD_HANDLE_PUSH_TOKEN = "handlePushToken"
        private const val METHOD_HANDLE_HMS_PUSH_TOKEN = "handleHmsPushToken"
        private const val METHOD_TRACK_CLICKED_PUSH = "trackClickedPush"
        private const val METHOD_TRACK_CLICKED_PUSH_WITHOUT_TRACKING_CONSENT = "trackClickedPushWithoutTrackingConsent"
        private const val METHOD_TRACK_DELIVERED_PUSH = "trackDeliveredPush"
        private const val METHOD_TRACK_DELIVERED_PUSH_WITHOUT_TRACKING_CONSENT = "trackDeliveredPushWithoutTrackingConsent"
        private const val METHOD_IS_BLOOMREACH_NOTIFICATION = "isBloomreachNotification"
        private const val METHOD_HANDLE_CAMPAIGN_CLICK = "handleCampaignClick"
        private const val METHOD_HANDLE_PUSH_NOTIFICATION_OPENED = "handlePushNotificationOpened"
        private const val METHOD_HANDLE_PUSH_NOTIFICATION_OPENED_WITHOUT_TRACKING_CONSENT = "handlePushNotificationOpenedWithoutTrackingConsent"
        private const val METHOD_GET_SEGMENTS = "getSegments"
        private const val METHOD_REGISTER_SEGMENTATION_DATA_STREAM = "registerSegmentationDataStream"
        private const val METHOD_UNREGISTER_SEGMENTATION_DATA_STREAM = "unregisterSegmentationDataStream"
    }

    var activity: Context? = null
    private var configuration: SendsayConfiguration? = null
    private val handler: Handler = Handler(Looper.getMainLooper())
    private val segmentationDataCallbacks = CopyOnWriteArrayList<FlutterSegmentationDataCallback>()

    override fun onMethodCall(call: MethodCall, result: Result) {
        Log.i(TAG, "onMethodCall(${call.method})")

        when (call.method) {
            METHOD_CONFIGURE -> {
                configure(call.arguments, result)
            }
            METHOD_IS_CONFIGURED -> {
                isConfigured(result)
            }
            METHOD_GET_CUSTOMER_COOKIE -> {
                getCustomerCookie(result)
            }
            METHOD_IDENTIFY_CUSTOMER -> {
                identifyCustomer(call.arguments, result)
            }
            METHOD_ANONYMIZE -> {
                anonymize(call.arguments, result)
            }
            METHOD_GET_DEFAULT_PROPERTIES -> {
                getDefaultProperties(result)
            }
            METHOD_SET_DEFAULT_PROPERTIES -> {
                setDefaultProperties(call.arguments, result)
            }
            METHOD_FLUSH -> {
                flush(result)
            }
            METHOD_GET_FLUSH_MODE -> {
                getFlushMode(result)
            }
            METHOD_SET_FLUSH_MODE -> {
                setFlushMode(call.arguments, result)
            }
            METHOD_GET_FLUSH_PERIOD -> {
                getFlushPeriod(result)
            }
            METHOD_SET_FLUSH_PERIOD -> {
                setFlushPeriod(call.arguments, result)
            }
            METHOD_TRACK_EVENT -> {
                trackEvent(call.arguments, result)
            }
            METHOD_TRACK_SSEC -> {
                trackSSEC(call.arguments, result)
            }
            METHOD_TRACK_SESSION_START -> {
                trackSessionStart(call.arguments, result)
            }
            METHOD_TRACK_SESSION_END -> {
                trackSessionEnd(call.arguments, result)
            }
            METHOD_FETCH_CONSENTS -> {
                fetchConsents(result)
            }
            METHOD_FETCH_RECOMMENDATIONS -> {
                fetchRecommendations(call.arguments, result)
            }
            METHOD_GET_LOG_LEVEL -> {
                getLogLevel(result)
            }
            METHOD_SET_LOG_LEVEL -> {
                setLogLevel(call.arguments, result)
            }
            METHOD_CHECK_PUSH_SETUP -> {
                checkPushSetup(result)
            }
            METHOD_REQUEST_PUSH_AUTHORIZATION -> {
                requestPushAuthorization(result)
            }
            METHOD_SET_APP_INBOX_PROVIDER -> {
                setAppInboxProvider(call.arguments, result)
            }
            METHOD_TRACK_APP_INBOX_OPENED -> {
                trackAppInboxOpened(call.arguments, result)
            }
            METHOD_TRACK_APP_INBOX_OPENED_WITHOUT_TRACKING_CONSENT -> {
                trackAppInboxOpenedWithoutTrackingConsent(call.arguments, result)
            }
            METHOD_TRACK_APP_INBOX_CLICK -> {
                trackAppInboxClick(call.arguments, result)
            }
            METHOD_TRACK_APP_INBOX_CLICK_WITHOUT_TRACKING_CONSENT -> {
                trackAppInboxClickWithoutTrackingConsent(call.arguments, result)
            }
            METHOD_MARK_APP_INBOX_AS_READ -> {
                markAppInboxAsRead(call.arguments, result)
            }
            METHOD_FETCH_APP_INBOX -> {
                fetchAppInbox(result)
            }
            METHOD_FETCH_APP_INBOX_ITEM -> {
                fetchAppInboxItem(call.arguments, result)
            }
            METHOD_TRACK_IN_APP_CONTENT_BLOCK_CLICK -> {
                trackInAppContentBlockClick(call.arguments, result)
            }
            METHOD_TRACK_IN_APP_CONTENT_BLOCK_CLICK_WITHOUT_TRACKING_CONSENT -> {
                trackInAppContentBlockClickWithoutTrackingConsent(call.arguments, result)
            }
            METHOD_TRACK_IN_APP_CONTENT_BLOCK_CLOSE -> {
                trackInAppContentBlockClose(call.arguments, result)
            }
            METHOD_TRACK_IN_APP_CONTENT_BLOCK_CLOSE_WITHOUT_TRACKING_CONSENT -> {
                trackInAppContentBlockCloseWithoutTrackingConsent(call.arguments, result)
            }
            METHOD_TRACK_IN_APP_CONTENT_BLOCK_SHOWN -> {
                trackInAppContentBlockShown(call.arguments, result)
            }
            METHOD_TRACK_IN_APP_CONTENT_BLOCK_SHOWN_WITHOUT_TRACKING_CONSENT -> {
                trackInAppContentBlockShownWithoutTrackingConsent(call.arguments, result)
            }
            METHOD_TRACK_IN_APP_CONTENT_BLOCK_ERROR -> {
                trackInAppContentBlockError(call.arguments, result)
            }
            METHOD_TRACK_IN_APP_CONTENT_BLOCK_ERROR_WITHOUT_TRACKING_CONSENT -> {
                trackInAppContentBlockErrorWithoutTrackingConsent(call.arguments, result)
            }
            METHOD_SET_IN_APP_MESSAGE_ACTION_HANDLER -> {
                setInAppMessageActionHandler(call.arguments, result)
            }
            METHOD_TRACK_IN_APP_MESSAGE_CLICK -> {
                trackInAppMessageClick(call.arguments, result)
            }
            METHOD_TRACK_IN_APP_MESSAGE_CLICK_WITHOUT_TRACKING_CONSENT -> {
                trackInAppMessageClickWithoutTrackingConsent(call.arguments, result)
            }
            METHOD_TRACK_IN_APP_MESSAGE_CLOSE -> {
                trackInAppMessageClose(call.arguments, result)
            }
            METHOD_TRACK_IN_APP_MESSAGE_CLOSE_WITHOUT_TRACKING_CONSENT -> {
                trackInAppMessageCloseWithoutTrackingConsent(call.arguments, result)
            }
            METHOD_TRACK_PAYMENT_EVENT -> {
                trackPaymentEvent(call.arguments, result)
            }
            METHOD_TRACK_PUSH_TOKEN -> {
                trackPushToken(call.arguments, result)
            }
            METHOD_TRACK_HMS_PUSH_TOKEN -> {
                trackHmsPushToken(call.arguments, result)
            }
            METHOD_HANDLE_PUSH_TOKEN -> {
                handlePushToken(call.arguments, result)
            }
            METHOD_HANDLE_HMS_PUSH_TOKEN -> {
                handleHmsPushToken(call.arguments, result)
            }
            METHOD_TRACK_CLICKED_PUSH -> {
                trackClickedPush(call.arguments, result)
            }
            METHOD_TRACK_CLICKED_PUSH_WITHOUT_TRACKING_CONSENT -> {
                trackClickedPushWithoutTrackingConsent(call.arguments, result)
            }
            METHOD_TRACK_DELIVERED_PUSH -> {
                trackDeliveredPush(call.arguments, result)
            }
            METHOD_TRACK_DELIVERED_PUSH_WITHOUT_TRACKING_CONSENT -> {
                trackDeliveredPushWithoutTrackingConsent(call.arguments, result)
            }
            METHOD_IS_BLOOMREACH_NOTIFICATION -> {
                isBloomreachNotification(call.arguments, result)
            }
            METHOD_HANDLE_CAMPAIGN_CLICK -> {
                handleCampaignClick(call.arguments, result)
            }
            METHOD_HANDLE_PUSH_NOTIFICATION_OPENED -> {
                handlePushNotificationOpened(call.arguments, result)
            }
            METHOD_HANDLE_PUSH_NOTIFICATION_OPENED_WITHOUT_TRACKING_CONSENT -> {
                handlePushNotificationOpenedWithoutTrackingConsent(call.arguments, result)
            }
            METHOD_GET_SEGMENTS -> {
                getSegments(call.arguments, result)
            }
            METHOD_REGISTER_SEGMENTATION_DATA_STREAM -> {
                registerSegmentationDataStream(call.arguments, result)
            }
            METHOD_UNREGISTER_SEGMENTATION_DATA_STREAM -> {
                unregisterSegmentationDataStream(call.arguments, result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun trackAppInboxOpened(args: Any?, result: Result) = runAsync(result) {
        requireConfigured()
        val messageData = args as Map<String, Any?>
        Sendsay.fetchAppInboxItem(messageId = messageData.getRequired("id")) { nativeMessage ->
            // we need to fetch native MessageItem; method needs syncToken and customerIds to be fetched
            if (nativeMessage == null) {
                result.error(TAG, "AppInbox message data are invalid. See logs", null)
                return@fetchAppInboxItem
            }
            Sendsay.trackAppInboxOpened(nativeMessage)
            result.success(null)
        }
    }

    private fun trackAppInboxOpenedWithoutTrackingConsent(args: Any?, result: Result) = runAsync(result) {
        requireConfigured()
        val messageData = args as Map<String, Any?>
        Sendsay.fetchAppInboxItem(messageId = messageData.getRequired("id")) { nativeMessage ->
            // we need to fetch native MessageItem; method needs syncToken and customerIds to be fetched
            if (nativeMessage == null) {
                result.error(TAG, "AppInbox message data are invalid. See logs", null)
                return@fetchAppInboxItem
            }
            Sendsay.trackAppInboxOpenedWithoutTrackingConsent(nativeMessage)
            result.success(null)
        }
    }

    private fun trackAppInboxClick(args: Any?, result: Result) = runAsync(result) {
        requireConfigured()
        val inputData = args as Map<String, Any?>
        val messageData = inputData.getRequired<HashMap<String, Any?>>("message").toMap()
        val action = AppInboxCoder.decodeAction(inputData.getRequired<HashMap<String, Any?>>("action").toMap())
            ?: throw SendsayException.common("AppInbox message action data are invalid. See logs")
        Sendsay.fetchAppInboxItem(messageId = messageData.getRequired("id")) { nativeMessage ->
            // we need to fetch native MessageItem; method needs syncToken and customerIds to be fetched
            if (nativeMessage == null) {
                result.error(TAG, "AppInbox message data are invalid. See logs", null)
                return@fetchAppInboxItem
            }
            Sendsay.trackAppInboxClick(action, nativeMessage)
            result.success(null)
        }
    }

    private fun trackAppInboxClickWithoutTrackingConsent(args: Any?, result: Result) = runAsync(result) {
        requireConfigured()
        val inputData = args as Map<String, Any?>
        val messageData = inputData.getRequired<HashMap<String, Any?>>("message").toMap()
        val action = AppInboxCoder.decodeAction(inputData.getRequired<HashMap<String, Any?>>("action").toMap())
            ?: throw SendsayException.common("AppInbox message action data are invalid. See logs")
        Sendsay.fetchAppInboxItem(messageId = messageData.getRequired("id")) { nativeMessage ->
            // we need to fetch native MessageItem; method needs syncToken and customerIds to be fetched
            if (nativeMessage == null) {
                result.error(TAG, "AppInbox message data are invalid. See logs", null)
                return@fetchAppInboxItem
            }
            Sendsay.trackAppInboxClickWithoutTrackingConsent(action, nativeMessage)
            result.success(null)
        }
    }

    private fun markAppInboxAsRead(args: Any?, result: Result) = runAsync(result) {
        requireConfigured()
        val messageData = args as Map<String, Any?>
        Sendsay.fetchAppInboxItem(messageId = messageData.getRequired("id")) { nativeMessage ->
            // we need to fetch native MessageItem; method needs syncToken and customerIds to be fetched
            if (nativeMessage == null) {
                result.error(TAG, "AppInbox message data are invalid. See logs", null)
                return@fetchAppInboxItem
            }
            Sendsay.markAppInboxAsRead(nativeMessage) { markedAsRead ->
                result.success(markedAsRead)
            }
        }
    }

    private fun fetchAppInbox(result: Result) = runAsync(result) {
        requireConfigured()
        Sendsay.fetchAppInbox { response ->
            if (response == null) {
                handler.post {
                    result.error(TAG, "AppInbox load failed. See logs", null)
                }
            } else {
                result.success(response.map { AppInboxCoder.encode(it) })
            }
        }
    }

    private fun fetchAppInboxItem(args: Any?, result: Result) = runAsync(result) {
        requireConfigured()
        val messageId = args as String
        Sendsay.fetchAppInboxItem(messageId = messageId) { nativeMessage ->
            if (nativeMessage == null) {
                handler.post {
                    result.error(TAG, "AppInbox message not found. See logs", null)
                }
            } else {
                result.success(AppInboxCoder.encode(nativeMessage))
            }
        }
    }

    private fun trackInAppContentBlockClick(args: Any?, result: Result) = runWithNoResult(result) {
        requireConfigured()
        val data = args as Map<String, Any?>
        val placeholderId = data.getRequired<String>("placeholderId")
        val contentBlockData = data.getRequired<String>("contentBlock")
        val contentBlock = SendsayGson.instance.fromJson(contentBlockData, InAppContentBlock::class.java)
        val action = InAppContentBlockActionCoder.decode(data.getRequired<HashMap<String, Any?>>("action").toMap())
        Sendsay.trackInAppContentBlockClickWithoutTrackingConsent(placeholderId = placeholderId, message = contentBlock, action = action)
    }

    private fun trackInAppContentBlockClickWithoutTrackingConsent(args: Any?, result: Result) = runWithNoResult(result) {
        requireConfigured()
        val data = args as Map<String, Any?>
        val placeholderId = data.getRequired<String>("placeholderId")
        val contentBlockData = data.getRequired<String>("contentBlock")
        val contentBlock = SendsayGson.instance.fromJson(contentBlockData, InAppContentBlock::class.java)
        val action = InAppContentBlockActionCoder.decode(data.getRequired<HashMap<String, Any?>>("action").toMap())
        Sendsay.trackInAppContentBlockClickWithoutTrackingConsent(placeholderId = placeholderId, message = contentBlock, action = action)
    }

    private fun trackInAppContentBlockClose(args: Any?, result: Result) = runWithNoResult(result) {
        requireConfigured()
        val data = args as Map<String, Any?>
        val placeholderId = data.getRequired<String>("placeholderId")
        val contentBlockData = data.getRequired<String>("contentBlock")
        val contentBlock = SendsayGson.instance.fromJson(contentBlockData, InAppContentBlock::class.java)
        Sendsay.trackInAppContentBlockClose(placeholderId = placeholderId, message = contentBlock)
    }

    private fun trackInAppContentBlockCloseWithoutTrackingConsent(args: Any?, result: Result) = runWithNoResult(result) {
        requireConfigured()
        val data = args as Map<String, Any?>
        val placeholderId = data.getRequired<String>("placeholderId")
        val contentBlockData = data.getRequired<String>("contentBlock")
        val contentBlock = SendsayGson.instance.fromJson(contentBlockData, InAppContentBlock::class.java)
        Sendsay.trackInAppContentBlockCloseWithoutTrackingConsent(placeholderId = placeholderId, message = contentBlock)
    }

    private fun trackInAppContentBlockShown(args: Any?, result: Result) = runWithNoResult(result) {
        requireConfigured()
        val data = args as Map<String, Any?>
        val placeholderId = data.getRequired<String>("placeholderId")
        val contentBlockData = data.getRequired<String>("contentBlock")
        val contentBlock = SendsayGson.instance.fromJson(contentBlockData, InAppContentBlock::class.java)
        Sendsay.trackInAppContentBlockShown(placeholderId = placeholderId, message = contentBlock)
    }

    private fun trackInAppContentBlockShownWithoutTrackingConsent(args: Any?, result: Result) = runWithNoResult(result) {
        requireConfigured()
        val data = args as Map<String, Any?>
        val placeholderId = data.getRequired<String>("placeholderId")
        val contentBlockData = data.getRequired<String>("contentBlock")
        val contentBlock = SendsayGson.instance.fromJson(contentBlockData, InAppContentBlock::class.java)
        Sendsay.trackInAppContentBlockShownWithoutTrackingConsent(placeholderId = placeholderId, message = contentBlock)
    }

    private fun trackInAppContentBlockError(args: Any?, result: Result) = runWithNoResult(result) {
        requireConfigured()
        val data = args as Map<String, Any?>
        val placeholderId = data.getRequired<String>("placeholderId")
        val contentBlockData = data.getRequired<String>("contentBlock")
        val contentBlock = SendsayGson.instance.fromJson(contentBlockData, InAppContentBlock::class.java)
        val errorMessage = data.getRequired<String>("errorMessage")
        Sendsay.trackInAppContentBlockError(placeholderId = placeholderId, message = contentBlock, errorMessage = errorMessage)
    }

    private fun trackInAppContentBlockErrorWithoutTrackingConsent(args: Any?, result: Result) = runWithNoResult(result) {
        requireConfigured()
        val data = args as Map<String, Any?>
        val placeholderId = data.getRequired<String>("placeholderId")
        val contentBlockData = data.getRequired<String>("contentBlock")
        val contentBlock = SendsayGson.instance.fromJson(contentBlockData, InAppContentBlock::class.java)
        val errorMessage = data.getRequired<String>("errorMessage")
        Sendsay.trackInAppContentBlockErrorWithoutTrackingConsent(placeholderId = placeholderId, message = contentBlock, errorMessage = errorMessage)
    }

    private fun setInAppMessageActionHandler(args: Any?, result: Result) = runWithNoResult(result) {
        requireConfigured()
        val params = args as Map<String, Any?>

        InAppMessageActionStreamHandler.currentInstance.overrideDefaultBehavior = params.getRequired("overrideDefaultBehavior")
        InAppMessageActionStreamHandler.currentInstance.trackActions = params.getRequired("trackActions")
    }

    private fun trackInAppMessageClick(args: Any?, result: Result) = runWithNoResult(result) {
        requireConfigured()
        val data = args as Map<String, Any?>
        val message = InAppMessageCoder.decode(data.getRequired<HashMap<String, Any?>>("message").toMap())
        val buttonData = data.getRequired<HashMap<String, Any?>>("button").toMap()
        Sendsay.trackInAppMessageClick(message = message, buttonText = buttonData.getRequired("text"), buttonLink = buttonData.getRequired("url"))
    }

    private fun trackInAppMessageClickWithoutTrackingConsent(args: Any?, result: Result) = runWithNoResult(result) {
        requireConfigured()
        val data = args as Map<String, Any?>
        val message = InAppMessageCoder.decode(data.getRequired<HashMap<String, Any?>>("message").toMap())
        val buttonData = data.getRequired<HashMap<String, Any?>>("button").toMap()
        Sendsay.trackInAppMessageClickWithoutTrackingConsent(message = message, buttonText = buttonData.getRequired("text"), buttonLink = buttonData.getRequired("url"))
    }

    private fun trackInAppMessageClose(args: Any?, result: Result) = runWithNoResult(result) {
        requireConfigured()
        val data = args as Map<String, Any?>
        val message = InAppMessageCoder.decode(data.getRequired<HashMap<String, Any?>>("message").toMap())
        val buttonData = data.getOptional<HashMap<String, Any?>>("button")?.toMap()
        Sendsay.trackInAppMessageClose(
            message = message,
            buttonText = buttonData?.getOptional("text"),
            interaction = data.getRequired("interaction")
        )
    }

    private fun trackInAppMessageCloseWithoutTrackingConsent(args: Any?, result: Result) = runWithNoResult(result) {
        requireConfigured()
        val data = args as Map<String, Any?>
        val message = InAppMessageCoder.decode(data.getRequired<HashMap<String, Any?>>("message").toMap())
        val buttonData = data.getOptional<HashMap<String, Any?>>("button")?.toMap()
        Sendsay.trackInAppMessageCloseWithoutTrackingConsent(
            message = message,
            buttonText = buttonData?.getOptional("text"),
            interaction = data.getRequired("interaction")
        )
    }

    private fun trackPaymentEvent(args: Any?, result: Result) = runWithNoResult(result) {
        requireConfigured()
        val data = args as Map<String, Any?>
        val timestamp = data.getOptional<Double>("timestamp")
        val purchasedItem = PurchasedItemCoder.decode(data.getRequired<HashMap<String, Any?>>("purchasedItem").toMap())
        Sendsay.trackPaymentEvent(timestamp = timestamp ?: currentTimeSeconds(),  purchasedItem = purchasedItem)
    }

    private fun trackPushToken(args: Any?, result: Result) = runWithNoResult(result) {
        requireConfigured()
        val token = args as String
        Sendsay.trackPushToken(token)
    }

    private fun trackHmsPushToken(args: Any?, result: Result) = runWithNoResult(result) {
        requireConfigured()
        val token = args as String
        Sendsay.trackHmsPushToken(token)
    }

    private fun handlePushToken(args: Any?, result: Result) = runWithNoResult(result) {
        requireConfigured()
        val token = args as String
        Sendsay.handleNewToken(activity ?: context, token)
    }

    private fun handleHmsPushToken(args: Any?, result: Result) = runWithNoResult(result) {
        requireConfigured()
        val token = args as String
        Sendsay.handleNewHmsToken(activity ?: context, token)
    }

    private fun trackClickedPush(args: Any?, result: Result) = runWithNoResult(result) {
        requireConfigured()
        val data = args as Map<String, Any?>
        val notification = NotificationCoder.decodeNotificationData(data)
        val notificationAction = NotificationCoder.decodeNotificationAction(data)
        val receivedSeconds = data.getNullSafely("receivedSeconds") ?: currentTimeSeconds()
        Sendsay.trackClickedPush(notification, notificationAction, receivedSeconds)
    }

    private fun trackClickedPushWithoutTrackingConsent(args: Any?, result: Result) = runWithNoResult(result) {
        requireConfigured()
        val data = args as Map<String, Any?>
        val notification = NotificationCoder.decodeNotificationData(data)
        val notificationAction = NotificationCoder.decodeNotificationAction(data)
        val receivedSeconds = data.getNullSafely("receivedSeconds") ?: currentTimeSeconds()
        Sendsay.trackClickedPushWithoutTrackingConsent(notification, notificationAction, receivedSeconds)
    }

    private fun trackDeliveredPush(args: Any?, result: Result) = runWithNoResult(result) {
        requireConfigured()
        val data = args as Map<String, Any?>
        val notification = NotificationCoder.decodeNotificationData(data)
        val receivedSeconds = data.getNullSafely("receivedSeconds") ?: currentTimeSeconds()
        Sendsay.trackDeliveredPush(notification, receivedSeconds)
    }

    private fun trackDeliveredPushWithoutTrackingConsent(args: Any?, result: Result) = runWithNoResult(result) {
        requireConfigured()
        val data = args as Map<String, Any?>
        val notification = NotificationCoder.decodeNotificationData(data)
        val receivedSeconds = data.getNullSafely("receivedSeconds") ?: currentTimeSeconds()
        Sendsay.trackDeliveredPushWithoutTrackingConsent(notification, receivedSeconds)
    }

    private  fun isBloomreachNotification(args: Any?, result: Result) = runWithResult(result) {
        requireConfigured()
        val data = args as Map<String, String>
        return@runWithResult Sendsay.isSendsayPushNotification(data)
    }

    private fun handleCampaignClick(args: Any?, result: Result) = runWithNoResult(result) {
        requireConfigured()
        val campaignUrl = args as String
        val campaignIntent = Intent()
        campaignIntent.action = Intent.ACTION_VIEW
        campaignIntent.data = Uri.parse(campaignUrl)
        Sendsay.handleCampaignIntent(campaignIntent, activity ?: context)
    }

    private fun handlePushNotificationOpened(args: Any?, result: Result) =
        trackClickedPush(args, result)

    private fun handlePushNotificationOpenedWithoutTrackingConsent(args: Any?, result: Result) =
        trackClickedPushWithoutTrackingConsent(args, result)

    private fun getSegments(args: Any?, result: Result) = runAsync(result) {
        requireConfigured()
        val params = args as Map<String, Any?>
        Sendsay.getSegments(
            exposingCategory = params.getRequired("exposingCategory"),
            force = params.getRequired("force")
        ) {
            result.success(it)
        }
    }

    private fun registerSegmentationDataStream(args: Any?, result: Result) = runWithResult(result) {
        requireConfigured()
        val params = args as Map<String, Any?>
        val segmentationDataCallback = FlutterSegmentationDataCallback(
            params.getRequired("exposingCategory"),
            params.getRequired("includeFirstLoad"),
        ) { callbackInstance, segments ->
            SegmentationDataStreamHandler.handle(
                SegmentationData(
                    callbackInstance.instanceId,
                    segments
                )
            )
        }
        Sendsay.registerSegmentationDataCallback(segmentationDataCallback)
        segmentationDataCallbacks.add(segmentationDataCallback)
        return@runWithResult segmentationDataCallback.instanceId
    }

    private fun unregisterSegmentationDataStream(args: Any?, result: Result) = runWithNoResult(result) {
        requireConfigured()
        val params = args as Map<String, Any?>
        val callbackInstanceId = params.getRequired<String>("instanceId")
        val segmentationCallbackToRemove = segmentationDataCallbacks.find { it.instanceId == callbackInstanceId }
        if (segmentationCallbackToRemove == null) {
            throw SendsayException.common("Segmentation data stream with instanceId $callbackInstanceId not found")
        }
        Sendsay.unregisterSegmentationDataCallback(segmentationCallbackToRemove)
        segmentationDataCallbacks.remove(segmentationCallbackToRemove)
    }

    private fun requireConfigured() {
        if (!Sendsay.isInitialized) {
            throw SendsayException.notConfigured()
        }
    }

    private fun requireNotConfigured() {
        if (Sendsay.isInitialized) {
            throw SendsayException.alreadyConfigured()
        }
    }

    private fun <T> runWithResult(result: Result, block: () -> T) {
        try {
            val res = block()
            result.success(res)
        } catch (e: Exception) {
            result.error(TAG, e.message, null)
        }
    }

    private fun runWithNoResult(result: Result, block: () -> Unit) {
        try {
            block()
            result.success(null)
        } catch (e: Exception) {
            result.error(TAG, e.message, null)
        }
    }

    private fun runAsync(result: Result, block: () -> Unit) {
        try {
            block()
        } catch (e: Exception) {
            result.error(TAG, e.message, null)
        }
    }

    private fun configure(args: Any?, result: Result) = runWithResult<Boolean>(result) {
        try {
            requireNotConfigured()
        } catch (e: Exception) {
            return@runWithResult false
        }
        val data = args as Map<String, Any?>
        val configuration = SendsayConfigurationParser().parseConfig(data)
        Sendsay.init(activity ?: context, configuration)
        this.configuration = configuration
        Sendsay.notificationDataCallback = { ReceivedPushStreamHandler.handle(ReceivedPush(it)) }
        Sendsay.inAppMessageActionCallback = InAppMessageActionStreamHandler.currentInstance
        return@runWithResult true
    }

    private fun isConfigured(result: Result) = runWithResult<Boolean>(result) {
        return@runWithResult Sendsay.isInitialized
    }

    private fun getCustomerCookie(result: Result) = runWithResult<String>(result) {
        requireConfigured()
        return@runWithResult Sendsay.customerCookie!!
    }

    private fun identifyCustomer(args: Any?, result: Result) = runWithNoResult(result) {
        requireConfigured()
        val data = args as Map<String, Any?>
        val customer = Customer.fromMap(data)
        Sendsay.identifyCustomer(
                CustomerIds(HashMap(customer.ids)),
                PropertiesList(HashMap(customer.properties)).properties
        )
    }

    private fun anonymize(args: Any?, result: Result) = runWithNoResult(result) {
        requireConfigured()
        val data = args as Map<String, Any?>
        val configChange = SendsayConfigurationParser().parseConfigChange(data, configuration!!.baseURL)
        if (configChange.project != null && configChange.mapping != null) {
            Sendsay.anonymize(configChange.project, configChange.mapping)
        } else if (configChange.project != null) {
            Sendsay.anonymize(configChange.project)
        } else if (configChange.mapping != null) {
            Sendsay.anonymize(projectRouteMap = configChange.mapping)
        } else {
            Sendsay.anonymize()
        }
    }

    private fun getDefaultProperties(result: Result) = runWithResult<Map<String, Any>>(result) {
        requireConfigured()
        Sendsay.defaultProperties
    }

    private fun setDefaultProperties(args: Any?, result: Result) = runWithNoResult(result) {
        requireConfigured()
        val data = args as Map<String, Any>
        Sendsay.defaultProperties = HashMap(data)
    }

    private fun flush(result: Result) = runWithNoResult(result) {
        requireConfigured()
        if (Sendsay.flushMode != FlushMode.MANUAL) {
            throw SendsayException.flushModeNotManual()
        }
        Sendsay.flushData()
    }

    private fun getFlushMode(result: Result) = runWithResult(result) {
        requireConfigured()
        return@runWithResult Sendsay.flushMode.name
    }

    private fun setFlushMode(args: Any?, result: Result) = runWithNoResult(result) {
        requireConfigured()
        val data = args as String
        Sendsay.flushMode = FlushMode.valueOf(data)
    }

    private fun getFlushPeriod(result: Result) = runWithResult(result) {
        requireConfigured()
        if (Sendsay.flushMode != FlushMode.PERIOD) {
            throw SendsayException.flushModeNotPeriodic()
        }
        val period = Sendsay.flushPeriod
        return@runWithResult period.timeUnit.toSeconds(period.amount)
    }

    private fun setFlushPeriod(args: Any?, result: Result) = runWithNoResult(result) {
        requireConfigured()
        if (Sendsay.flushMode != FlushMode.PERIOD) {
            throw SendsayException.flushModeNotPeriodic()
        }
        val data = args as Int
        Sendsay.flushPeriod = FlushPeriod(data.toLong(), TimeUnit.SECONDS)
    }

    private fun trackEvent(args: Any?, result: Result) = runWithNoResult(result) {
        requireConfigured()
        val data = args as Map<String, Any?>
        val event = Event.fromMap(data)
        Sendsay.trackEvent(
                PropertiesList(HashMap(event.properties)).properties,
                event.timestamp,
                event.name
        )
    }

    private fun trackSessionStart(args: Any?, result: Result) = runWithNoResult(result) {
        requireConfigured()
        val timestamp = args as? Double
        if (timestamp != null) {
            Sendsay.trackSessionStart(timestamp)
        } else {
            Sendsay.trackSessionStart()
        }
    }

    private fun trackSessionEnd(args: Any?, result: Result) = runWithNoResult(result) {
        requireConfigured()
        val timestamp = args as? Double
        if (timestamp != null) {
            Sendsay.trackSessionEnd(timestamp)
        } else {
            Sendsay.trackSessionEnd()
        }
    }

    private fun fetchConsents(result: Result) = runAsync(result) {
        requireConfigured()
        Sendsay.getConsents(
                {
                    val data = it.results.map { consent ->
                        ConsentEncoder.encode(consent)
                    }
                    handler.post {
                        result.success(data)
                    }
                },
                {
                    handler.post {
                        result.error(TAG, it.results.message, null)
                    }
                }
        )
    }

    private fun fetchRecommendations(args: Any?, result: Result) = runAsync(result) {
        requireConfigured()
        val inData = args as Map<String, Any?>
        val options = RecommendationOptionsEncoder.decode(inData)
        Log.i(TAG, "aaa $options")
        Sendsay.fetchRecommendation(
                options,
                {
                    val outData = it.results.map { recommendation ->
                        RecommendationEncoder.encode(recommendation)
                    }
                    handler.post {
                        result.success(outData)
                    }
                },
                {
                    handler.post {
                        result.error(TAG, it.results.message, null)
                    }
                }
        )
    }

    private fun getLogLevel(result: Result) = runWithResult(result) {
        requireConfigured()
        return@runWithResult Sendsay.loggerLevel.name
    }

    private fun setLogLevel(args: Any?, result: Result) = runWithNoResult(result) {
        requireConfigured()
        val logLevel = args as String
        Sendsay.loggerLevel = Logger.Level.valueOf(logLevel)
    }

    private fun checkPushSetup(result: Result) = runWithNoResult(result) {
        requireNotConfigured()
        Sendsay.checkPushSetup = true
    }

    private fun requestPushAuthorization(result: Result) = runAsync(result) {
        Sendsay.requestPushAuthorization(context) { granted ->
            result.success(granted)
        }
    }

    private fun setAppInboxProvider(args: Any, result: Result) = runWithNoResult(result) {
        val configMap = args as Map<String, Any?>
        val appInboxStyle = AppInboxStyleParser(configMap).parse()
        Sendsay.appInboxProvider = StyledAppInboxProvider(appInboxStyle)
    }


    private fun trackSSEC(args: Any?, result: Result) = runWithNoResult(result) {
        requireConfigured()
        val data = args as Map<String, Any?>
        val ssec = SSECEvent.fromMap(data)
        val trackType = TrackingSSECType.valueOf(ssec.type)
        val trackData = ssec.data.toTrackSSECData()

        Sendsay.trackSSECEvent(
            trackType,
            trackData
        )
    }
}

/**
 * Handles listeners for opened push notifications.
 */
class OpenedPushStreamHandler : StreamHandler {
    companion object {
        private var currentInstance: OpenedPushStreamHandler? = null

        // We have to hold OpenedPush until plugin is initialized and listener set
        private var pendingData: OpenedPush? = null

        fun handle(push: OpenedPush): Boolean {
            val handled = currentInstance?.internalHandle(push) ?: false
            if (!handled) {
                pendingData = push
            }
            return handled
        }
    }

    init {
        currentInstance = this
    }

    private var eventSink: EventSink? = null

    override fun onListen(arguments: Any?, eSink: EventSink?) {
        eventSink = eSink
        pendingData?.let {
            if (handle(it)) {
                pendingData = null
            }
        }
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    private fun internalHandle(push: OpenedPush): Boolean {
        val sink = eventSink
        if (sink != null) {
            sink.success(push.toMap())
            return true
        }
        return false
    }
}

/**
 * Handles listeners for received push notifications.
 */
class ReceivedPushStreamHandler : StreamHandler {
    companion object {
        private var currentInstance: ReceivedPushStreamHandler? = null

        // We have to hold OpenedPush until plugin is initialized and listener set
        private var pendingData: ReceivedPush? = null

        fun handle(push: ReceivedPush): Boolean {
            val handled = currentInstance?.internalHandle(push) ?: false
            if (!handled) {
                pendingData = push
            }
            return handled
        }
    }

    init {
        currentInstance = this
    }

    private var eventSink: EventSink? = null

    override fun onListen(arguments: Any?, eSink: EventSink?) {
        eventSink = eSink
        pendingData?.let {
            if (handle(it)) {
                pendingData = null
            }
        }
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    private fun internalHandle(push: ReceivedPush): Boolean {
        val sink = eventSink
        if (sink != null) {
            sink.success(push.toMap())
            return true
        }
        return false
    }
}

/**
 * Handles listeners for in-app message actions.
 */
class InAppMessageActionStreamHandler private constructor(
    override var overrideDefaultBehavior: Boolean = false,
    override var trackActions: Boolean = true,
) : StreamHandler, InAppMessageCallback {
    companion object {
        var currentInstance: InAppMessageActionStreamHandler = InAppMessageActionStreamHandler()
            private set
    }

    // We have to hold inAppMessage until plugin is initialized and listener set
    private var pendingData: InAppMessageAction? = null

    private var eventSink: EventSink? = null

    override fun onListen(arguments: Any?, eSink: EventSink?) {
        eventSink = eSink
        pendingData?.let {
            if (handle(it)) {
                pendingData = null
            }
        }
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
        overrideDefaultBehavior = false
        trackActions = true
    }

    override fun inAppMessageClickAction(
        message: InAppMessage,
        button: InAppMessageButton,
        context: Context
    ) {
        handle(InAppMessageAction(type = InAppMessageActionType.CLICK, message = message, button = button))
    }

    override fun inAppMessageCloseAction(
        message: InAppMessage,
        button: InAppMessageButton?,
        interaction: Boolean,
        context: Context
    ) {
        handle(
            InAppMessageAction(
                type = InAppMessageActionType.CLOSE,
                message = message,
                button = button,
                interaction = interaction
            )
        )
    }

    override fun inAppMessageError(message: InAppMessage?, errorMessage: String, context: Context) {
        handle(InAppMessageAction(type = InAppMessageActionType.ERROR, message = message, errorMessage = errorMessage))
    }

    override fun inAppMessageShown(message: InAppMessage, context: Context) {
        handle(InAppMessageAction(type = InAppMessageActionType.SHOW, message = message))
    }

    private fun handle(action: InAppMessageAction): Boolean {
        val sink = eventSink
        if (sink != null) {
            sink.success(action.toMap())
            return true
        }
        pendingData = action
        return false
    }
}

/**
 * Handles listeners for segmentation data.
 */
class SegmentationDataStreamHandler : StreamHandler {
    companion object {
        private var currentInstance: SegmentationDataStreamHandler? = null

        // We have to hold SegmentationData until plugin is initialized and listener set
        private var pendingData: SegmentationData? = null

        fun handle(segmentationData: SegmentationData): Boolean {
            val handled = currentInstance?.internalHandle(segmentationData) ?: false
            if (!handled) {
                pendingData = segmentationData
            }
            return handled
        }
    }

    init {
        currentInstance = this
    }

    private var eventSink: EventSink? = null

    override fun onListen(arguments: Any?, eSink: EventSink?) {
        eventSink = eSink
        pendingData?.let {
            if (handle(it)) {
                pendingData = null
            }
        }
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    private fun internalHandle(segmentationData: SegmentationData): Boolean {
        val sink = eventSink
        if (sink != null) {
            CoroutineScope(Dispatchers.Main).launch {
                sink.success(segmentationData.toMap())
            }
            return true
        }
        return false
    }
}