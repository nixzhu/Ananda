// swift-tools-version: 5.7

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
        .package(url: "https://github.com/ibireme/yyjson.git", from: "0.6.0"),
    ],
    targets: [
        .target(
            name: "Ananda",
            dependencies: [
                .product(name: "yyjson", package: "yyjson"),
            ]
        ),
        .testTarget(
            name: "AnandaTests",
            dependencies: ["Ananda"]
        ),
    ]
)
