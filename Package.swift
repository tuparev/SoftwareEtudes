// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SoftwareEtudes",
    defaultLocalization: "en",
    platforms: [.macOS(.v14), .iOS(.v18), .tvOS(.v18), .watchOS(.v11), .visionOS(.v1)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name:    "SoftwareEtudesUtilities",               targets: ["SoftwareEtudesUtilities"]),
        .library(name:    "SoftwareEtudesExecutableConfiguration", targets: ["SoftwareEtudesExecutableConfiguration"]),
//        .library(name:    "SoftwareEtudesLogging",                 targets: ["SoftwareEtudesLogging"]),
//        .library(name:    "SoftwareEtudesCoreMessageDispatching",  targets: ["SoftwareEtudesCoreMessageDispatching"]),
        .executable(name: "logging-sandbox",                       targets: ["LoggingSandbox"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git",     from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(name: "SoftwareEtudesUtilities",               dependencies: [], path: "Sources/Utilities"),
        .target(name: "SoftwareEtudesExecutableConfiguration", dependencies: [], path: "Sources/ExecutableConfiguration"),
//        .target(name: "SoftwareEtudesLogging",
//                dependencies: [.product(name: "Logging", package: "swift-log"), "SoftwareEtudesCoreMessageDispatching"],
//                path: "Sources/MessageDispatching/Logging",
//                resources: [
//                    .process("Documentation.docc")
//                ]),
//        .target(name: "SoftwareEtudesCoreMessageDispatching",  dependencies: ["SoftwareEtudesUtilities"], path: "Sources/MessageDispatching/CoreMessageDispatching",
//                resources: [
//                    .copy("model.json"),
//                    .copy("TestData"),
//                    .process("Documentation.docc")
//                ]),

        .testTarget(name: "SoftwareEtudesUtilitiesTests",               dependencies: ["SoftwareEtudesUtilities"],               path: "Tests/Utilities"),
        .testTarget(name: "SoftwareEtudesExecutableConfigurationTests", dependencies: ["SoftwareEtudesExecutableConfiguration"], path: "Tests/ExecutableConfiguration"),
//        .testTarget(name: "SoftwareEtudesLoggingTests",                 dependencies: ["SoftwareEtudesLogging"],                 path: "Tests/MessageDispatching/Logging"),
//        .testTarget(name: "SoftwareEtudesCoreMessageDispatchingTests",  dependencies: ["SoftwareEtudesCoreMessageDispatching"],  path: "Tests/MessageDispatching/CoreMessageDispatching"),
        .executableTarget(
            name: "LoggingSandbox",
            dependencies: [
                .target(name: "SoftwareEtudesLogging")
            ],
            path: "Sources/LoggingSandbox"
        ),
    ],
    swiftLanguageModes: [.v5]
)
