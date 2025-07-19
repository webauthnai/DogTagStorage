// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DogTagStorage",
    platforms: [
        .macOS(.v12),  // Support macOS 12+ with Core Data fallback
        .iOS(.v15)     // Future iOS support
    ],
    products: [
        .library(
            name: "DogTagStorage",
            targets: ["DogTagStorage"]),
    ],
    dependencies: [
        // No external dependencies - uses only Foundation, SwiftData, CoreData
    ],
    targets: [
        .target(
            name: "DogTagStorage",
            dependencies: [],
            swiftSettings: [
                // Enable Swift concurrency
                .enableUpcomingFeature("ConciseMagicFile"),
                .enableUpcomingFeature("ForwardTrailingClosures"),
                .enableUpcomingFeature("ExistentialAny")
            ]
        ),
        .testTarget(
            name: "DogTagStorageTests",
            dependencies: ["DogTagStorage"]
        ),
    ]
) 
