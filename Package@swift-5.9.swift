// swift-tools-version:5.9

import PackageDescription

let buildTests = false

extension Product {
  static func allTests() -> [Product] {
    if buildTests {
      return [.executable(name: "AllTestz", targets: ["AllTestz"])]
    } else {
      return []
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
      return [.target(name: "AllTestz", dependencies: ["RxSwift", "RxCocoa", "RxBlocking", "RxTest"])]
    } else {
      return []
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
    Product.allTests()
  ] as [[Product]]).flatMap { $0 },
  dependencies: [
    // NOTE: Currently used for WASI targets only.
    // Avoid using this dependency for any other targets.
    .package(
        url: "https://github.com/apple/swift-atomics.git",
        from: "1.2.0"
    ),
    .package(url: "https://github.com/PassiveLogic/swift-dispatch-async.git", from: "1.0.0")
  ],
  targets: ([
    [
      .rxTarget(
        name: "RxSwift",
        dependencies: [
            // WASI targets can't use CoreFoundation, but WASI does support
            // compiling Swift Atomics.
            //
            // This dependency is added ONLY for WASI targets, and should NOT
            // be added for any other platforms.
            .product(
                name: "Atomics",
                package: "swift-atomics",
                condition: .when(platforms: [.wasi])
            ),

            .product(
                name: "DispatchAsync",
                package: "swift-dispatch-async",
                condition: .when(platforms: [.wasi])
            ),
        ]
      ),
    ],
    Target.rxCocoa(),
    Target.rxCocoaRuntime(),
    [
      .rxTarget(name: "RxRelay", dependencies: ["RxSwift"]),
      .target(name: "RxBlocking", dependencies: ["RxSwift"]),
      .target(name: "RxTest", dependencies: ["RxSwift"]),
    ],
    Target.allTests()
  ] as [[Target]]).flatMap { $0 },
  swiftLanguageVersions: [.v5]
)
