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
        // TODO: Convert string values.
        // TODO: Create configuration properties.

        return []
    }
}
