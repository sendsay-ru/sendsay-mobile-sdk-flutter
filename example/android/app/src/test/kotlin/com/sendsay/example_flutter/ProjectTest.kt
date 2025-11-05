package com.sendsay.example_flutter

import com.sendsay.data.SendsayConfigurationParser
import org.junit.Assert.assertEquals
import org.junit.Assert.fail
import org.junit.BeforeClass
import org.junit.Test

class ProjectTest {
    companion object {
        lateinit var data: List<Map<String, Any?>>

        @BeforeClass @JvmStatic fun setup() {
            data = BaseTest.readMapData("project")
        }
    }

    @Test
    fun `validate data`() {
        assertEquals(data.size, 5)
    }

    @Test
    fun `fail to parse empty map`() {
        try {
            val parser = SendsayConfigurationParser()
            parser.parseSendsayProject(data[0], "defaultUrl")
            fail("Should throw exception")
        } catch (e: Exception) {
            assertEquals("Property projectToken is required.", e.message)
        }
    }

    @Test
    fun `fail to parse missing auth token`() {
        try {
            val parser = SendsayConfigurationParser()
            parser.parseSendsayProject(data[1], "defaultUrl")
            fail("Should throw exception")
        } catch (e: Exception) {
            assertEquals("Property authorizationToken is required.", e.message)
        }
    }

    @Test
    fun `parse with no base url`() {
        val parser = SendsayConfigurationParser()
        val project = parser.parseSendsayProject(data[2], "defaultUrl")

        assertEquals(project.projectToken, "1234567890")
        assertEquals(project.authorization, "Token 0987654321")
        assertEquals(project.baseUrl, "defaultUrl")
    }

    @Test
    fun `parse with null base url`() {
        val parser = SendsayConfigurationParser()
        val project = parser.parseSendsayProject(data[3], "defaultUrl")

        assertEquals(project.projectToken, "1234567890")
        assertEquals(project.authorization, "Token 0987654321")
        assertEquals(project.baseUrl, "defaultUrl")
    }

    @Test
    fun `parse full`() {
        val parser = SendsayConfigurationParser()
        val project = parser.parseSendsayProject(data[4], "defaultUrl")

        assertEquals(project.projectToken, "1234567890")
        assertEquals(project.authorization, "Token 0987654321")
        assertEquals(project.baseUrl, "http://a.b.c")
    }
}
