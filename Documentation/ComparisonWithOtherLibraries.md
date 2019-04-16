## Comparison with ReactiveSwift

RxSwift is somewhat similar to ReactiveSwift since ReactiveSwift borrows a large number of concepts from Rx.

One of the main goals of this project was to create a significantly simpler interface that is more aligned with other Rx implementations, offers a richer concurrency model, offers more optimization opportunities and is more aligned with built-in Swift error handling mechanisms.

We've also decided to only rely on the Swift/llvm compiler and not introduce any external dependencies.

Probably the main difference between these projects is in their approach in building abstractions.

The main goal of RxSwift project is to provide environment-agnostic compositional computation glue abstracted in the form of observable sequences.

We then aim to improve the experience of using RxSwift on specific platforms. To do this, RxCocoa uses generic computations to build more practical abstractions and wrap Foundation/Cocoa/UKit frameworks. That means that other libraries give context and semantics to the generic computation engine RxSwift provides such as `Driver`, `Signal`, `ControlProperty`, `ControlEvent`s and more.

One of the benefits to representing all of these abstractions as a single concept - ​_observable sequences_​ - is that all computation abstractions built on top of them are also composable in the same fundamental way. They all follow the same contract and implement the same interface.
 It is also easy to create flexible subscription (resource) sharing strategies or use one of the built-in ones: `share`, `publish`, `multicast` ...

This library also offers a fine-tunable concurrency model. If concurrent schedulers are used, observable sequence operators will preserve sequence properties. The same observable sequence operators will also know how to detect and optimally use known serial schedulers. ReactiveSwift has a more limited concurrency model and only allows serial schedulers.

Multithreaded programming is really hard and detecting non-trivial loops is even harder. That's why all operators are built in a fault tolerant way. Even if element generation occurs during element processing (recursion), operators will try to handle that situation and prevent deadlocks. This means that in the worst possible case programming error will cause stack overflow, but users won't have to manually kill the app, and you will get a crash report in error reporting systems so you can find and fix the problem.
