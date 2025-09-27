// swift-tools-version:6.2
import PackageDescription

let package = Package(
    name: "customContext",
    platforms : [.macOS(.v14)],
    products: [.executable(name: "customContext", targets: ["customContext"])],
    dependencies: [
        .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0"),
        .package(url: "https://github.com/hummingbird-project/swift-mustache", from: "2.0.0")
    ],
    targets: [
        .executableTarget(
            name: "customContext",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Hummingbird", package: "hummingbird"),
                .product(name: "Mustache", package: "swift-mustache"),
                .product(name: "HummingbirdRouter", package: "hummingbird"),
            ],
            resources: [.process("Templates")]

        ),
        .testTarget(name: "addTestingTests",
            dependencies: [
                .byName(name: "customContext"),
                .product(name: "HummingbirdTesting", package: "hummingbird")
            ],
            path: "Tests/AppTests"
        )
    ]
)
