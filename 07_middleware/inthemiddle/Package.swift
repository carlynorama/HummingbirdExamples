// swift-tools-version:6.2
import PackageDescription

let package = Package(
    name: "inthemiddle",
    platforms : [.macOS(.v14)],
    products: [.executable(name: "inthemiddle", targets: ["inthemiddle"])],
    dependencies: [
        .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0"),
        .package(url: "https://github.com/hummingbird-project/swift-mustache", from: "2.0.0")
    ],
    targets: [
        .executableTarget(
            name: "inthemiddle",
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
                .byName(name: "inthemiddle"),
                .product(name: "HummingbirdTesting", package: "hummingbird")
            ],
            path: "Tests/AppTests"
        )
    ]
)
