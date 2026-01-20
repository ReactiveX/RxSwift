// swift-tools-version:5.5

import PackageDescription

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
        #if os(Linux)
        return [.rxTarget(name: "RxCocoa", dependencies: ["RxSwift", "RxRelay"])]
        #else
        return [.rxTarget(name: "RxCocoa", dependencies: ["RxSwift", "RxRelay", "RxCocoaRuntime"])]
        #endif
    }

    static func rxCocoaRuntime() -> [Target] {
        #if os(Linux)
        return []
        #else
        return [.rxTarget(name: "RxCocoaRuntime", dependencies: ["RxSwift"])]
        #endif
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
