// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Test",
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "1.13.0"),
        .package(url: "https://github.com/apple/swift-package-manager.git", from: "0.3.0")
    ],
    targets: [
        .target(
            name: "Test",
            dependencies: ["Aqueduct"]),
        .target(
            name: "Aqueduct",
            dependencies: ["NIO", "NIOHTTP1", "Utility"]),
        .testTarget(
            name: "TestTests",
            dependencies: ["Test"]),
    ]
)
