// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "GroqSwift",
    platforms: [
        .macOS(.v13),
        .macCatalyst(.v13),
        .iOS(.v16),
        .watchOS(.v9),
        .tvOS(.v16),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "GroqSwift",
            targets: ["GroqSwift"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "GroqSwift",
            dependencies: []),
        .testTarget(
            name: "GroqSwiftTests",
            dependencies: ["GroqSwift"]),
    ]
)
