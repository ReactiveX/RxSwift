import PackageDescription

let buildTests = false
#if os(Linux)
let supportsTests = true
#else
let supportsTests = false
#endif

private struct Paths {
    static let testExcludes: [String] = (!buildTests ? ["Sources/AllTestz"] : []) + (!supportsTests ? ["Sources/RxTest"] : [])
    #if os(Linux)
    static let excludes: [String] = ["Tests", "Sources/RxCocoaRuntime"] + Paths.testExcludes
    #else
    static let excludes: [String] = ["Tests"] + Paths.testExcludes
    #endif
}

private struct TargetDependencies {
    static private let rxSwiftTarget: Target.Dependency = .Target(name: "RxSwift")
    static private let rxBlockingTarget: Target.Dependency = .Target(name: "RxBlocking")
    static private let rxCocoaRuntimeTarget: Target.Dependency = .Target(name: "RxCocoaRuntime")
    static private let rxCocoaTarget:Target.Dependency = .Target(name: "RxCocoa")
    static private let rxTestTarget: Target.Dependency = .Target(name: "RxTest")
    
    static let rxSwift: [Target.Dependency] = [rxSwiftTarget]
    static let rxAllTestz: [Target.Dependency] = [rxSwiftTarget, rxBlockingTarget, rxTestTarget, rxCocoaTarget]
    
    #if os(Linux)
    static let rxCocoaDependencies: [Target.Dependency] = rxSwift
    #else
    static let rxCocoaDependencies: [Target.Dependency] = rxSwift + [rxCocoaRuntimeTarget]
    #endif
}

private struct Targets {
    private static let rxSwift = Target(name: "RxSwift")
    private static let rxBlocking = Target(name: "RxBlocking", dependencies: TargetDependencies.rxSwift)
    private static let rxCocoaRuntime = Target(name: "RxCocoaRuntime", dependencies: TargetDependencies.rxSwift)
    private static let rxCocoa = Target(name: "RxCocoa", dependencies: TargetDependencies.rxCocoaDependencies)
    private static let rxTest = Target(name: "RxTest", dependencies: TargetDependencies.rxSwift)
    private static let rxAllTestz = Target(name: "AllTestz", dependencies: TargetDependencies.rxSwift)
    private static let rxTests: [Target] = (buildTests ? [rxAllTestz] : []) + (supportsTests ?  [rxTest] : [])
    private static let library = [Targets.rxSwift, Targets.rxBlocking, Targets.rxCocoa]
    static let rxSwiftComplete = Targets.library + [Targets.rxCocoaRuntime] + Targets.rxTests
}

let package = Package(name: "RxSwift",
                      targets: Targets.rxSwiftComplete,
                      exclude: Paths.excludes)
