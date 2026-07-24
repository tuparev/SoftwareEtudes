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
}

public struct ConfigurationProperty: Sendable {
    public let key: String
    public var value: ConfigurationValueType

    
}
