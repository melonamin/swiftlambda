// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swiftlambda",
    platforms: [
        .macOS(.v10_13),
    ],
    products: [
        .executable(name: "swiftlambda", targets: ["swiftlambda"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.3.1"),
        .package(url: "https://github.com/JohnSundell/ShellOut", from: "2.3.0")
    ],
    targets: [
        .target(
            name: "swiftlambda",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "ShellOut", package: "ShellOut")
            ])
    ]
)
