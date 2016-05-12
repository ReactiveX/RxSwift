Linux
=====

We've made a proof of concept for Linux.

To test it, create `Package.swift` in your test directory with the following content:

```
import PackageDescription

let package = Package(
    name: "MyShinyUnicornCat",
    dependencies: [
        .Package(url: "https://github.com/ReactiveX/RxSwift.git", Version(2, 0, 0))
    ]
)
```

What works:
* Distribution using Swift Package Manager
* Single Threaded mode (CurrentThreadScheduler)
* Half of the unit tests are passing.
* Projects that can be compiled and "used":
    * RxSwift
    * RxBlocking
    * RxTests

What doesn't work:
* Schedulers - because they are dependent on https://github.com/apple/swift-corelibs-libdispatch and it still hasn't been released
* Multithreading - still no access to c11 locks
* For some reason it looks like Swift compiler generates wrong code when using `ErrorType` on `Linux`, so don't use errors, otherwise you can get weird crashes.
