// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Steelyard",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .executable(name: "steelyard", targets: ["Steelyard"]),
    ],
    dependencies: [
        .package(path: "Packages/AppStoreConnect"),
        .package(path: "Packages/Console"),
        .package(path: "Packages/CommandLine"),
        .package(path: "Packages/Platform"),
    ],
    targets: [
        .target(
            name: "AppSizeFetcher",
            dependencies: [
                .product(name: "AppStoreConnect", package: "AppStoreConnect"),
                .product(name: "Console", package: "Console"),
                .product(name: "CommandLine", package: "CommandLine"),
                .product(name: "Platform", package: "Platform"),
            ]
        ),
        .target(
            name: "DataCommand",
            dependencies: [
                .target(name: "AppSizeFetcher"),
            ]
        ),
        .target(
            name: "GraphCommand",
            dependencies: [
                .target(name: "AppSizeFetcher"),
            ]
        ),
        .executableTarget(
            name: "Steelyard",
            dependencies: [
                .target(name: "DataCommand"),
                .target(name: "GraphCommand"),
            ]
        ),
    ]
)
