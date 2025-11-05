package com.sendsay.example_flutter

import com.sendsay.sdk.models.SendsayConfiguration.HttpLoggingLevel
import org.junit.Assert.assertEquals
import org.junit.Assert.fail
import org.junit.BeforeClass
import org.junit.Test

class HttpLogLevelTest {
    companion object {
        lateinit var data: List<String>

        @BeforeClass @JvmStatic fun setup() {
            data = BaseTest.readStringData("http_log_level")
        }
    }

    @Test
    fun `validate data`() {
        assertEquals(data.size, 4)
    }

    @Test
    fun `encode`() {
        for (i in 0..(data.size - 1)) {
            assertEquals(HttpLoggingLevel.values()[i].name, data[i])
        }
    }

    @Test
    fun `decode`() {
        for (i in 0..(data.size - 1)) {
            assertEquals(HttpLoggingLevel.valueOf(data[i]), HttpLoggingLevel.values()[i])
        }
    }
}
