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
        .library(name: "SoftwareEtudesLogger",                  targets: ["SoftwareEtudesLogger"]),
        .executable(name: "SoftwareEtudesMessaging",            targets: ["SoftwareEtudesMessaging"])
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(name: "SoftwareEtudesUtilities",               dependencies: [], path: "Sources/Utilities"),
        .target(name: "SoftwareEtudesMessages",                dependencies: [], path: "Sources/Messages"),
        .target(name: "SoftwareEtudesExecutableConfiguration", dependencies: [], path: "Sources/ExecutableConfiguration"),
        .target(name: "SoftwareEtudesLogger",                  dependencies: [], path: "Sources/Logger"),
        .executableTarget(name: "SoftwareEtudesMessaging",     dependencies: ["SoftwareEtudesMessages", "SoftwareEtudesLogger"], path: "Sources/Messaging"),

        .testTarget(name: "SoftwareEtudesUtilitiesTests",               dependencies: ["SoftwareEtudesUtilities"],               path: "Tests/Utilities"),
        .testTarget(name: "SoftwareEtudesMessagesTests",                dependencies: ["SoftwareEtudesMessages"],                path: "Tests/Messages"),
        .testTarget(name: "SoftwareEtudesExecutableConfigurationTests", dependencies: ["SoftwareEtudesExecutableConfiguration"], path: "Tests/ExecutableConfiguration"),
    ]
)
