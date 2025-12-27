// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "PhotoCleaner",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "PhotoCleaner",
            targets: ["PhotoCleaner"]),
    ],
    dependencies: [
        // Add external dependencies here if needed
    ],
    targets: [
        .target(
            name: "PhotoCleaner",
            dependencies: []),
        .testTarget(
            name: "PhotoCleanerTests",
            dependencies: ["PhotoCleaner"]),
    ]
)

