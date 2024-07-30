// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SoftwareEtudes",
    defaultLocalization: "en",
    platforms: [.macOS(.v13), .iOS(.v16), .tvOS(.v16), .watchOS(.v9), .visionOS(.v1)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: "SoftwareEtudesUtilities",               targets: ["SoftwareEtudesUtilities"]),
        .library(name: "SoftwareEtudesMessages",                targets: ["SoftwareEtudesMessages"]),
        .library(name: "SoftwareEtudesExecutableConfiguration", targets: ["SoftwareEtudesExecutableConfiguration"]),
        .library(name: "SoftwareEtudesLogger",                  targets: ["SoftwareEtudesLogger"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(name: "SoftwareEtudesUtilities",               dependencies: [],                         path: "Sources/Utilities"),
        .target(name: "SoftwareEtudesMessages",                dependencies: [],                         path: "Sources/Messages"),
        .target(name: "SoftwareEtudesExecutableConfiguration", dependencies: [],                         path: "Sources/ExecutableConfiguration"),
        .target(name: "SoftwareEtudesLogger",                  dependencies: [
            "SoftwareEtudesMessages",
            .product(name: "Logging", package: "swift-log"),
        ], path: "Sources/Logger"),

        .testTarget(name: "SoftwareEtudesUtilitiesTests",               dependencies: ["SoftwareEtudesUtilities"],                        path: "Tests/Utilities"),
        .testTarget(name: "SoftwareEtudesMessagesTests",                dependencies: ["SoftwareEtudesMessages"],                         path: "Tests/Messages"),
        .testTarget(name: "SoftwareEtudesExecutableConfigurationTests", dependencies: ["SoftwareEtudesExecutableConfiguration"],          path: "Tests/ExecutableConfiguration"),
        .testTarget(name: "SoftwareEtudesLoggerTests",                  dependencies: ["SoftwareEtudesLogger", "SoftwareEtudesMessages"], path: "Tests/Logger")
    ]
)
