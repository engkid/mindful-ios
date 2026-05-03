// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MindfulModules",
    platforms: [
        .iOS(.v18),
        .macOS(.v15)
    ],
    products: [
        .library(name: "CoreFirebase", targets: ["CoreFirebase"]),
        .library(name: "CoreNetworking", targets: ["CoreNetworking"]),
        .library(name: "CoreStorage", targets: ["CoreStorage"]),
        .library(name: "CoreLogger", targets: ["CoreLogger"]),
        .library(name: "SharedDesignSystem", targets: ["SharedDesignSystem"]),
        .library(name: "SharedUIComponents", targets: ["SharedUIComponents"]),
        .library(name: "HomeFeature", targets: ["HomeFeature"]),
        .library(name: "SampleFeature", targets: ["SampleFeature"]),
        .library(name: "ReflectionFeature", targets: ["ReflectionFeature"])
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "12.5.0")
    ],
    targets: [
        .target(
            name: "CoreFirebase",
            dependencies: [
                .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseRemoteConfig", package: "firebase-ios-sdk")
            ],
            path: "Core/Firebase"
        ),
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
        .target(
            name: "ReflectionFeature",
            dependencies: [
                "CoreFirebase",
                "CoreStorage",
                .product(name: "FirebaseAILogic", package: "firebase-ios-sdk"),
                "SharedDesignSystem",
                "SharedUIComponents"
            ],
            path: "Features/ReflectionFeature"
        ),
        .testTarget(
            name: "SampleFeatureTests",
            dependencies: ["SampleFeature"],
            path: "Tests/SampleFeatureTests"
        ),
        .testTarget(
            name: "HomeFeatureTests",
            dependencies: ["HomeFeature"],
            path: "Tests/HomeFeatureTests"
        ),
        .testTarget(
            name: "ReflectionFeatureTests",
            dependencies: ["ReflectionFeature", "CoreFirebase", "CoreStorage"],
            path: "Tests/ReflectionFeatureTests"
        )
    ],
    swiftLanguageModes: [.v6]
)
