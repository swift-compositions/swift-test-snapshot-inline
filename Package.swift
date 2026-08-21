// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-test-snapshot-inline",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(name: "Test Snapshot Inline", targets: ["Test Snapshot Inline"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-primitives/swift-test.git",
            branch: "testing-stack/neutral-test-boundary"
        ),
        .package(
            url: "https://github.com/swift-foundations/swift-test-snapshot.git",
            branch: "testing-stack/test-snapshot"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-snapshot.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-source-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-foundations/swift-file-system.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swiftlang/swift-syntax.git",
            exact: "602.0.0"
        ),
    ],
    targets: [
        .target(
            name: "Test Snapshot Inline",
            dependencies: [
                .product(name: "Test", package: "swift-test"),
                .product(name: "Test Snapshot", package: "swift-test-snapshot"),
                .product(name: "Snapshot", package: "swift-snapshot"),
                .product(name: "Source Primitives", package: "swift-source-primitives"),
                .product(name: "File System", package: "swift-file-system"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
            ]
        ),
        .testTarget(
            name: "Test Snapshot Inline Tests",
            dependencies: [
                .target(name: "Test Snapshot Inline"),
                .product(name: "Test", package: "swift-test"),
                .product(name: "Test Snapshot", package: "swift-test-snapshot"),
                .product(name: "Snapshot", package: "swift-snapshot"),
                .product(name: "Source Primitives", package: "swift-source-primitives"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]
    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem
}
