package com.sendsay.exception

class SendsayException : Exception {
    companion object {
        fun notConfigured(): SendsayException {
            return SendsayException("Sendsay SDK is not configured. Call Sendsay.configure() before calling functions of the SDK")
        }

        fun alreadyConfigured(): SendsayException {
            return SendsayException("Sendsay SDK was already configured.")
        }

        fun flushModeNotPeriodic(): SendsayException {
            return SendsayException("Flush mode is not periodic.")
        }

        fun flushModeNotManual(): SendsayException {
            return SendsayException("Flush mode is not manual.")
        }

        fun notAvailableForPlatform(name: String): SendsayException {
            return SendsayException("$name is not available for iOS platform.")
        }

        fun fetchError(description: String): SendsayException {
            return SendsayException("Data fetching failed: $description.")
        }

        fun common(description: String): SendsayException {
            return SendsayException("Error occurred: $description.")
        }
    }

    constructor(message: String) : super(message)
    constructor(message: String, cause: Throwable) : super(message, cause)
}
