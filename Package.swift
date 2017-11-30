// swift-tools-version:4.0

import PackageDescription

let buildTests = true

func filterNil<T>(_ array: [T?]) -> [T] {
  return array.flatMap { $0 }
}

extension Product {
  static func allTests() -> Product? {
    if buildTests {
      return .executable(name: "AllTestz", targets: ["AllTestz"])
    } else {
      return nil
    }
  }
}

extension Target {
  static func rxCocoa() -> Target? {
    #if os(Linux)
      return .target(name: "RxCocoa", dependencies: ["RxSwift"])
    #else
      return .target(name: "RxCocoa", dependencies: ["RxSwift", "RxCocoaRuntime"])
    #endif
  }

  static func rxCocoaRuntime() -> Target? {
    #if os(Linux)
      return nil
    #else
      return .target(name: "RxCocoaRuntime", dependencies: ["RxSwift"])
    #endif
  }

  static func allTests() -> Target? {
    if buildTests {
      return .target(name: "AllTestz", dependencies: ["RxSwift", "RxCocoa", "RxBlocking", "RxTest"])
    } else {
      return nil
    }
  }
}

let package = Package(
  name: "RxSwift",
  products: filterNil([
    .library(name: "RxSwift", targets: ["RxSwift"]),
    .library(name: "RxCocoa", targets: ["RxCocoa"]),
    .library(name: "RxBlocking", targets: ["RxBlocking"]),
    .library(name: "RxTest", targets: ["RxTest"]),
    .allTests(),
  ]),
  targets: filterNil([
    .target(name: "RxSwift", dependencies: []),
    .rxCocoa(),
    .rxCocoaRuntime(),
    .target(name: "RxBlocking", dependencies: ["RxSwift"]),
    .target(name: "RxTest", dependencies: ["RxSwift"]),
    .allTests(),
  ])
)
