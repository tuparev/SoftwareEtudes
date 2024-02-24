//
//  ConfigurationDomain.swift
//  
//
//  Created by Georg Tuparev on 15/01/2024.
//  Copyright © See Framework's LICENSE file
//

import Foundation

public enum ConfigurationDomainHierarchyType: Int, Codable, CaseIterable {
    case runtime               = 99
    case commandLine           = 30
    case user                  = 20
    case externalConfiguration = 10
    case registration          = 0

    public func description() -> String {
        switch self {
            case .runtime:               return "Runtime"
            case .commandLine:           return "Command Line"
            case .user:                  return "Defined by User Defaults"
            case .externalConfiguration: return "From External Configuration File"
            case .registration:          return "Defined by the Developer(s)"
        }
    }
}

public protocol ConfigurationDomainProtocol {
    var domainType: ConfigurationDomainHierarchyType { get }

    func configurationItemFor(key: String) -> (any ConfigurationItemProtocol)?
    mutating func setConfiguration(item: any ConfigurationItemProtocol, for key: String)
}

public struct ConfigurationDomain: ConfigurationDomainProtocol {
    public var domainType: ConfigurationDomainHierarchyType

    public init(domain: ConfigurationDomainHierarchyType, configurationItems: [String : any ConfigurationItemProtocol]? = [String : any ConfigurationItemProtocol]()) {
        self.domainType         = domain
        self.configurationItems = configurationItems!
    }

    public func configurationItemFor(key: String) -> (ConfigurationItemProtocol)?           { configurationItems[key] }
    public mutating func setConfiguration(item: ConfigurationItemProtocol, for key: String) { configurationItems[key] = item }

    //MARK: - Private stuff -
    private var configurationItems: [String : ConfigurationItemProtocol]
}

