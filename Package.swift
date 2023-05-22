// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "Kinzoku",
    platforms: [ .macOS(.v13) ], // I don't think we need to specify Linux
    products: [
        .library(
            name: "Kinzoku",
            targets: [ "Kinzoku" ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/thepotatoking55/SwiftGLFW.git", branch: "main")
    ],
    targets: [
        .target(
            name: "WgpuHeaders"
        ),
        .target(
            name: "Kinzoku",
            dependencies: [ "WgpuHeaders" ],
            resources: [
                .process("Libraries") // Eventually we should do individual if statements for platforms, so we don't import them all
            ]
        ),
        .testTarget(
            name: "KinzokuTests",
            dependencies: [ "Kinzoku", "SwiftGLFW" ],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
