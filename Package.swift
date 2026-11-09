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
            name: "YoruUI",
            targets: ["YoruUI"]
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
        .target(
            name: "YoruComponents",
            dependencies: ["YoruCore", "YoruTelegram"],
            path: "Yoru/Components"
        ),
        .target(
            name: "YoruUI",
            dependencies: ["YoruCore", "YoruTelegram", "YoruComponents"],
            path: "Yoru/Features"
        ),
        .testTarget(
            name: "YoruTests",
            dependencies: ["YoruCore", "YoruTelegram", "YoruComponents"],
            path: "Tests"
        )
    ]
)
