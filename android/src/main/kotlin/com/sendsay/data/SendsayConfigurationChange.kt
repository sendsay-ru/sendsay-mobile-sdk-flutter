package com.sendsay.data

import com.sendsay.sdk.models.EventType
import com.sendsay.sdk.models.SendsayProject

data class SendsayConfigurationChange(
    val project: SendsayProject?,
    val mapping: Map<EventType, List<SendsayProject>>?
)
