# Change Log
All notable changes to this project will be documented in this file.

---

## [2.4](https://github.com/ReactiveX/RxSwift/releases/tag/2.4)

#### Features

* adds `Driver.drive` with `Variable` parameter.
* exposes `RxSearchBarDelegateProxy`
* adds `rx_cancelButtonClicked` to `UISearchBar`.
* adds `rx_searchButtonClicked` to `UISearchBar`.
* adds `UISearchController` extensions:
  * `rx_didDismiss`
  * `rx_didPresent`
  * `rx_present`
  * `rx_willDismiss`
  * `rx_willPresent`


#### Anomalies

* Fixes anomaly with `multicast` disposing subscription.
* Small grammar fixes in code.
* Fixes in documentation.

## [2.3.1](https://github.com/ReactiveX/RxSwift/releases/tag/2.3.1)

#### Features

* Xcode 7.3 / Swift 2.2 support

## [2.3.0](https://github.com/ReactiveX/RxSwift/releases/tag/2.3.0)

#### Features

* Adds `rx_badgeValue` to `UITabBarItem`.
* Adds `rx_progress` to `UIProgresView`.
* Adds `rx_selectedScopeButtonIndex` to `UISearchBar`.
* Adds `asyncInstance` to `MainScheduler`.
* Makes `name` parmeter optional for `rx_notification` extension.
* Adds `UnitTests.md`.
* Adds `Tips.md`.
* Updates playground inline documentation with running instructions.
* Synchronizes copy of `RxDataSources` source files inside example project to `0.6` release.

#### Anomalies

* Fixes anomaly with synchronization in disposable setter of `SingleAssignmentDisposable`.
* Improves `DelegateProxy` memory management.
* Fixes anomaly during two way binding of `UITextView` text value.
* Improves `single` operator so it handles reentrancy better.

## [2.2.0](https://github.com/ReactiveX/RxSwift/releases/tag/2.2.0)

#### Public Interface anomalies

* Fixes problem with `timer` operator. Changes return type from `Observable<Int64>` to `Observable<T>`. This could potentially cause code breakage, but it was an API anomaly.
* Curried functions were marked deprecated so they were replaced in `UITableView` and `UICollectionView` extensions with equivalent lambdas. This shouldn't break anyone's code, but it is a change in public interface.

This is example of those changes:

```swift
- public func rx_itemsWithCellFactory<S : SequenceType, O : ObservableType where O.E == S>
      (source: O)
      (cellFactory: (UITableView, Int, S.Generator.Element) -> UITableViewCell) -> Disposable
+ public func rx_itemsWithCellFactory<S : SequenceType, O : ObservableType where O.E == S>
      (source: O)
      -> (cellFactory: (UITableView, Int, S.Generator.Element) -> UITableViewCell) -> Disposable
```

* Fixes anomaly in `CLLocationManager` extensions

```swift
-    public var rx_didFinishDeferredUpdatesWithError: RxSwift.Observable<NSError> { get }
+    public var rx_didFinishDeferredUpdatesWithError: RxSwift.Observable<NSError?> { get }
```

#### Features

* Adds `UIBindingObserver`.
* Adds `doOnNext` convenience operator (also added to `Driver`).
* Adds `doOnError` convenience operator.
* Adds `doOnCompleted` convenience operator (also added to `Driver`).
* Adds `skip`, `startWith` to `Driver`.
* Adds `rx_active` extension to `NSLayoutConstraint`.
* Adds `rx_refreshing` extension to `UIRefreshControl`.
* Adds `interval` and `timer` to `Driver`.
* Adds `rx_itemAccessoryButtonTapped` to `UITableView` extensions.
* Adds `rx_networkActivityIndicatorVisible` to `UIApplication`.
* Adds `rx_selected` to `UIControl`.

#### Anomalies

* Fixes anomaly with registering multiple observers to `UIBarButtonItem`.
* Fixes anomaly with blocking operators possibly over-stopping the `RunLoop`.

## [2.1.0](https://github.com/ReactiveX/RxSwift/releases/tag/2.1.0)

#### Features

* Adds `UIImagePickerController` delegate wrappers.
* Adds `SectionedViewDataSourceType` that enables third party data sources to use existing `rx_modelSelected`/`rx_modelDeselected` wrappers.
* Adds `rx_modelDeselected` to `UITableView`
* Adds `rx_itemDeselected` to `UITableView`
* Adds `rx_modelDeselected` to `UICollectionView`
* Adds `rx_itemDeselected` to `UICollectionView`
* Adds `rx_state` to `NSButton`
* Adds `rx_enabled` to `NSControl`
* Adds `UIImagePickerController` usage example to Example app.

#### Anomalies

* Removes usage of `OSSpinLock`s from all `Darwin` platforms because of problems with inversion of priority on iOS. [Original thread on swift mailing list is here](https://lists.swift.org/pipermail/swift-dev/Week-of-Mon-20151214/000321.html)
* Reduces verbose output from `RxCocoa` project in debug mode. `TRACE_RESOURCES` is now also treated as a verbosity level setting. It is possible to get old output by using `TRACE_RESOURCES` with verbosity level `>= 2`. [#397](https://github.com/ReactiveX/RxSwift/issues/397)
* Fixes anomaly with logging of HTTP body of requests in `RxCocoa` project.

## [2.0.0](https://github.com/ReactiveX/RxSwift/releases/tag/2.0.0)

#### Features

* Changes package names to `io.rx.[library]`
* Packages data sources from `RxDataSourceStarterKit` into it's own repository [RxDataSources](https://github.com/RxSwiftCommunity/RxDataSources) under `RxSwiftCommunity`.
* Removes deprecated APIs.

#### Anomalies

* Replaces hacky code that solved anomaly caused by interaction between autocorrect and text controls notification mechanism with proper solution. #333

## [2.0.0-rc.0](https://github.com/ReactiveX/RxSwift/releases/tag/2.0.0-rc.0)

#### Features

* Adds generic `public func rx_sentMessage(selector: Selector) -> Observable<[AnyObject]>` that enables observing of messages
 sent to any object. (This is enabled if DISABLE_SWIZZLING isn't set).
  * use cases like `cell.rx_sentMessage("prepareForReuse")` are now supported.
* Linux support (proof of concept, but single threaded mode works)
  * more info in [Documentation/Linux.md](https://github.com/ReactiveX/RxSwift/blob/master/Documentation/Linux.md)
* Initial support for `Swift Package Manager`
  * works on `Linux` (`RxSwift`, `RxBlocking`, `RxTests`)
  * doesn't work on OSX because it can't compile `RxCocoa` and `RxTests` (because of inclusion of `XCTest` extensions), but OSX has two other package managers and manual method.
  * Project content is linked to `Sources` automagically using custom tool
  * more info in [Documentation/Linux.md](https://github.com/ReactiveX/RxSwift/blob/master/Documentation/Linux.md)
* Adds `VirtualTimeScheduler` to `RxSwift`
* Adds `HistoricalScheduler` to `RxSwift`
* Improves performance of virtual schedulers using priority queue.
* Adds new `RxTests` library to enable testing of custom Rx operators.
This library contains everything needed to write unit tests in the following way:
```swift
func testMap() {
    let scheduler = TestScheduler(initialClock: 0)

    let xs = scheduler.createHotObservable([
        next(150, 1),
        next(210, 0),
        next(220, 1),
        next(230, 2),
        next(240, 4),
        completed(300)
        ])

    let res = scheduler.start { xs.map { $0 * 2 } }

    let correctEvents = [
        next(210, 0 * 2),
        next(220, 1 * 2),
        next(230, 2 * 2),
        next(240, 4 * 2),
        completed(300)
    ]

    let correctSubscriptions = [
        Subscription(200, 300)
    ]

    XCTAssertEqual(res.events, correctEvents)
    XCTAssertEqual(xs.subscriptions, correctSubscriptions)
}
```

* Adds test project for `RxExample-iOS` that demonstrates how to easily write marble tests using `RxTests` project.
```swift
let (
    usernameEvents,
    passwordEvents,
    repeatedPasswordEvents,
    loginTapEvents,

    expectedValidatedUsernameEvents,
    expectedSignupEnabledEvents
) = (
    scheduler.parseEventsAndTimes("e---u1----u2-----u3-----------------", values: stringValues).first!,
    scheduler.parseEventsAndTimes("e----------------------p1-----------", values: stringValues).first!,
    scheduler.parseEventsAndTimes("e---------------------------p2---p1-", values: stringValues).first!,
    scheduler.parseEventsAndTimes("------------------------------------", values: events).first!,

    scheduler.parseEventsAndTimes("e---v--f--v--f---v--o----------------", values: validations).first!,
    scheduler.parseEventsAndTimes("f--------------------------------t---", values: booleans).first!
)
```

* Adds example app for GitHub signup example that shows the same example written with and without `Driver`.
* Documents idea behind units and `Driver` in `Units.md`.
* Example of table view with editing is polished to use more functional approach.
* Adds `deferred` to `Driver` unit.
* Removes implicitly unwrapped optionals from `CLLocationManager` extensions.
* Removes implicitly unwrapped optionals from `NSURLSession` extensions.
* Polishes the `debug` operator format.
* Adds optional `cellType` parameter to Table/Collection view `rx_itemsWithCellIdentifier` method.
* Polish for calculator example in `RxExample` app.
* Documents and adds unit tests for tail recursive optimizations of `concat` operator.
* Moves `Event` equality operator to `RxTests` project.
* Adds `seealso` references to `reactivex.io`.
* Polishes headers in source files and adds tests to enforce standard header format.
* Adds `driveOnScheduler` to enable scheduler mocking for `Driver` during unit tests.
* Adds assertions to `drive*` family of functions that makes sure they are always called from main thread.
* Refactoring and polishing of internal ObjC runtime interception architecture.

#### Deprecated

* Changes `ConnectableObservable`, generic argument is now type of elements in observable sequence and not type of underlying subject. (BREAKING CHANGE)
* Removes `RxBox` and `RxMutable` box from public interface. (BREAKING CHANGE)
* `SchedulerType` now isn't parametrized on `Time` and `TimeInterval`.
* Deprecates `Variable` implementing `ObservableType` in favor of `asObservable()`.
  * Now variable also sends `.Completed` to observable sequence returned from `asObservable` when deallocated.
    If you were (mis)using variable to return single value
    ```
    Variable(1).map { x in ... }
    ```
    ... you can just use `just` operator
    ```
    Observable.just(1).map { x in ... }
    ```
* Deprecates free functions in favor of `Observable` factory methods, and deprecates versions of operators with hidden external parameters (scheduler, count) in favor of ones with explicit parameter names.
    E.g.

    `Observable.just(1)` instead of `just(1)`

    `Observable.empty()` instead of `empty()`

    `Observable.error()` instead of `failWith()`

    `Observable.of(1, 2, 3)` instead of `sequenceOf(1, 2, 3)`

    `.debounce(0.2, scheduler: MainScheduler.sharedInstance)` instead of `.debounce(0.2, MainScheduler.sharedInstance)`

    `Observable.range(start:0, count: 10)` instead of `range(0, 10)`

    `Observable.generate(initialState: 0, condition: { $0 < 10 }) { $0 + 1 }` instead of `generate(0, condition: { $0 < 10 }) { $0 + 1 }`

    `Observable<Int>.interval(1, scheduler: MainScheduler.sharedInstance)` instead of `interval(1, MainScheduler.sharedInstance)`

    ...

    If you want to continue using free functions form, you can define your free function aliases for `Observable` factory methods (basically copy deprecated methods).
* Deprecates `UIAlertView` extensions.
  * These extensions could be stored locally if needed.
* Deprecates `UIActionSheet` extensions.
  * These extensions could be stored locally if needed.
* Deprecates `rx_controlEvents` in favor of `rx_controlEvent`.
* Deprecates `MainScheduler.sharedInstance` in favor of `MainScheduler.instance`
* Deprecates `ConcurrentMainScheduler.sharedInstance` in favor of `ConcurrentMainScheduler.instance`
* Deprecates factory methods from `Drive` in favor of `Driver` factory methods.
* Deprecates `sampleLatest` in favor of `withLatestFrom`.
* Deprecates `ScopedDisposable` and `scopedDispose()` in favor of `DisposeBag`.

#### Fixed

* Improves and documents resource leak code in `RxExample`.
* Replaces `unowned` reference with `weak` references in `RxCocoa` project.
* Fixes `debug` operator not using `__FILE__` and `__LINE__` properly.
* Fixes anomaly with `timeout` operator.
* Fixes problem with spell-checker and `UIText*` losing focus.

## [2.0.0-beta.4](https://github.com/ReactiveX/RxSwift/releases/tag/2.0.0-beta.4)

#### Updated

* Adds `ignoreElements` operator.
* Adds `timeout` operator (2 overloads).
* Adds `shareReplayLatestWhileConnected` operator.
* Changes `Driver` to internally use `shareReplayLatestWhileConnected` for subscription sharing instead of `shareReplay(1)`.
* Adds `flatMapFirst` to `Driver` unit.
* Adds `replayAll` operator.
* Adds `createUnbounded` factory method to `ReplaySubject`.
* Adds optional type hints to `empty`, `failWith` and `never` (`empty(Int)` now works and means empty observable sequence of `Int`s).
* Adds `rx_hidden` to `UIView`.
* Adds `rx_alpha` to `UIView`.
* Adds `rx_attributedText` to `UILabel`.
* Adds `rx_animating` to `UIActivityIndicatorView`.
* Adds `rx_constant` to `NSLayoutConstraint`.
* Removes implicitly unwrapped optional from `NSURLSession.rx_response`.
* Exposes `rx_createDataSourceProxy`, `rx_createDelegateProxy` on `UITableView`/`UICollectionView`.
* Exposes `rx_createDelegateProxy` on `UITextView`.
* Exposes `rx_createDelegateProxy` on `UIScrollView`.
* Exposes `RxCollectionViewDataSourceProxy`.
* Exposes `RxCollectionViewDelegateProxy`.
* Exposes `RxScrollViewDelegateProxy`.
* Exposes `RxTableViewDataSourceProxy`.
* Exposes `RxTableViewDelegateProxy`.
* Deprecates `proxyForObject` in favor of `proxyForObject<P : DelegateProxyType>(type: P.Type, _ object: AnyObject) -> P`.
* Deprecates `rx_modelSelected<T>()` in favor of `rx_modelSelected<T>(modelType: T.Type)`.
* Adds `func bindTo(variable: Variable<E>) -> Disposable` extension to `ObservableType`.
* Exposes `ControlEvent` init.
* Exposes `ControlProperty` init.
* Refactoring of example app
  * Divides examples into sections
  * Adds really simple examples of how to do simple calculated bindings with vanilla Rx.
  * Adds really simple examples of table view extensions (sectioned and non sectioned version).
  * Refactoring of `GitHub sign in example` to use MVVM paradigm.

#### Fixed

* Fixes documentation for `flatMapFirst`
* Fixes problem with delegate proxies not detecting all delegate methods in delegate proxy hierarchy.

## [2.0.0-beta.3](https://github.com/ReactiveX/RxSwift/releases/tag/2.0.0-beta.3)

#### Updated

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

#### Fixed

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
