// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SoftwareEtudes",
    defaultLocalization: "en",
    platforms: [.macOS(.v13), .iOS(.v16), .tvOS(.v16), .watchOS(.v9), .visionOS(.v1)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: "SoftwareEtudesUtilities", targets: ["SoftwareEtudesUtilities"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(name: "SoftwareEtudesUtilities", dependencies: [], path: "Sources/Utilities"),

        .testTarget(name: "SoftwareEtudesUtilitiesTests", dependencies: ["SoftwareEtudesUtilities"], path: "Tests/Utilities"),
    ]
)
