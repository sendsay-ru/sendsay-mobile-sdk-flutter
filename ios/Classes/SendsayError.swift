//
//  SendsayError.swift
//  Sendsay
//

import Foundation

enum SendsayError: LocalizedError {
    case notConfigured
    case alreadyConfigured
    case flushModeNotPeriodic
    case notAvailableForPlatform(name: String)
    case fetchError(description: String)
    
    public var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Sendsay SDK is not configured. Call Sendsay.configure() before calling functions of the SDK"
        case .alreadyConfigured:
            return "Sendsay SDK was already configured."
        case .flushModeNotPeriodic:
            return "Flush mode is not periodic."
        case .notAvailableForPlatform(let name):
            return "\(name) is not available for iOS platform."
        case .fetchError(let description):
            return "Data fetching failed: \(description)"
        }
    }
}
