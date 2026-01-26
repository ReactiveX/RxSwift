// swift-tools-version:5.5

import Foundation
import PackageDescription

func isTargetingDarwin() -> Bool {
    // Check if building for Android or other non-Darwin platforms
    if (ProcessInfo.processInfo.environment["ANDROID_DATA"] != nil) ||
        (ProcessInfo.processInfo.environment["ANDROID_ROOT"] != nil)
    {
        return false
    }

    #if canImport(Darwin)
    return true
    #else
    return false
    #endif
}

let buildTests = false
let targetsDarwin = isTargetingDarwin()

extension Product {
    static func allTests() -> [Product] {
        if buildTests {
            [.executable(name: "AllTestz", targets: ["AllTestz"])]
        } else {
            []
        }
    }

    static func rxCocoaProducts() -> [Product] {
        if targetsDarwin {
            [
                .library(name: "RxCocoa", targets: ["RxCocoa"]),
                .library(name: "RxCocoa-Dynamic", type: .dynamic, targets: ["RxCocoa"])
            ]
        } else {
            []
        }
    }
}

extension Target {
    static func rxTarget(name: String, dependencies: [Target.Dependency]) -> Target {
        .target(
            name: name,
            dependencies: dependencies,
            resources: [.copy("PrivacyInfo.xcprivacy")]
        )
    }
}

extension Target {
    static func rxCocoa() -> [Target] {
        if !targetsDarwin {
            []
        } else {
            [
                .target(
                    name: "RxCocoa",
                    dependencies: [
                        "RxSwift",
                        "RxRelay",
                        .target(name: "RxCocoaRuntime", condition: .when(platforms: [.iOS, .macOS, .tvOS, .watchOS]))
                    ],
                    resources: [.copy("PrivacyInfo.xcprivacy")]
                )
            ]
        }
    }

    static func rxCocoaRuntime() -> [Target] {
        if !targetsDarwin {
            []
        } else {
            [
                .target(
                    name: "RxCocoaRuntime",
                    dependencies: ["RxSwift"],
                    resources: [.copy("PrivacyInfo.xcprivacy")]
                )
            ]
        }
    }

    static func allTests() -> [Target] {
        if buildTests {
            [.target(name: "AllTestz", dependencies: ["RxSwift", "RxCocoa", "RxBlocking", "RxTest"])]
        } else {
            []
        }
    }
}

let package = Package(
    name: "RxSwift",
    platforms: [.iOS(.v9), .macOS(.v10_10), .watchOS(.v3), .tvOS(.v9)],
    products: ([
        [
            .library(name: "RxSwift", targets: ["RxSwift"]),
            .library(name: "RxRelay", targets: ["RxRelay"]),
            .library(name: "RxBlocking", targets: ["RxBlocking"]),
            .library(name: "RxTest", targets: ["RxTest"]),
            .library(name: "RxSwift-Dynamic", type: .dynamic, targets: ["RxSwift"]),
            .library(name: "RxRelay-Dynamic", type: .dynamic, targets: ["RxRelay"]),
            .library(name: "RxBlocking-Dynamic", type: .dynamic, targets: ["RxBlocking"]),
            .library(name: "RxTest-Dynamic", type: .dynamic, targets: ["RxTest"])
        ],
        Product.rxCocoaProducts(),
        Product.allTests()
    ] as [[Product]]).flatMap(\.self),
    targets: ([
        [
            .rxTarget(name: "RxSwift", dependencies: [])
        ],
        Target.rxCocoa(),
        Target.rxCocoaRuntime(),
        [
            .rxTarget(name: "RxRelay", dependencies: ["RxSwift"]),
            .target(name: "RxBlocking", dependencies: ["RxSwift"]),
            .target(name: "RxTest", dependencies: ["RxSwift"])
        ],
        Target.allTests()
    ] as [[Target]]).flatMap(\.self),
    swiftLanguageVersions: [.v5]
)
