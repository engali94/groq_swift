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
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "GroqSwift",
            targets: ["GroqSwift"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "GroqSwift",
            dependencies: []
        ),
        .testTarget(
            name: "GroqSwiftTests",
            dependencies: ["GroqSwift"])
    ]
)
