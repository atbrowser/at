// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "atSwiftAddon",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(name: "SwiftCode", type: .static, targets: ["SwiftCode"])
    ],
    dependencies: [
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.15.4")
    ],
    targets: [
        .target(
            name: "SwiftCode",
            dependencies: [
                .product(name: "SQLite", package: "SQLite.swift")
            ],
            path: "Sources/SwiftCode"
        )
    ]
)