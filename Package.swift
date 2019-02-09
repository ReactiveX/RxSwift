// swift-tools-version:4.0

import PackageDescription

let buildTests = true

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
  static func rxCocoa() -> [Target] {
    #if os(Linux)
      return [.target(name: "RxCocoa", dependencies: ["RxSwift"])]
    #else
      return [.target(name: "RxCocoa", dependencies: ["RxSwift", "RxCocoaRuntime"])]
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
      return [.target(name: "AllTestz", dependencies: ["RxSwift", "RxCocoa", "RxBlocking", "RxTest"])]
    } else {
      return []
    }
  }
}

let package = Package(
  name: "RxSwift",
  products: ([
    [
      .library(name: "RxAtomic", targets: ["RxAtomic"]),
      .library(name: "RxSwift", targets: ["RxSwift"]),
      .library(name: "RxCocoa", targets: ["RxCocoa"]),
      .library(name: "RxBlocking", targets: ["RxBlocking"]),
      .library(name: "RxTest", targets: ["RxTest"]),
    ],
    Product.allTests()
  ] as [[Product]]).flatMap { $0 },
  targets: ([
    [
      .target(name: "RxAtomic", dependencies: []),
      .target(name: "RxSwift", dependencies: ["RxAtomic"]),
    ], 
    Target.rxCocoa(),
    Target.rxCocoaRuntime(),
    [
      .target(name: "RxBlocking", dependencies: ["RxSwift", "RxAtomic"]),
      .target(name: "RxTest", dependencies: ["RxSwift"]),
    ],
    Target.allTests()
  ] as [[Target]]).flatMap { $0 }
)
