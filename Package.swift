import PackageDescription

#if os(OSX)
let package = Package(
    name: "RxSwift",
    exclude: [
        "Sources/RxCocoa",
        "Sources/RxTests",
        "Sources/AllTests"
    ],
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
#elseif os(Linux)
let package = Package(
    name: "RxSwift",
    exclude: [
        "Sources/RxCocoa",
    ],
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
#endif
