// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "steelyard",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .executable(name: "steelyard", targets: ["Steelyard"]),
    ],
    dependencies: [
        .package(url: "https://github.com/mcrollin/SteelyardCore.git", branch: "c9c53b47d776479e04680912f06822d018cd201c"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMajor(from: "1.2.0")),
        .package(url: "https://github.com/onevcat/Rainbow", .upToNextMajor(from: "4.0.0")),
    ],
    targets: [
        .executableTarget(
            name: "Steelyard",
            dependencies: [
                .target(name: "Archive"),
                .target(name: "History"),
            ]
        ),
        .target(
            name: "Archive",
            dependencies: [
                .target(name: "CommandLine"),
                .product(name: "ApplicationArchive", package: "SteelyardCore"),
                .product(name: "DesignComponents", package: "SteelyardCore"),
                .product(name: "Platform", package: "SteelyardCore"),
            ]
        ),
        .target(
            name: "CommandLine",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Rainbow", package: "Rainbow"),
            ]
        ),
        .target(
            name: "History",
            dependencies: [
                .target(name: "CommandLine"),
                .product(name: "AppStoreConnect", package: "SteelyardCore"),
                .product(name: "Platform", package: "SteelyardCore"),
            ]
        ),
    ]
)
