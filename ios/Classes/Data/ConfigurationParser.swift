//
//  ConfigurationParser.swift
//  Sendsay
//

import Foundation
import SendsaySDK

class ConfigurationParser {
    func parseConfig(_ data: [String:Any?]) throws -> SendsayConfiguration {
        return try SendsayConfiguration(data, parser: self)
    }

    func parseConfigChange(_ data: [String:Any?], defaultBaseUrl: String) throws -> SendsayConfigurationChange {
        return try SendsayConfigurationChange(data, parser: self, baseUrl: defaultBaseUrl)
    }

    func parseSendsayProject(_ projectData: [String:Any?], defaultBaseUrl: String) throws -> SendsayProject {
        let projectToken: String = try projectData.getRequired("projectToken")
        let authorizationToken: String = try projectData.getRequired("authorizationToken")
        let baseUrl: String = try projectData.getOptional("baseUrl") ?? defaultBaseUrl
        return SendsayProject(baseUrl: baseUrl, projectToken: projectToken, authorization: .token(authorizationToken))
    }

    func parseProjectMapping(
        _ mappingData: [String:Any?],
        defaultBaseUrl: String
    ) throws -> [EventType: [SendsayProject]] {
        var res: [EventType: [SendsayProject]]  = [:]

        for (key, value) in mappingData {
            guard let eventType = EventType(rawValue: key) else {
                throw SendsayDataError.invalidValue(for: "eventType key")
            }
            guard let projectArray = value as? [Any] else {
                continue // skip empty values
            }
            let sendsayProjects: [SendsayProject] = try projectArray.map { project in
                guard let project = project as? [String:Any?] else {
                    throw SendsayDataError.invalidType(for: "project in project list in project mapping")
                }
                return try parseSendsayProject(project, defaultBaseUrl: defaultBaseUrl)
            }
            res[eventType] = sendsayProjects
        }

        return res
    }

    func parseProjectSettings(_ data: [String:Any?]) throws -> SendsaySDK.Sendsay.ProjectSettings {
        let projectToken: String = try data.getRequired("projectToken")
        let authorizationToken: String = try data.getRequired("authorizationToken")
        let baseUrl: String = try data.getOptional("baseUrl") ?? SendsaySDK.Constants.Repository.baseUrl
        var projectMapping: [EventType: [SendsayProject]]?
        if let mapping: [String:Any?] = try data.getOptional("projectMapping") {
            projectMapping = try parseProjectMapping(mapping, defaultBaseUrl: baseUrl)
        }
        return SendsaySDK.Sendsay.ProjectSettings(
            projectToken: projectToken,
            authorization: SendsaySDK.Authorization.token(authorizationToken),
            baseUrl: baseUrl,
            projectMapping: projectMapping
        )
    }

    func parsePushNotificationTracking(_ data: [String:Any?]) throws -> SendsaySDK.Sendsay.PushNotificationTracking {
        let iosData: [String:Any?] = try data.getOptional("ios") ?? [:]
        let appGroup: String = try iosData.getOptional("appGroup") ?? ""
        let requirePushAuthorization: Bool = try data.getOptional("requirePushAuthorization") ??
            iosData.getOptional("requirePushAuthorization") ?? true
        var frequency: TokenTrackFrequency?
        if let frequencyString: String = try data.getOptional("pushTokenTrackingFrequency") {
            switch frequencyString {
            case "ON_TOKEN_CHANGE": frequency = .onTokenChange
            case "EVERY_LAUNCH": frequency = .everyLaunch
            case "DAILY": frequency = .daily
            default: throw SendsayDataError.invalidValue(for: "pushTokenTrackingFrequency")
            }
        }

        if let frequency = frequency {
            return SendsaySDK.Sendsay.PushNotificationTracking.enabled(
                appGroup: appGroup,
                requirePushAuthorization: requirePushAuthorization,
                tokenTrackFrequency: frequency
            )
        } else {
            return SendsaySDK.Sendsay.PushNotificationTracking.enabled(
                appGroup: appGroup,
                requirePushAuthorization: requirePushAuthorization
            )
        }
    }

    func parseSessionTracking(_ data: [String:Any?]) throws -> SendsaySDK.Sendsay.AutomaticSessionTracking {
        let automaticSessionTracking: Bool = try data.getOptional("automaticSessionTracking") ?? true
        let timeout: Double = try data.getOptional("sessionTimeout") ?? SendsaySDK.Constants.Session.defaultTimeout
        return automaticSessionTracking ? .enabled(timeout: timeout) : .disabled
    }

    func parseDefaultProperties(_ data: [String:Any?]) throws -> [String: JSONConvertible]? {
        if let props: [String:Any?] = try data.getOptional("defaultProperties") {
            return try JsonDataParser.parse(dictionary: props)
        }
        return nil
    }

    func parseFlushingSetup(_ data: [String:Any?]) throws -> SendsaySDK.Sendsay.FlushingSetup {
        let maxRetries: Int = try data.getOptional("flushMaxRetries") ?? SendsaySDK.Constants.Session.maxRetries
        return SendsaySDK.Sendsay.FlushingSetup(mode: .immediate, maxRetries: maxRetries)
    }

}
