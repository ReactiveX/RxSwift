// swift-tools-version:5.1
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

private let TRACE_RESOURCES = SwiftSetting.define("TRACE_RESOURCES", .when(configuration: .debug))

extension Target {
  static func rxCocoa() -> [Target] {
    #if os(Linux)
      return [.target(name: "RxCocoa", dependencies: ["RxSwift", "RxRelay"], swiftSettings: [TRACE_RESOURCES])]
    #else
      return [.target(name: "RxCocoa", dependencies: ["RxSwift", "RxRelay", "RxCocoaRuntime"], swiftSettings: [TRACE_RESOURCES])]
    #endif
  }

  static func rxCocoaRuntime() -> [Target] {
    #if os(Linux)
      return []
    #else
      return [.target(name: "RxCocoaRuntime", dependencies: ["RxSwift"])]
    #endif
  }

  static func allTests() -> [Target] {
    if buildTests {
      return [.target(name: "AllTestz", dependencies: ["RxSwift", "RxCocoa", "RxBlocking", "RxTest"], swiftSettings: [TRACE_RESOURCES])]
    } else {
      return []
    }
  }
}

let package = Package(
  name: "RxSwift",
  platforms: [
    .macOS(.v10_10), .iOS(.v8), .tvOS(.v9), .watchOS(.v3)
  ],
  products: ([
    [
      .library(name: "RxSwift", targets: ["RxSwift"]),
      .library(name: "RxCocoa", targets: ["RxCocoa"]),
      .library(name: "RxRelay", targets: ["RxRelay"]),
      .library(name: "RxBlocking", targets: ["RxBlocking"]),
      .library(name: "RxTest", targets: ["RxTest"]),
    ],
    Product.allTests()
  ] as [[Product]]).flatMap { $0 },
  targets: ([
    [
      .target(name: "RxSwift", dependencies: [], swiftSettings: [TRACE_RESOURCES]),
    ],
    Target.rxCocoa(),
    Target.rxCocoaRuntime(),
    [
      .target(name: "RxRelay", dependencies: ["RxSwift"], swiftSettings: [TRACE_RESOURCES]),
      .target(name: "RxBlocking", dependencies: ["RxSwift"], swiftSettings: [TRACE_RESOURCES]),
      .target(name: "RxTest", dependencies: ["RxSwift"], swiftSettings: [TRACE_RESOURCES]),
    ],
    Target.allTests()
  ] as [[Target]]).flatMap { $0 },
  swiftLanguageVersions: [.v5]
)
