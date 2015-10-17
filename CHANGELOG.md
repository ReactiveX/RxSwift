# Change Log
All notable changes to this project will be documented in this file.

---

## [2.0.0-alpha.4](https://github.com/ReactiveX/RxSwift/releases/tag/2.0.0-alpha.4)

#### Updated

* Adds `tvOS` support
* Adds `watchOS` support
* Adds auto loading example to example app
* Restores old `Variable` behavior. Variable doesn't send anything on dealloc.
* Adds performance tests target.
* Adds more detailed resource tracing during unit tests (important for further optimizations).
* Adds `UIStepper` extensions.
* Adds `UIBarButtonItem` enabled property wrapper.
* Adds response data to userInfo of error for `rx_response` extensions of `NSURLSession`.
* Adds `onNext`, `onError` and `onCompleted` convenience methods to `ObserverType`.

#### Fixed

* Fixes problem on some systems with unregistering `CurrentThreadScheduler` from current thread.
* Fixes retry parameter naming (`maxAttemptCount`).
* Fixes a lot of unit test warnings.
* Removes embedding of Swift library with built frameworks.

## [2.0.0-alpha.3](https://github.com/ReactiveX/RxSwift/releases/tag/2.0.0-alpha.3)

#### Updated

* Renames `ImmediateScheduler` protocol to `ImmediateSchedulerType`
* Renames `Scheduler` protocol to `SchedulerType`
* Adds `CurrentThreadScheduler`
* Adds `generate` operator
* Cleanup of dead observer code.
* Removes `SpinLock`s in disposables in favor of more performant `OSAtomicCompareAndSwap32`.
* Adds `buffer` operator (version with time and count).
* Adds `range` operator.
* Adds `repeat` operator.

## [2.0.0-alpha.2](https://github.com/ReactiveX/RxSwift/releases/tag/2.0.0-alpha.2)

#### Updated

* Renames `ScopedDispose` to `ScopedDisposable`
* Deprecates `observeSingleOn` in favor of `observeOn`
* Adds inline documentation
* Renames `from` to `asObservable` extension method on `SequenceType`
* Renames `catchErrorResumeNext` in favor of `catchErrorJustReturn`
* Deprecates `catchErrorToResult`, the preferred way is to use Swift `do/try/catch` mechanism.
* Deprecates `RxResult`, the preferred way is to use Swift `do/try/catch` mechanism.
* Deprecates `sendNext` on `Variable` in favor of just using `value` setter.
* Renames `rx_searchText` to `rx_text` on `UISearchBar+Rx`.
* Changes parameter type for `rx_imageAnimated` to be transitionType (kCATransitionFade, kCATransitionMoveIn, ...).

## [2.0.0-alpha.1](https://github.com/ReactiveX/RxSwift/releases/tag/2.0-alpha.1)

#### Fixed

* Problem in RxExample with missing `observeOn` for images.

#### Updated

* Removes deprecated APIs
* Adds `ObservableType`
* Moved from using `>-` operator to protocol extensions
* Change from `disposeBag.addDisposable` to `disposable.addDisposableTo`
* Changes in RxCocoa extensions to enable fluent style
* Rename of `do*` to `doOn*`
* Deprecates `returnElement` in favor of `just`
* Deprecates `aggregate` in favor of `reduce`
* Deprecates `variable` in favor of `shareReplay(1)` (to be consistent with RxJS version)
* Method `next` on `Variable` in favor of `sendNext`


#### Fixed

## [1.9.1](https://github.com/ReactiveX/RxSwift/releases/tag/1.9.1)

#### Updated

* Adds Calculator example app
* Performance improvements for Queue

#### Fixed

* Crash in `rx_didChangeAuthorizationStatus`. [#89](https://github.com/ReactiveX/RxSwift/issues/89)
