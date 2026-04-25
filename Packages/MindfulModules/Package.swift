// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MindfulModules",
    platforms: [
        .iOS(.v18),
        .macOS(.v15)
    ],
    products: [
        .library(name: "CoreNetworking", targets: ["CoreNetworking"]),
        .library(name: "CoreStorage", targets: ["CoreStorage"]),
        .library(name: "CoreLogger", targets: ["CoreLogger"]),
        .library(name: "SharedDesignSystem", targets: ["SharedDesignSystem"]),
        .library(name: "SharedUIComponents", targets: ["SharedUIComponents"]),
        .library(name: "HomeFeature", targets: ["HomeFeature"]),
        .library(name: "SampleFeature", targets: ["SampleFeature"])
    ],
    targets: [
        .target(name: "CoreNetworking", path: "Core/Networking"),
        .target(name: "CoreStorage", path: "Core/Storage"),
        .target(name: "CoreLogger", path: "Core/Logger"),
        .target(name: "SharedDesignSystem", path: "Shared/DesignSystem"),
        .target(
            name: "SharedUIComponents",
            dependencies: ["SharedDesignSystem"],
            path: "Shared/UIComponents"
        ),
        .target(
            name: "HomeFeature",
            dependencies: ["SharedDesignSystem", "SharedUIComponents"],
            path: "Features/HomeFeature"
        ),
        .target(
            name: "SampleFeature",
            dependencies: [
                "CoreNetworking",
                "CoreLogger",
                "SharedDesignSystem",
                "SharedUIComponents"
            ],
            path: "Features/SampleFeature"
        ),
        .testTarget(
            name: "SampleFeatureTests",
            dependencies: ["SampleFeature"],
            path: "Tests/SampleFeatureTests"
        )
    ],
    swiftLanguageModes: [.v6]
)
