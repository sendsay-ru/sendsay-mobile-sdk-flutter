package com.sendsay.exception

class SendsayDataException : Exception {
    companion object {
        fun missingProperty(property: String): SendsayDataException {
            return SendsayDataException("Property $property is required.")
        }

        fun invalidType(property: String): SendsayDataException {
            return SendsayDataException("Invalid type for $property.")
        }

        fun invalidValue(property: String, value: String): SendsayDataException {
            return SendsayDataException("Invalid value $value for $property.")
        }
    }

    constructor(message: String) : super(message)
    constructor(message: String, cause: Throwable) : super(message, cause)
}
