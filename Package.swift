// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "VectorPusoyDos",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "VectorPusoyDos",
            targets: ["VectorPusoyDos"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/supabase/supabase-swift", from: "2.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.0.0"),
        .package(url: "https://github.com/realm/SwiftLint", from: "0.50.0")
    ],
    targets: [
        .target(
            name: "VectorPusoyDos",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .testTarget(
            name: "VectorPusoyDosTests",
            dependencies: ["VectorPusoyDos"]
        ),
    ]
)
