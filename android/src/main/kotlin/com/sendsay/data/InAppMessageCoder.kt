package com.sendsay.data

import com.sendsay.getRequired
import com.sendsay.sdk.models.DateFilter
import com.sendsay.sdk.models.InAppMessage
import com.sendsay.sdk.models.InAppMessagePayload
import com.sendsay.sdk.models.eventfilter.EventFilter
import com.sendsay.sdk.util.SendsayGson

class InAppMessageCoder {
    companion object {
        fun encode(source: InAppMessage): Map<String, Any?> {
            return mapOf(
                "id" to source.id,
                "name" to source.name,
                "messageType" to source.messageType.value,
                "frequency" to source.frequency?.value,
                "payload" to source.payload?.let {
                    SendsayGson.instance.toJson(it)
                },
                "variantId" to source.variantId,
                "variantName" to source.variantName,
                "trigger" to source.trigger?.let {
                    SendsayGson.instance.toJson(it)
                },
                "dateFilter" to SendsayGson.instance.toJson(source.dateFilter),
                "loadPriority" to source.priority,
                "loadDelay" to source.delay,
                "closeTimeout" to source.timeout,
                "payloadHtml" to source.payloadHtml,
                "isHtml" to source.isHtml,
                "hasTrackingConsent" to source.hasTrackingConsent,
                "consentCategoryTracking" to source.consentCategoryTracking,
                "isRichText" to source.isRichText,
            )
        }

        fun decode(source: Map<String, Any?>): InAppMessage {
            return InAppMessage(
                id = source.getRequired("id"),
                name = source.getRequired("name"),
                rawMessageType = source.getOptional("messageType"),
                rawFrequency = source.getRequired("frequency"),
                payload = SendsayGson.instance.fromJson(source.getOptional<String>("payload"), InAppMessagePayload::class.java),
                variantId = source.getRequired("variantId"),
                variantName = source.getRequired("variantName"),
                trigger = SendsayGson.instance.fromJson(source.getOptional<String>("trigger"), EventFilter::class.java),
                dateFilter = SendsayGson.instance.fromJson(source.getOptional<String>("dateFilter"), DateFilter::class.java),
                priority = source.getOptional("loadPriority"),
                delay = source.getOptional<Int>("loadDelay")?.toLong(),
                timeout = source.getOptional<Int>("closeTimeout")?.toLong(),
                payloadHtml = source.getOptional("payloadHtml"),
                isHtml = source.getOptional("isHtml"),
                rawHasTrackingConsent = source.getOptional("hasTrackingConsent"),
                consentCategoryTracking = source.getOptional("consentCategoryTracking"),
                isRichText = source.getOptional("isRichText"),
            )
        }
    }
}