// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FontRenderer",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(path: "../FontLoader"),
        .package(url: "https://github.com/SwiftGFX/SwiftMath", from: "3.3.1"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        .package(url: "https://github.com/thebarndog/swift-dotenv.git", .upToNextMajor(from: "2.0.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "FontRenderer",
            dependencies: [
                "FontLoader",
                "SwiftMath",
                .product(name: "SwiftDotenv", package: "swift-dotenv"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
    ]
)
