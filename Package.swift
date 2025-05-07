// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "TDAssistant",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "TDAssistant",
            targets: ["TDAssistant"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/robbiehanson/XMPPFramework.git", from: "4.0.0"),
        .package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.18.10"),
        .package(url: "https://github.com/yahoojapan/SwiftyXMLParser.git", from: "5.6.0"),
        .package(url: "https://github.com/hackiftekhar/IQKeyboardManager.git", from: "7.0.0"),
        .package(url: "https://github.com/relatedcode/ProgressHUD.git", from: "14.1.0")
    ],
    targets: [
        .target(
            name: "TDAssistant",
            dependencies: [
                .product(name: "XMPPFramework", package: "XMPPFramework"),
                .product(name: "SDWebImage", package: "SDWebImage"),
                .product(name: "SwiftyXMLParser", package: "SwiftyXMLParser"),
                .product(name: "IQKeyboardManagerSwift", package: "IQKeyboardManager"),
                .product(name: "ProgressHUD", package: "ProgressHUD")
            ],
            path: "Sources/TDAssistant",
            sources: ["Classes", "Manager", "Models", "Utilities"],
            resources: [
                .process("Resources")
            ],
            linkerSettings: [
                .linkedFramework("UIKit")
            ]
        )
    ]
)
