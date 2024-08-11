// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AirTag",
    platforms: [.macOS(.v14)],
    products: [
        .library(
            name: "AirTag",
            targets: ["AirTag"]
        ),
        .executable(
            name: "Holders",
            targets: ["Holders"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/tomasf/SwiftSCAD.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "AirTag",
            dependencies: ["SwiftSCAD"]
        ),
        .executableTarget(
            name: "Holders",
            dependencies: ["AirTag", "SwiftSCAD"]
        ),
    ]
)
