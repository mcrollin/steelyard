// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppStoreConnect",
    platforms: [
        .macOS(.v13),
        .iOS(.v13),
    ],
    products: [
        .library(name: "AppStoreConnect", targets: ["AppStoreConnect"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Kitura/Swift-JWT", .upToNextMajor(from: "4.0.1")),
        .package(url: "https://github.com/apple/swift-http-types", .upToNextMajor(from: "1.0.0")),
    ],
    targets: [
        .target(
            name: "AppStoreConnect", dependencies: [
                .target(name: "AppStoreConnectClient"),
                .target(name: "AppStoreConnectModels"),
            ]
        ),
        .target(
            name: "AppStoreConnectClient",
            dependencies: [
                .product(name: "SwiftJWT", package: "Swift-JWT"),
                .product(name: "HTTPTypes", package: "swift-http-types"),
                .product(name: "HTTPTypesFoundation", package: "swift-http-types"),
            ]
        ),
        .target(
            name: "AppStoreConnectModels"
        ),
    ]
)
