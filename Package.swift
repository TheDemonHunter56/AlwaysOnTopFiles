// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "WindowMirror",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "WindowMirror",
            targets: ["WindowMirror"]
        )
    ],
    targets: [
        .executableTarget(
            name: "WindowMirror"
        )
    ]
)