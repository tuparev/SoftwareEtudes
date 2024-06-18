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
    case commandLine           = 70
    case user                  = 50
    case externalConfiguration = 20
    case userDefaults          = 10
    case registration          = 0

    public func description() -> String {
        switch self {
        case .runtime:               return "Runtime"
        case .commandLine:           return "Command Line"
        case .user:                  return "Defined by User Defaults"
        case .externalConfiguration: return "From External Configuration File"
        case .userDefaults:          return "From OS level User Defaults"
        case .registration:          return "Defined by the Developer(s)"
        }
    }
}

public protocol ConfigurationDomainProtocol: Identifiable {
    var domainType: ConfigurationDomainHierarchyType { get }

//    func allKeys() -> [String]

    func configurationItemFor(key: String) -> (any ConfigurationItemProtocol)?
    mutating func setConfiguration(item: any ConfigurationItemProtocol, for key: String)
}

open class ConfigurationDomain: ConfigurationDomainProtocol {
    public var id: UUID
    public var domainType: ConfigurationDomainHierarchyType
    public var name: String?
    
    public init(id: UUID? = UUID(),
                domain: ConfigurationDomainHierarchyType,
                configurationItems: [String : any ConfigurationItemProtocol]? = [String : any ConfigurationItemProtocol]()) {
        self.id                 = id!
        self.domainType         = domain
        self.configurationItems = configurationItems!
    }

    public func configurationItemFor(key: String) -> (ConfigurationItemProtocol)?  { configurationItems[key] }
    public func setConfiguration(item: ConfigurationItemProtocol, for key: String) { configurationItems[key] = item }

    //MARK: - Private stuff -
    private var configurationItems: [String : ConfigurationItemProtocol]
}

//TODO: Extensions to convert different sources into domains (e.g. config file, UserDefaults, ...)
