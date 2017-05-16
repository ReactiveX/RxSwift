import PackageDescription
import Foundation

let buildTests = false
let RxTestIsTarget = buildTests || ProcessInfo.processInfo.environment["TEST"] == "1"

#if os(Linux)
let rxCocoaDependencies: [Target.Dependency] = [
        .Target(name: "RxSwift"),
    ]
#else
let rxCocoaDependencies: [Target.Dependency] = [
        .Target(name: "RxSwift"),
        .Target(name: "RxCocoaRuntime"),
    ]
#endif

let library = [
        Target(
            name: "RxSwift"
        ),
        Target(
            name: "RxBlocking",
            dependencies: [
                .Target(name: "RxSwift")
            ]
        ),
        Target(
            name: "RxCocoa",
            dependencies: rxCocoaDependencies
        )
] + (RxTestIsTarget ? [
        Target(
            name: "RxTest",
            dependencies: [
                .Target(name: "RxSwift")
            ]
        ),
] : [])
 
#if os(Linux) 
    let cocoaRuntime: [Target] = []   
#else
    let cocoaRuntime: [Target] = [
         Target(
            name: "RxCocoaRuntime",
            dependencies: [
                .Target(name: "RxSwift")
            ]
        )
    ]
#endif

let tests: [Target] = (buildTests ? [
        Target(
            name: "AllTestz",
            dependencies: [
	        .Target(name: "RxSwift"),
	        .Target(name: "RxBlocking"),
	        .Target(name: "RxTest"),
	        .Target(name: "RxCocoa")
            ]
        )
    ] : [])

let testExcludes: [String] = (buildTests ? [] : ["Sources/AllTestz"]) + (RxTestIsTarget ? [] : ["Sources/RxTest"])

#if os(Linux)

    let excludes: [String] = [
        "Tests",
        "Sources/RxCocoaRuntime",
    ] + testExcludes
#else
    let excludes: [String] = [
        "Tests",
    ] + testExcludes
#endif

let package = Package(
    name: "RxSwift",
    targets: library + cocoaRuntime + tests,
    exclude: excludes
)
