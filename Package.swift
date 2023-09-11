// swift-tools-version: 5.9
import PackageDescription

// MARK: Add detection for backend later, or make it modular with pluign and protocol

let package = Package(
    name: "kinzoku",
    products: [
        .library(
            name: "Kinzoku",
            targets: ["Kinzoku"]),
        .plugin(name: "NagaPlugin",
                targets: ["NagaPlugin"])
    ],
    targets: [
        .target(name: "Kinzoku"),
        .plugin(
            name: "NagaPlugin",
            capability: .buildTool,
            dependencies: [.target(name:"naga")]),
        .binaryTarget(name: "naga", path: "External/naga.artifactbundle")
    ]
)
