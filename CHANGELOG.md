# Change Log
All notable changes to this project will be documented in this file.

---

## [2.0.0-beta.3](https://github.com/ReactiveX/RxSwift/releases/tag/2.0.0-beta.3)

### Updated

* Improves KVO mechanism.
  * Type of observed object is now first argument `view.rx_observe(CGRect.self, "frame")`
  * Support for observing ObjC bridged enums and `RawRepresentable` protocol
  * Support for easier extending of KVO using `KVORepresentable` protocol
  * Deprecates KVO extensions that don't accept type as first argument in favor of ones that do.
* Adds `flatMapLatest` (also added to `Driver` unit).
* Adds `flatMapFirst` operator (also added to `Driver` unit).
* Adds `retryWhen` operator.
* Adds `window` operator.
* Adds `single` operator.
* Adds `single` (blocking version) operator.
* Adds `rx_primaryAction` on `UIButton` for `tvOS`.
* Transforms error types in `RxSwift`/`RxCocoa` projects from `NSError`s to Swift enum types.
  * `RxError`
  * `RxCocoaError`
  * `RxCocoaURLError`
  * ...
* `NSURLSession` extensions now return `Observable<(NSData!, NSHTTPURLResponse)>` instead of `Observable<(NSData!, NSURLResponse!)>`.
* Optimizes consecutive map operators. For example `map(validate1).map(validate2).map(parse)` is now internally optimized to one `map` operator.
* Adds overloads for `just`, `sequenceOf`, `toObservable` that accept scheduler.
* Deprecates `asObservable` extension of `SequenceType` in favor of `toObservable`.
* Adds `toObservable` extension to `Array`.
* Improves table view animated data source example.
* Polishing of `RxDataSourceStarterKit`
  * `differentiateForSectionedView` operator
  * `rx_itemsAnimatedWithDataSource` extension
* Makes blocking operators run current thread's runloop while blocking and thus disabling deadlocks.

### Fixed

* Fixes example with `Variable` in playgrounds so it less confusing regarding memory management.
* Fixes `UIImageView` extensions to use `UIImage?` instead of `UIImage!`.
* Fixes improper usage of `CustomStringConvertible` and replaces it with `CustomDebugStringConvertible`.

## [2.0.0-beta.2](https://github.com/ReactiveX/RxSwift/releases/tag/2.0.0-beta.2)

#### Updated

* Optimizations. System now performs significantly fewer allocations and is several times faster then 2.0.0-beta.1
* Makes `AnonymousObservable` private in favor of `create` method.
* Adds `toArray` operator (non blocking version).
* Adds `withLatestFrom` operator, and also extends `Driver` with that operation.
* Adds `elementAt` operator (non blocking version).
* Adds `takeLast` operator.
* Improves `RxExample` app. Adds retries example when network becomes available again.
* Adds composite extensions to `Bag` (`on`, `disposeAllIn`).
* Renames mistyped extension on `ObserverType` from `onComplete` to `onCompleted`.

#### Fixed

* Fixes minimal platform version in OSX version of library to 10.9

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
