// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "Yoru",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "YoruCore",
            targets: ["YoruCore"]
        ),
        .library(
            name: "YoruTelegram",
            targets: ["YoruTelegram"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "YoruCore",
            path: "Yoru/Core"
        ),
        .target(
            name: "YoruTelegram",
            dependencies: ["YoruCore"],
            path: "Yoru/Telegram"
        ),
        .testTarget(
            name: "YoruTests",
            dependencies: ["YoruCore", "YoruTelegram"],
            path: "Tests"
        )
    ]
)
