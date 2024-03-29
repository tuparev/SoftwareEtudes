//
//  ConfigurationItem.swift
//
//
//  Created by Georg Tuparev on 14.01.24.
//  Copyright © See Framework's LICENSE file
//

import Foundation

public enum ConfigurationItemValueType: String, Codable {
    case string  // Default
    case int
    case double
    case bool
}

public protocol ConfigurationItemProtocol {
    var key: String                                { get }
    var isRequiredItem: Bool?                      { get }
    var itemValueType: ConfigurationItemValueType? { get }
    var value: String?                             { get set }
    var defaultValueIfRequired: String?            { get }
    var exampleValue: String?                      { get }
    var commandLineArgumentsName: String?          { get }
    var commandLineArgumentsModernName: String?    { get }  // e.g. --argument
    var usageDescription: String?                  { get }

    func isRequired() -> Bool                        // Default value - false
    func itemType() -> ConfigurationItemValueType    // Default is .string
}

public struct ConfigurationItem: Codable, ConfigurationItemProtocol {
    public var key: String
    public var isRequiredItem: Bool?
    public var itemValueType: ConfigurationItemValueType?
    public var value: String?
    public var defaultValueIfRequired: String?
    public var exampleValue: String?
    public var commandLineArgumentsName: String?
    public var commandLineArgumentsModernName: String?
    public var usageDescription: String?

    public init(key: String,
                isRequiredItem: Bool?                      = nil,
                itemValueType: ConfigurationItemValueType? = nil,
                value: String?                             = nil,
                defaultValueIfRequired: String?            = nil,
                exampleValue: String?                      = nil,
                commandLineArgumentsName: String?          = nil,
                commandLineArgumentsModernName: String?    = nil,
                usageDescription: String?                  = nil) {
        self.key                            = key
        self.isRequiredItem                 = isRequiredItem
        self.itemValueType                  = itemValueType
        self.value                          = value
        self.defaultValueIfRequired         = defaultValueIfRequired
        self.exampleValue                   = exampleValue
        self.commandLineArgumentsName       = commandLineArgumentsName
        self.commandLineArgumentsModernName = commandLineArgumentsModernName
        self.usageDescription               = usageDescription
    }

    public func stringValueFor() -> String? { itemValueType  == .string ? value : nil }
    public func intValueFor()    -> Int?    { (itemValueType == .int)    && (value != nil) ? Int(value!) : nil }
    public func doubleValueFor() -> Double? { (itemValueType == .double) && (value != nil) ? Double(value!) : nil }
    public func boolValueFor()   -> Bool?   { (itemValueType == .bool)   && (value != nil) ? Bool(value!) : nil }
}

//MARK: - Extensions -
public  extension ConfigurationItemProtocol {
    func isRequired() -> Bool                     { isRequiredItem != nil ? isRequiredItem! : false }
    func itemType() -> ConfigurationItemValueType { itemValueType != nil ? itemValueType! : .string }
}
