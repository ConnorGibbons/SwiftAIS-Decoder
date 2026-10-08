// swift-tools-version: 6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftAIS-Decoder",
    products: [
        .library(name: "SwiftAIS_Decoder", targets: ["SwiftAIS_Decoder"]),
        .executable(name: "SwiftAIS_DecoderCLI", targets: ["SwiftAIS_DecoderCLI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
        .package(url: "https://github.com/ConnorGibbons/SignalTools", branch: "main"),
        .package(url: "https://github.com/ConnorGibbons/Networking", branch: "main")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SwiftAIS_Decoder",
            dependencies: [
                .product(name: "SignalTools", package: "SignalTools")
            ],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ],
        ),
        .executableTarget(
            name: "SwiftAIS_DecoderCLI",
            dependencies: [
                "SwiftAIS_Decoder",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ],
        ),
        .testTarget(
            name: "SwiftAIS_DecoderTests",
            dependencies: [
                "SwiftAIS_Decoder",
            ],
        ),

    ]
)
