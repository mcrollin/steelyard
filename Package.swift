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
        .library(name: "App", targets: ["ApplicationArchive", "TreeMap"])
    ],
    dependencies: [
        .package(path: "Packages/AppStoreConnect"),
        .package(path: "Packages/CommandLine"),
        .package(path: "Packages/Platform"),
        .package(url: "https://github.com/marmelroy/Zip.git", .upToNextMajor(from: "2.1.0")),
    ],
    targets: [
        .executableTarget(
            name: "Steelyard",
            dependencies: [
                .target(name: "Build"),
                .target(name: "History"),
            ]
        ),
        .target(
            name: "ApplicationArchive",
            dependencies: [
                .product(name: "Platform", package: "Platform"),
                .product(name: "Zip", package: "Zip"),
            ]
        ),
        .target(
            name: "Build",
            dependencies: [
                .target(name: "ApplicationArchive"),
                .target(name: "TreeMap"),
                .product(name: "CommandLine", package: "CommandLine"),
                .product(name: "Platform", package: "Platform"),
            ]
        ),
        .target(
            name: "History",
            dependencies: [
                .product(name: "AppStoreConnect", package: "AppStoreConnect"),
                .product(name: "CommandLine", package: "CommandLine"),
                .product(name: "Platform", package: "Platform"),
            ]
        ),
        .target(
            name: "TreeMap",
            dependencies: [
                .product(name: "Platform", package: "Platform"),
            ]
        ),
    ]
)
