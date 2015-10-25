# Change Log
All notable changes to this project will be documented in this file.

---

## [2.0.0-beta.1](https://github.com/ReactiveX/RxSwift/releases/tag/2.0.0-beta.1)

#### Updated

* Adds `Driver` unit. This unit uses Swift compiler to prove certain properties about observable sequences. Specifically
  * that fallback error handling is put in place
  * results are observed on main thread
  * work is performed only when there is a need (at least one subscriber)
  * computation results are shared between different observers (replay latest element)
* Renames `ObserverOf` to `AnyObserver`.
* Adds new interface `ObservableConvertibleType`.
* Adds `BlockingObservable` to `RxBlocking` and makes it more consistent with `RxJava`.
* Renames `func subscribe(next:error:completed:disposed:)` to `func subscribe(onNext:onError:onCompleted:onDisposed:)`
* Adds concat convenience method `public func concat<O : ObservableConvertibleType where O.E == E>(second: O) -> RxSwift.Observable<Self.E>`
* Adds `skipUntil` operator.
* Adds `takeWhile` operator.
* Renames `takeWhile` indexed version to `takeWhileWithIndex`
* Adds `skipWhile` operator.
* Adds `skipWhileWithIndex` operator.
* Adds `using` operator.
* Renames `func doOn(next:error:completed:)` to `func doOn(onNext:onError:onCompleted:)`.
* Makes `RecursiveImmediateSchedulerOf` private.
* Makes `RecursiveSchedulerOf` private.
* Adds `ConcurrentMainScheduler`.
* Adds overflow error so now in case of overflow, operators will return `RxErrorCode.Overflow`.
* Adds `rx_modelAtIndexPath` to `UITableView` and `UICollectionView`.
* Adds `var rx_didUpdateFocusInContextWithAnimationCoordinator: ControlEvent<(context:animationCoordinator:)>` to `UITableView` and `UICollectionView`
* Makes `resultSelector` argument in `combineLatest` explicit `func combineLatest<O1, O2, R>(source1: O1, _ source2: O2, resultSelector: (O1.E, O2.E) throws -> R) -> RxSwift.Observable<R>`.
* Makes `resultSelector` argument in `zip` explicit `func combineLatest<O1, O2, R>(source1: O1, _ source2: O2, resultSelector: (O1.E, O2.E) throws -> R) -> RxSwift.Observable<R>`.
* Adds activity indicator example in `RxExample` app.
* Adds two way binding example in `RxExample` app.
* many other small features

#### Fixed

* Problem with xcodebuild 7.0.1 treating tvOS shared schemes as osx schemes.

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
