// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Ananda",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .macCatalyst(.v13),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "Ananda",
            targets: ["Ananda"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/ibireme/yyjson.git",
            from: "0.9.0"
        ),
        .package(
            url: "https://github.com/michaeleisel/JJLISO8601DateFormatter.git",
            from: "0.1.8"
        ),
    ],
    targets: [
        .target(
            name: "Ananda",
            dependencies: [
                .product(
                    name: "yyjson",
                    package: "yyjson"
                ),
                .product(
                    name: "JJLISO8601DateFormatter",
                    package: "JJLISO8601DateFormatter"
                ),
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
            ]
        ),
        .testTarget(
            name: "AnandaTests",
            dependencies: ["Ananda"]
        ),
    ]
)
