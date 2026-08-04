//
//  EnvironmentPropertyProvider.swift
//  SoftwareEtudes
//
//  Created by Georg Tuparev on 29.07.26.
//

import Foundation

open class EnvironmentPropertyProvider: PropertyProviding {

    public var delegate: PropertyProvidingDelegate?
    public let policy: EnvironmentUsagePolicy
    public let selectedKeys: Set<String>

    private let environment: [String: String]

    public init(
        policy: EnvironmentUsagePolicy = .useSelectedDefaults,
        selectedKeys: Set<String> = [],
        environment: [String: String] = ProcessInfo.processInfo.environment
    ) {
        self.policy       = policy
        self.selectedKeys = selectedKeys
        self.environment  = environment
    }

    public func configurationProperties() async throws -> [ConfigurationProperty] {
        // TODO: Implement me!
        // TODO: Select variables based on the policy.
        // TODO: Map variable names to key paths.
        // TODO: Convert string values.
        // TODO: Create configuration properties.

        return []
    }
}

private extension EnvironmentPropertyProvider {
    func selectedEnvironmentVariables() -> [String: String] {
        // TODO: Return selected environment variables.
        [:]
    }

    func configurationKeyPath(fromEnvironmentKey key: String) -> String {
        // TODO: Define the environment-key mapping strategy.
        key
    }

    func configurationValue(from stringValue: String) -> ConfigurationValueType {
        // TODO: Convert the string using the property.
        .string(stringValue)
    }
}

