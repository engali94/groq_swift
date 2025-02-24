// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "GroqChatDemo",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    dependencies: [
        .package(path: "../..")
    ],
    targets: [
        .executableTarget(
            name: "GroqChatDemo",
            dependencies: [
                .product(name: "GroqSwift", package: "groq_swift")
            ],
            path: "."
        )
    ]
)
