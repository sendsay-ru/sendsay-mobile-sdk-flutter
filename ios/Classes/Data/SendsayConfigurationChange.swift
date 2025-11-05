//
//  SendsayConfigurationChange.swift
//  sendsay
//
//  Created by Franky on 12/06/2021.
//

import Foundation
import SendsaySDK

class SendsayConfigurationChange {
    let project: SendsayProject?
    let mapping: [EventType : [SendsayProject]]?
    
    init(_ data: [String:Any?], parser: ConfigurationParser, baseUrl: String) throws {
        if let projectData = data["project"] as? [String:Any?] {
            self.project = try parser.parseSendsayProject(projectData, defaultBaseUrl: baseUrl)
        } else {
            self.project = nil
        }
        if let mappingData = data["mapping"] as? [String:Any?] {
            self.mapping = try parser.parseProjectMapping(mappingData, defaultBaseUrl: self.project?.baseUrl ?? baseUrl)
        } else {
            self.mapping = nil
        }
    }
}
