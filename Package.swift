// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ViewInspector",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v10_15), .iOS(.v12), .tvOS(.v13), .watchOS(.v7), .visionOS(.v1)
    ],
    products: [
        .library(
            name: "ViewInspector", targets: ["ViewInspector"]),
    ],
    targets: [
        .target(
            name: "ViewInspector", dependencies: []),
        .testTarget(
            name: "ViewInspectorTests",
            dependencies: ["ViewInspector"],
            resources: [.process("TestResources")]),
    ]
)
