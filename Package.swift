// swift-tools-version: 5.9

import PackageDescription
import CompilerPluginSupport

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
            from: "0.8.0"
        ),
        .package(
            url: "https://github.com/michaeleisel/JJLISO8601DateFormatter.git",
            from: "0.1.6"
        ),
        .package(
            url: "https://github.com/apple/swift-syntax.git",
            from: "509.0.0"
        ),
    ],
    targets: [
        .macro(
            name: "AnandaMacros",
            dependencies: [
                .product(
                    name: "SwiftSyntaxMacros",
                    package: "swift-syntax"
                ),
                .product(
                    name: "SwiftCompilerPlugin",
                    package: "swift-syntax"
                ),
            ]
        ),
        .target(
            name: "Ananda",
            dependencies: [
                "AnandaMacros",
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
            dependencies: [
                "Ananda",
                .product(
                    name: "SwiftSyntaxMacrosTestSupport",
                    package: "swift-syntax"
                ),
            ]
        ),
    ]
)
