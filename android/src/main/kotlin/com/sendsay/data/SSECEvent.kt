package com.sendsay.data

import com.google.gson.reflect.TypeToken
import com.sendsay.sdk.models.OrderItem
import com.sendsay.sdk.models.OrderItemAdapter
import com.sendsay.sdk.models.TrackSSECData
import com.sendsay.sdk.util.SendsayGson
import io.flutter.Log

data class SSECEvent(val type: String, val data: Map<String, Any>) {

    companion object {
        val gson = SendsayGson.instance;
        val orderItemJavaType = object : TypeToken<List<OrderItem>>(){}.type

        fun fromMap(map: Map<String, Any?>): SSECEvent {
            return SSECEvent(
                type = map["type"] as String? ?: throw IllegalStateException("SSECEvent.type is required!"),
                data = (map["data"] as Map<String, Any>?) ?: throw IllegalStateException("SSECEvent.data is required!")
            )
        }

        fun Map<String, Any>.toTrackSSECData(): TrackSSECData {
            return TrackSSECData(
                productId           = this["productId"] as? String,
                productName         = this["productName"] as? String,
                picture             = (this["picture"] as? List<*>)?.map { it as String },
                url                 = this["url"] as? String,
                available           = (this["available"] as? Number)?.toLong(),
                categoryPaths       = (this["categoryPaths"] as? List<*>)?.map { it as String },
                categoryId          = (this["categoryId"] as? Number)?.toLong(),
                category            = this["category"] as? String,
                description         = this["description"] as? String,
                vendor              = this["vendor"] as? String,
                model               = this["model"] as? String,
                type                = this["type"] as? String,
                price               = (this["price"] as? Number)?.toDouble(),
                oldPrice            = (this["oldPrice"] as? Number)?.toDouble(),
                updatePerItem       = (this["updatePerItem"] as? Number)?.toInt(),
                update              = (this["update"] as? Number)?.toInt(),
                transactionId       = this["transactionId"] as? String,
                transactionDt       = this["transactionDt"] as? String,
                transactionStatus   = (this["transactionStatus"] as? Number)?.toLong(),
                transactionDiscount = (this["transactionDiscount"] as? Number)?.toDouble(),
                transactionSum      = (this["transactionSum"] as? Number)?.toDouble(),
                deliveryDt          = this["deliveryDt"] as? String,
                deliveryPrice       = (this["deliveryPrice"] as? Number)?.toDouble(),
                paymentDt           = this["paymentDt"] as? String,
                items               =
                    (this["items"] as? List<Map<String, Any?>>?)?.let { raw ->
                        val raw = this["items"]
                        Log.d("DBG", "raw items = $raw (${raw?.javaClass})")

                        val json = gson.toJson(raw)
                        Log.d("DBG", "json for items = $json")
                        gson.fromJson(json, orderItemJavaType)
                    },
                subscriptionAdd     =
                    (this["subscriptionAdd"] as? List<Map<String, Any?>>?)?.let { raw ->
                        val json = gson.toJson(raw)
                        gson.fromJson(json, orderItemJavaType)
                    },
                subscriptionDelete  = (this["subscriptionDelete"] as? List<Int>),
//                cp                  = this["cp"] as? Map<String, Any>?,
            )
        }
    }
}
