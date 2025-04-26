// swift-tools-version:5.9

import Foundation
import PackageDescription

func targetsDarwin() -> Bool {
    if (ProcessInfo.processInfo.environment["TARGET_OS_ANDROID"] ?? "0") != "0" {
        // we are building for Android, and so Cocoa is not available
        return false
    }

    #if !canImport(Darwin)
    return false // Linux, Windows, etc.
    #else
    return true // macOS, iOS, etc.
    #endif
}

let buildTests = false

extension Product {
    static func allTests() -> [Product] {
        if buildTests {
            [.executable(name: "AllTestz", targets: ["AllTestz"])]
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
            resources: [.copy("PrivacyInfo.xcprivacy")],
        )
    }
}

extension Target {
    static func rxCocoa() -> [Target] {
        if !targetsDarwin() {
            [.rxTarget(name: "RxCocoa", dependencies: ["RxSwift", "RxRelay"])]
        } else {
            [.rxTarget(name: "RxCocoa", dependencies: ["RxSwift", "RxRelay", "RxCocoaRuntime"])]
        }
    }

    static func rxCocoaRuntime() -> [Target] {
        if !targetsDarwin() {
            []
        } else {
            [.rxTarget(name: "RxCocoaRuntime", dependencies: ["RxSwift"])]
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
    platforms: [.iOS(.v12), .macOS(.v10_13), .watchOS(.v4), .tvOS(.v12), .visionOS(.v1)],
    products: ([
        [
            .library(name: "RxSwift", targets: ["RxSwift"]),
            .library(name: "RxCocoa", targets: ["RxCocoa"]),
            .library(name: "RxRelay", targets: ["RxRelay"]),
            .library(name: "RxBlocking", targets: ["RxBlocking"]),
            .library(name: "RxTest", targets: ["RxTest"]),
            .library(name: "RxSwift-Dynamic", type: .dynamic, targets: ["RxSwift"]),
            .library(name: "RxCocoa-Dynamic", type: .dynamic, targets: ["RxCocoa"]),
            .library(name: "RxRelay-Dynamic", type: .dynamic, targets: ["RxRelay"]),
            .library(name: "RxBlocking-Dynamic", type: .dynamic, targets: ["RxBlocking"]),
            .library(name: "RxTest-Dynamic", type: .dynamic, targets: ["RxTest"]),
        ],
        Product.allTests(),
    ] as [[Product]]).flatMap(\.self),
    targets: ([
        [
            .rxTarget(name: "RxSwift", dependencies: []),
        ],
        Target.rxCocoa(),
        Target.rxCocoaRuntime(),
        [
            .rxTarget(name: "RxRelay", dependencies: ["RxSwift"]),
            .target(name: "RxBlocking", dependencies: ["RxSwift"]),
            .target(name: "RxTest", dependencies: ["RxSwift"]),
        ],
        Target.allTests(),
    ] as [[Target]]).flatMap(\.self),
    swiftLanguageVersions: [.v5],
)
