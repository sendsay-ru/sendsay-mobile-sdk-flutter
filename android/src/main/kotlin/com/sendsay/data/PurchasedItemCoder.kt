package com.sendsay.data

import com.sendsay.getRequired
import com.sendsay.sdk.models.PurchasedItem

class PurchasedItemCoder {
    companion object {
        fun decode(source: Map<String, Any?>): PurchasedItem {
            return PurchasedItem(
                value = source.getRequired("value"),
                currency = source.getRequired("currency"),
                paymentSystem = source.getRequired("paymentSystem"),
                productId = source.getRequired("productId"),
                productTitle = source.getRequired("productTitle"),
                receipt = source.getOptional("receipt")
            )
        }
    }
}