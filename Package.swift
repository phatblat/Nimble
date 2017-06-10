// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Nimble",
    products: [
        .library(name: "Nimble", targets: ["Nimble"])
    ],
    targets: [
        .target(
            name: "Nimble",
            dependencies: [],
            path: "Sources/Nimble"
        ),
        .testTarget(
            name: "NimbleTests",
            dependencies: [
                .target(name: "Nimble"),
            ],
            path: "Tests/NimbleTests",
            exclude: [
                "objc",
            ]
        ),
    ],
    swiftLanguageVersions: [4]
)
