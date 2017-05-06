Linux
=====

Use Swift Package Manager.

```
import PackageDescription

let package = Package(
    name: "RxTestProject",
    targets: [],
    dependencies: [
        .Package(url: "https://github.com/ReactiveX/RxSwift.git", majorVersion: 3)
    ]
)
```