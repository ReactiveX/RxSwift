import PackageDescription

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
#if os(OSX)
    package.exclude = ["Sources/RxCocoa", "Sources/RxTests", "Sources/AllTests"]
#elseif os(Linux)
    package.exclude = ["Sources/RxCocoa"]
#else
#endif
