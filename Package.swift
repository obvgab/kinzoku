// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "Kinzoku",
    products: [
        .library(
            name: "Kinzoku",
            targets: ["Kinzoku"]),
    ],
    dependencies: [],
    targets: [
        .systemLibrary(
            name: "Wgpu"
        ),
        .target(
            name: "Kinzoku",
            dependencies: ["Wgpu"],
            linkerSettings: [
                .unsafeFlags([
                    "-L\(Context.packageDirectory)/Sources/Wgpu/macos/arm64"
                ])
            ]
        ),
        .testTarget(
            name: "KinzokuTests",
            dependencies: ["Kinzoku"],
            resources: [
                .copy("Resources/compute.wgsl")
            ]
        )
    ]
)
