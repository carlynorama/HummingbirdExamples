// swift-tools-version:6.1
import PackageDescription

let package = Package(
    name: "simple-respond",
    platforms : [.macOS(.v14)],
    products: [.executable(name: "simple-respond", targets: ["simple-respond"])],
    dependencies: [
        .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0")
    ],
    targets: [
        .executableTarget(
            name: "simple-respond",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Hummingbird", package: "hummingbird"),
            ]
        ),
    ]
)
