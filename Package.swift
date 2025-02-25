// swift-tools-version: 5.9
import PackageDescription

#if os(Linux)
let swiftLintPlugin: [Target.PluginUsage] = []
#else
let swiftLintPlugin: [Target.PluginUsage] = [
    .plugin(name: "SwiftLint", package: "SwiftLintPlugin")
]
#endif

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
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        .package(url: "https://github.com/lukepistrol/SwiftLintPlugin", from: "0.2.2")
    ],
    targets: [
        .target(
            name: "GroqSwift",
            dependencies: [],
            plugins: swiftLintPlugin
        ),
        .testTarget(
            name: "GroqSwiftTests",
            dependencies: ["GroqSwift"])
    ]
)
