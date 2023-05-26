// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "Ananda",
    products: [
        .library(
            name: "Ananda",
            targets: ["Ananda"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/ibireme/yyjson.git",
            from: "0.7.0"
        ),
        .package(
            url: "https://github.com/michaeleisel/JJLISO8601DateFormatter.git",
            from: "0.1.6"
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
            ]
        ),
        .testTarget(
            name: "AnandaTests",
            dependencies: ["Ananda"]
        ),
    ]
)
