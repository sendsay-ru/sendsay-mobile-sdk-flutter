//
//  SendsayConfiguration.swift
//  sendsay
//
//  Created by Franky on 16/06/2021.
//

import Foundation
import SendsaySDK

class SendsayConfiguration {
    let projectSettings: SendsaySDK.Sendsay.ProjectSettings
    let pushNotificationTracking: SendsaySDK.Sendsay.PushNotificationTracking
    let automaticSessionTracking: SendsaySDK.Sendsay.AutomaticSessionTracking
    let flushingSetup: SendsaySDK.Sendsay.FlushingSetup
    let defaultProperties: [String: JSONConvertible]?
    var allowDefaultCustomerProperties: Bool? = nil
    var advancedAuthEnabled: Bool? = nil
    var inAppContentBlockPlaceholdersAutoLoad: [String]? = nil
    var manualSessionAutoClose: Bool = true
    
    init(_ data: [String: Any?], parser: ConfigurationParser) throws {
        self.projectSettings = try parser.parseProjectSettings(data)
        self.pushNotificationTracking = try parser.parsePushNotificationTracking(data)
        self.automaticSessionTracking = try parser.parseSessionTracking(data)
        self.flushingSetup = try parser.parseFlushingSetup(data)
        self.defaultProperties = try parser.parseDefaultProperties(data)
        if let allowDefaultCustomerProperties = data["allowDefaultCustomerProperties"] as? Bool {
            self.allowDefaultCustomerProperties = allowDefaultCustomerProperties
        }
        if let advancedAuthEnabled = data["advancedAuthEnabled"] as? Bool {
            self.advancedAuthEnabled = advancedAuthEnabled
        }
        if let inAppContentBlockPlaceholdersAutoLoad = data["inAppContentBlockPlaceholdersAutoLoad"] as? [String] {
            self.inAppContentBlockPlaceholdersAutoLoad = inAppContentBlockPlaceholdersAutoLoad
        }
        if let manualSessionAutoClose = data["manualSessionAutoClose"] as? Bool {
            self.manualSessionAutoClose = manualSessionAutoClose
        }
    }
}
