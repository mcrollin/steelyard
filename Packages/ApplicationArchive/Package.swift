// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ApplicationArchive",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .library(name: "ApplicationArchive", targets: ["ApplicationBuildTree"]),
    ],
    dependencies: [
        .package(url: "https://github.com/marmelroy/Zip.git", .upToNextMajor(from: "2.1.0")),
    ],
    targets: [
        .target(
            name: "ApplicationBuildTree", dependencies: [
                .product(name: "Zip", package: "Zip"),
            ]
        ),
    ]
)
