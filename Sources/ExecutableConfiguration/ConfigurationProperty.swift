//
//  ConfigurationProperty.swift
//  SoftwareEtudes
//
//  Created by Georg Tuparev on 24.07.26.
//

import Foundation

public enum ConfigurationValueType : Sendable{
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
}

public struct ConfigurationProperty: Sendable {
    // Required properties
    public let keyPath: String
    public var value: ConfigurationValueType

    // Optional properties
    public var isRequired: Bool = false
}


/*
 - aliases (optional)
 - valueType (optional), if not set -> inferred
 - defaultValue(Set) (optional)
 - description/help (optional)
 - allowedValueSet (optional)
 - min/max value (optional)
 - origin {domain : setting} hierarchy - computed dynamically.

 Settings could be:
 - simple values (e.g. timeout=30)
 - dictionaries
 - arrays
 - key-path (will be flatten to one of the above possibilities), and exist because is very useful notation.

 */

