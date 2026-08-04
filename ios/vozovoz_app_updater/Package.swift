// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "vozovoz_app_updater",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "vozovoz-app-updater", targets: ["vozovoz_app_updater"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "vozovoz_app_updater",
            dependencies: [],
            resources: [
                .process("Resources/PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
