import PackageDescription

#if os(OSX)
let package = Package(
    name: "RxSwift",
    targets: [
        Target(
            name: "RxSwift"
        ),
        Target(
            name: "RxCocoa",
            dependencies: [
                .Target(name: "RxSwift")
            ]
        ),
        Target(
            name: "RxTests",
            dependencies: [
                .Target(name: "RxSwift")
            ]
        ),
        Target(
            name: "RxBlocking",
            dependencies: [
                .Target(name: "RxSwift")
            ]
        ),
        Target(
            name: "AllTests",
            dependencies: [
                .Target(name: "RxSwift"),
                .Target(name: "RxBlocking"),
                .Target(name: "RxTests")
            ]
        )
    ]
)
#elseif os(Linux)
let package = Package(
    name: "RxSwift",
    targets: [
        Target(
            name: "RxSwift"
        ),
        Target(
            name: "RxTests",
            dependencies: [
                .Target(name: "RxSwift")
            ]
        ),
        Target(
            name: "RxBlocking",
            dependencies: [
                .Target(name: "RxSwift")
            ]
        ),
        Target(
            name: "AllTests",
            dependencies: [
                .Target(name: "RxSwift"),
                .Target(name: "RxBlocking"),
                .Target(name: "RxTests")
            ]
        )
    ]
)
#else
#endif
