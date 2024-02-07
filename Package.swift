// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WZAsyncDrawingKit",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "WZAsyncDrawingKit", targets: ["WZAsyncDrawingKit"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "WZAsyncDrawingKit", dependencies: ["WZAsyncCore"], path: "Sources/Exports"),
        .target(name: "WZAsyncCore", dependencies: [], path: "Sources/Core"),
        .target(name: "WZAsyncDrawingKitTests", dependencies: ["WZAsyncDrawingKit"], path: "Tests"),
    ],
    swiftLanguageVersions: [
        .v5,
    ]
)
