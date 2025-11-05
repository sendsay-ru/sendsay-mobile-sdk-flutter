//
//  DictionaryExtensions.swift
//  Sendsay
//

import Foundation

extension Dictionary where Key == String, Value == Any? {
    func getOptional<T>(_ property: String) throws -> T? {
        if let value = self[property] {
            guard value != nil else {
                return nil
            }
            guard let value = value as? T else {
                throw SendsayDataError.invalidType(for: property)
            }
            return value
        }
        return nil
    }

    func getRequired<T>(_ property: String) throws -> T {
        guard let anyValue = self[property] else {
            throw SendsayDataError.missingProperty(property: property)
        }
        guard let value = anyValue as? T else {
            throw SendsayDataError.invalidType(for: property)
        }
        return value
    }
}
