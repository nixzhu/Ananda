// swift-tools-version: 6.0

import PackageDescription

#if os(Linux)
let packageDependencies: [Package.Dependency] = [
    .package(
        url: "https://github.com/ibireme/yyjson.git",
        from: "0.12.0"
    ),
]
#else
let packageDependencies: [Package.Dependency] = [
    .package(
        url: "https://github.com/ibireme/yyjson.git",
        from: "0.12.0"
    ),
    .package(
        url: "https://github.com/michaeleisel/JJLISO8601DateFormatter.git",
        from: "0.1.8"
    ),
]
#endif

#if os(Linux)
let targetDependencies: [Target.Dependency] = [
    .product(
        name: "yyjson",
        package: "yyjson"
    ),
]
#else
let targetDependencies: [Target.Dependency] = [
    .product(
        name: "yyjson",
        package: "yyjson"
    ),
    .product(
        name: "JJLISO8601DateFormatter",
        package: "JJLISO8601DateFormatter"
    ),
]
#endif

let package = Package(
    name: "Ananda",
    products: [
        .library(
            name: "Ananda",
            targets: ["Ananda"]
        ),
    ],
    dependencies: packageDependencies,
    targets: [
        .target(
            name: "Ananda",
            dependencies: targetDependencies
        ),
        .testTarget(
            name: "AnandaTests",
            dependencies: ["Ananda"]
        ),
    ]
)
