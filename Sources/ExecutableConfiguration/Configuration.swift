//
//  Configuration.swift
//
//
//  Created by Georg Tuparev on 07/04/2023.
//  Copyright © See Framework's LICENSE file
//

import Foundation

//MARK: - Configuration -

public protocol Configuring {
    func argumentNamesForConfigurationFilePath() -> (name: String?, longName: String?)? // e.g. ("c", "config")
    func configurationFilePath() -> String?
}


/// `Configuration` is a high-level class that provides runtime configuration of command line tools and daemons. It is based on lower level Command Line Argument Parser and on the
/// standard  UserDefaults.
///
/// 
open class Configuration {
    public enum ConfiguratorError: Error {
        case creatingCommandLineParserError
    }

    public var commandLineParser: CommandLineParser


    public init(delegate: Configuring? = nil, configurationDomains: [any ConfigurationDomainProtocol]? = [any ConfigurationDomainProtocol]()) throws {
        self.delegate = delegate // Ignore for now

        if let clp = CommandLineParser() { self.commandLineParser = clp }
        else                             { throw ConfiguratorError.creatingCommandLineParserError }

        // Finalise initiation
        completeDomaineStackFrom(template: configurationDomains!)
    }

    //MARK: Principle methods
    public func stringValueFor(key: String, domain: ConfigurationDomainHierarchyType? = nil) -> String? { nil } //TODO: Implement me!
    public func intValueFor(key: String, domain: ConfigurationDomainHierarchyType? = nil)    -> Int?    { nil } //TODO: Implement me!
    public func doubleValueFor(key: String, domain: ConfigurationDomainHierarchyType? = nil) -> Double? { nil } //TODO: Implement me!
    public func boolValueFor(key: String, domain: ConfigurationDomainHierarchyType? = nil)   -> Bool?   { nil } //TODO: Implement me!

    public func configurationItemFor(key: String, domain: ConfigurationDomainHierarchyType? = .runtime) -> (any ConfigurationItemProtocol)? {
        let domains = domainStack.filter { $0.domainType == domain }
        
        for domain in domains {
            if let item = domain.configurationItemFor(key: key) { return item }
        }
        
        return nil
    }
    
    public func setConfiguration(item: any ConfigurationItemProtocol, forKey: String, domain: ConfigurationDomainHierarchyType? = .runtime) throws { }     //TODO: Implement me!

    //MARK: - Private properties
    private var delegate: Configuring?
    private var domainStack: [any ConfigurationDomainProtocol]!
    private var configurationCache = [String :ConfigurationItem]()

    private func configurationItemFor(key: String) -> ConfigurationItem? {
        if let cachedItem = configurationCache[key] { return cachedItem }

        if let newItem = configurationItemFromStackFor(key: key) {
            configurationCache[key] = newItem
            return newItem
        }

        return nil
    }

    private func configurationItemFromStackFor(key: String) -> ConfigurationItem? {

        //TODO: Implement me!
        nil
    }

    private func completeDomaineStackFrom(template: [any ConfigurationDomainProtocol]) {
        domainStack = [any ConfigurationDomainProtocol]()

        ConfigurationDomainHierarchyType.allCases.forEach {
            var domain = configurationDomainOf(type: $0, domainList: template)

            if domain == nil { domain = ConfigurationDomain(domain: $0) }
            domainStack.append(domain!)
        }
    }

    /// If `domainList` is `nil`, the method searches in `domainStack`.
    private func configurationDomainOf(type: ConfigurationDomainHierarchyType, domainList: [(any ConfigurationDomainProtocol)]? = nil) ->  (any ConfigurationDomainProtocol)? {
        let domainsToSearch = domainList != nil ? domainList! : domainStack!

        for aDomain in domainsToSearch {
            if aDomain.domainType == type { return aDomain}
        }
        return nil
    }
}

//MARK: - Default Configuring implementation -
public extension Configuring {
    func argumentNamesForConfigurationFilePath() -> (name: String?, longName: String?)? { (name: "c", longName: "config") }
    func configurationFilePath()                 -> String? { nil }
}

