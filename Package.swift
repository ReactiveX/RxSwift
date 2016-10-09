import PackageDescription

#if !os(Linux)
let package = Package(
    name: "RxSwift",
    targets: [
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
            name: "RxCocoaRuntime",
            dependencies: [
                .Target(name: "RxSwift")
            ]
        ),
        Target(
            name: "RxCocoa",
            dependencies: [
                .Target(name: "RxSwift"),
                .Target(name: "RxCocoaRuntime")
            ]
        ),
        Target(
            name: "RxTest",
            dependencies: [
                .Target(name: "RxSwift")
            ]
        ),
        Target(
            name: "AllTestz",
            dependencies: [
                .Target(name: "RxSwift"),
                .Target(name: "RxBlocking"),
                .Target(name: "RxTest"),
                .Target(name: "RxCocoa")
            ]
        )
    ],
    exclude: [
        "Tests"
    ]
)
#else 
let package = Package(
    name: "RxSwift",
    targets: [
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
            dependencies: [
                .Target(name: "RxSwift")
            ]
        ),
        Target(
            name: "RxTest",
            dependencies: [
                .Target(name: "RxSwift")
            ]
        ),
        Target(
            name: "AllTestz",
            dependencies: [
                .Target(name: "RxSwift"),
                .Target(name: "RxBlocking"),
                .Target(name: "RxTest"),
                .Target(name: "RxCocoa")
            ]
        )
    ],
    exclude: [
        "Tests",
        "Sources/RxCocoaRuntime"
    ]
)
#endif
