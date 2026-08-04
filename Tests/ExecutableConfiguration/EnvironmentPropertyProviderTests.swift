//
//  EnvironmentPropertyProviderTests.swift
//  SoftwareEtudes
//
//  Created by Zhanna Hakobyan on 03.08.26.
//

import XCTest
@testable import SoftwareEtudesExecutableConfiguration

final class EnvironmentPropertyProviderTests: XCTestCase {

    let sampleEnvironment = [
        "SERVER_HOST": "127.0.0.1",
        "SERVER_PORT": "8080",
        "DEBUG_ENABLED": "true"
    ]

    func test_configurationProperties_usesOnlySelectedDefaults() async throws {
        // Given
        let sut = EnvironmentPropertyProvider(
            policy: .useSelectedDefaults,
            selectedKeys: [
                "SERVER_HOST",
                "SERVER_PORT"
            ],
            environment: sampleEnvironment
        )

        // When
        let properties = try await sut.configurationProperties()

        let propertiesByKeyPath = Dictionary(
            uniqueKeysWithValues: properties.map {
                ($0.keyPath, $0.value)
            }
        )

        // Then
        XCTExpectFailure("EnvironmentPropertyProvider.configurationProperties() not implemented yet") {
            XCTAssertEqual(properties.count, 2)
            XCTAssertEqual(propertiesByKeyPath["server.host"], .string("127.0.0.1"))
            XCTAssertEqual(propertiesByKeyPath["server.port"], .string("8080"))
            XCTAssertNil(propertiesByKeyPath["debug.enabled"])
        }
    }

    func test_configurationProperties_usesAllDefaults() async throws {
        // Given
        let sut = EnvironmentPropertyProvider(
            policy: .useAllDefaults,
            environment: sampleEnvironment
        )

        // When
        let properties = try await sut.configurationProperties()

        let propertiesByKeyPath = Dictionary(
            uniqueKeysWithValues: properties.map {
                ($0.keyPath, $0.value)
            }
        )

        // Then
        XCTExpectFailure("EnvironmentPropertyProvider.configurationProperties() not implemented yet") {
            XCTAssertEqual(properties.count, 3)
            XCTAssertEqual(propertiesByKeyPath["server.host"],   .string("127.0.0.1"))
            XCTAssertEqual(propertiesByKeyPath["server.port"],   .string("8080"))
            XCTAssertEqual(propertiesByKeyPath["debug.enabled"], .string("true"))
        }
    }
    
    static var allTests = [
        ("test_configurationProperties_usesOnlySelectedDefaults", test_configurationProperties_usesOnlySelectedDefaults),
        ("test_configurationProperties_usesAllDefaults",          test_configurationProperties_usesAllDefaults)
    ]
}
