// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "swift_addon",
    platforms: [.macOS(.v11)],
    products: [
        .library(
            name: "SwiftCode",
            type: .static,
            targets: ["SwiftCode"]
        )
    ],
    dependencies: [
        .package(path: "src/couchdb-swift-2.3.2")
    ],
    targets: [
        .target(
            name: "SwiftCode",
            dependencies: [
                .product(name: "CouchDBClient", package: "couchdb-swift-2.3.2")
            ],
            path: "src",
            sources: ["SwiftCode.swift"]
        )
    ]
)

