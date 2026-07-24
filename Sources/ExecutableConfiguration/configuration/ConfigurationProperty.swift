//
//  ConfigurationProperty.swift
//  SoftwareEtudes
//
//  Created by Georg Tuparev on 24.07.26.
//

import Foundation

public enum ConfigurationValueType: Sendable, Hashable {
    case string(String)
    case bool(Bool)
    case int(Int)
    case double(Double)
    case timestamp(Date)
    case data(Data)
    case array([ConfigurationValueType])
    case dictionary([String : ConfigurationValueType])

    case unset
    case null
    case NaN
    case infinity

    // Equatable conformance (explicit for clarity and to match hashing)
    public static func == (lhs: ConfigurationValueType, rhs: ConfigurationValueType) -> Bool {
        switch (lhs, rhs) {
            case let (.string(a), .string(b)):       return a == b
            case let (.bool(a), .bool(b)):           return a == b
            case let (.int(a), .int(b)):             return a == b
            case let (.double(a), .double(b)):       return a == b
            case let (.timestamp(a), .timestamp(b)): return a == b
            case let (.data(a), .data(b)):           return a == b
            case let (.array(a), .array(b)):         return a == b
            case let (.dictionary(a), .dictionary(b)):
                if a.count != b.count                                { return false }
                for (key, valueA) in a {
                    guard let valueB = b[key], valueA == valueB else { return false }
                }
                return true
            case (.unset, .unset):                   return true
            case (.null, .null):                     return true
            case (.NaN, .NaN):                       return true
            case (.infinity, .infinity):             return true
            default:                                 return false
        }
    }

    // Hashable conformance with stable hashing for collections
    public func hash(into hasher: inout Hasher) {
        switch self {
            case .string(let s):
                hasher.combine(0)
                hasher.combine(s)
            case .bool(let b):
                hasher.combine(1)
                hasher.combine(b)
            case .int(let i):
                hasher.combine(2)
                hasher.combine(i)
            case .double(let d):
                hasher.combine(3)
                hasher.combine(d.bitPattern)
            case .timestamp(let date):
                hasher.combine(4)
                hasher.combine(date.timeIntervalSince1970)
            case .data(let data):
                hasher.combine(5)
                hasher.combine(data)
            case .array(let arr):
                hasher.combine(6)
                for element in arr {
                    hasher.combine(element)
                }
            case .dictionary(let dict):
                hasher.combine(7)
                // Ensure order-independent hashing by sorting keys
                for key in dict.keys.sorted() {
                    hasher.combine(key)
                    if let value = dict[key] {
                        hasher.combine(value)
                    }
                }
            case .unset:    hasher.combine(8)
            case .null:     hasher.combine(9)
            case .NaN:      hasher.combine(10)
            case .infinity: hasher.combine(11)
        }
    }
}

public struct ConfigurationProperty: Sendable, Hashable {
    // Required properties
    public let keyPath: String
    public var value: ConfigurationValueType

    // Optional properties
    public var defaultValue: ConfigurationValueType?
    public var isRequired: Bool = false
    public var aliases: [String]?

    public var description: String?
    public var exampleValue: String?

    public var allowedValueSet: Set<ConfigurationValueType>?
    public var minValue: ConfigurationValueType?
    public var maxValue: ConfigurationValueType?

    public var commandLineArgumentsName: String?
    public var commandLineArgumentsModernName: String?  // e.g. --argument

    // origin {domain : setting} hierarchy - computed dynamically.
}
