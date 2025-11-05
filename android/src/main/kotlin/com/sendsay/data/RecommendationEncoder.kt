package com.sendsay.data

import com.sendsay.sdk.models.CustomerRecommendation
import com.sendsay.sdk.util.SendsayGson

class RecommendationEncoder {
    companion object {
        fun encode(recommendation: CustomerRecommendation): Map<String, Any?> {
            return mapOf<String, Any?>(
                "engineName" to recommendation.engineName,
                "itemId" to recommendation.itemId,
                "recommendationId" to recommendation.recommendationId,
                "recommendationVariantId" to recommendation.recommendationVariantId,
                "data" to SendsayGson.instance.toJson(recommendation.data)
            )
        }
    }
}