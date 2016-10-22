import PackageDescription

let buildTests = false
#if os(Linux)
let supportsTests = true
#else
let supportsTests = false
#endif

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
        ),
    ]
 
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
    ] : []) + (supportsTests ?  [Target(
            name: "RxTest",
            dependencies: [
                .Target(name: "RxSwift")
            ]
        )
    ] : [])

let testExcludes: [String] = (!buildTests ? ["Sources/AllTestz"] : []) + (!supportsTests ? ["Sources/RxTest"] : [])

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
