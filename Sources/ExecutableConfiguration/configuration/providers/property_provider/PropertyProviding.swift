//
//  PropertyProviding.swift
//  SoftwareEtudes
//
//  Created by Georg Tuparev on 24.07.26.
//

import Foundation

public protocol PropertyProvidingDelegate {
    func addConfigurationProperty(_ property: ConfigurationProperty) // To allow parallel loading
}

public protocol PropertyProviding {
    var delegate: PropertyProvidingDelegate? { get set }

    func configurationProperties() async throws -> [ConfigurationProperty]
}

//MARK: Default implementations
public extension PropertyProvidingDelegate {
    func addConfigurationProperty(_ property: ConfigurationProperty) { }
}

public extension PropertyProviding {
    func configurationProperties() async throws -> [ConfigurationProperty] { [] }
}
