//
//  JsonDataParser.swift
//  Sendsay
//

import Foundation
import SendsaySDK


struct JsonDataParser {
    static func parse(dictionary: [String: Any?]) throws -> [String: JSONValue] {
        var data: [String: JSONValue] = [:]
        try dictionary.forEach { key, value in
            if let usedValue = value {
                data[key] = try parseValue(value: usedValue)
            }
        }
        return data
    }
    
    static func parseArray(array: NSArray) throws -> [JSONValue] {
        return try array.map { try parseValue(value: $0) }
    }
    
    static func parseValue(value: Any) throws -> JSONValue {
        if let dictionary = value as? [String:Any?] {
            return .dictionary(try parse(dictionary: dictionary))
        }
        if let array = value as? NSArray {
            return .array(try parseArray(array: array))
        }
        if let number = value as? NSNumber {
            if number === kCFBooleanFalse {
                return .bool(false)
            } else if number === kCFBooleanTrue {
                return .bool(true)
            } else {
                return .double(number.doubleValue)
            }
        } else if let string = value as? NSString {
            return .string(string as String)
        }
        throw SendsayDataError.invalidType(for: "value in data '\(type(of: value))'")
    }
}
