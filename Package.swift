// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ViewInspector",
    products: [
        .library(
            name: "ViewInspector", targets: ["ViewInspector"]),
    ],
    targets: [
        .target(
            name: "ViewInspector", dependencies: []),
        .testTarget(
            name: "ViewInspectorTests", dependencies: ["ViewInspector"]),
    ]
)
