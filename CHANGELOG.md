# Change Log
All notable changes to this project will be documented in this file.

---
## Master

#### Anomalies

## [4.1.2](https://github.com/ReactiveX/RxSwift/releases/tag/4.1.2)

* Adds deprecation warner.

#### Anomalies

* Fixes ambiguity issue with  `Single.do(onNext:onError:onSubscribe:onSubscribed:onDispose:)` and `Single.do(onSuccess:onError:onSubscribe:onSubscribed:onDispose:)`.

## [4.1.1](https://github.com/ReactiveX/RxSwift/releases/tag/4.1.1)

#### Anomalies

* Fixes compilation issue with  Xcode 9.1.
* Deprecates `Single.do(onNext:onError:onSubscribe:onSubscribed:onDispose:)` in favor of `Single.do(onSuccess:onError:onSubscribe:onSubscribed:onDispose:)`.

## [4.1.0](https://github.com/ReactiveX/RxSwift/releases/tag/4.1.0)

* Adds `Recorded<Event<T>>` array factory method in **RxTest**. #1531
* Replaces global functions `next`, `error`, `completed` with `Recorded.next`, `Recorded.error`, `Recorded.completed` in **RxTest**. #1510
* Removes `AnyObject` constraint from `Delegate` parameter on `DelegateProxy`. #1442
* Adds `ObservableType.bind(to:)` overloads for `PublishRelay` and `BehaviorRelay`.
* Adds `ControlEvent.asSignal()`.
* Adds `UISegmentedControl.rx.enabled(forSegmentAt:)` extension.
* Adds `UIStepper.rx.stepValue` extension.
* Adds error handling Hook to `Single`, `Maybe` and `Completable`. #1532
* Adds `recordCallStackOnError` to improve performance of `DEBUG` configuration.

#### Anomalies

* Changes return value of blocking version of `single` operator from `E?` to `E`. #1525
* Removes deprecation attribute from `asSharedSequence`.

## [4.0.0](https://github.com/ReactiveX/RxSwift/releases/tag/4.0.0)

* Adds global Hooks and implements error handling hook.
* Deprecates `asSharedSequence` extensions on `ObservableType`.
* Publicly exposes `controlProperty`.

#### Anomalies

* Changes `Observable` extensions to `ObservableType` extensions.
* Changes `didUpdateFocusInContextWithAnimationCoordinator` `UITableView` extension argument to `UITableViewFocusUpdateContext`.
* Changes access modifier of `DelegateProxy.setForwardToDelegate` to `open`.

## [4.0.0-rc.0](https://github.com/ReactiveX/RxSwift/releases/tag/4.0.0-rc.0)

* Deprecates `image(transitionType:)` in favor of `image`.
* Changes return type of `ignoreElements` to `Completable`. #1436
* Removes warning of sequence completion from `Binder`. #1431
* Deprecates `Variable` in favor of `BehaviorRelay`.

## [4.0.0-beta.1](https://github.com/ReactiveX/RxSwift/releases/tag/4.0.0-beta.1)

* Adds `attributedText` to `UITextField`. #1249
* Adds `attributedText` to `UITextView`. #1249
* Deprecates `shareReplayLatestWhileConnected` and `shareReplay` in favor of `share(replay:scope:)`. #1430
* Changes `publish`, `replay`, `replayAll` to clear state in case of sequence termination to be more consistent with other Rx implementations and enable retries. #1430
* Replaces `share` with default implementation of `share(replay:scope:)`. #1430
* Adds `HasDelegate` and `HasDataSource` protocols.
* Updates package version to v4 format. #1418

#### Anomalies

* Adds deprecated warnings to API parts that were missing it. #1427
* Improves memory handling in `isScheduleRequiredKey`. #1428
* Removes pre-release identifier from bundle version to enable `TestFlight` submissions. #1424
* Removes code coverage to enable `TestFlight` submissions. #1423
* Fixes Xcode warnings. #1421

## [4.0.0-beta.0](https://github.com/ReactiveX/RxSwift/releases/tag/4.0.0-beta.0)

* Adds `materialize()` operator for RxBlocking's `BlockingObservable`. #1383
* Adds `first` operator to `ObservableType`.
* Deprecates `UIBindingObserver` in favor of `Binder`. #1411
* Adds another specialization of `SharedSequence` called `Signal`.
* Refactors `DelegateProxy` to be type safe.
* Changes nested `SharedSequence` strategy to use inner sharing strategy for result.

#### Anomalies

* Call `controlTextDidChange(…)` as an optional method. #1406
* Fixed issue with `NSControl.rx.value` regarding multiple observers. #1399
* Removes useless extensions from `PrimitiveSequence`. #1248

## [4.0.0-alpha.1](https://github.com/ReactiveX/RxSwift/releases/tag/4.0.0-alpha.1)

* Merge of `3.6.1` changes.
* Adds `UIScrollView.willEndDragging` extension. #1365
* Adds `enumerated` operator (deprecates `skipWhileWithIndex`, `takeWhileWithIndex`, `flatMapWithIndex`, `mapWithIndex`).

#### Anomalies
* Fixes gesture recognizer extensions crash. #1382
* Adds `onSubscribed` parameter to `SharedSequence` extensions.

## [4.0.0-alpha.0](https://github.com/ReactiveX/RxSwift/releases/tag/4.0.0-alpha.0)
* Swift 4.0 compatibility
* Changes delegate proxy to use plugin architecture. 

#### Anomalies
* Fixes public interface leakage of `NSKeyValueObservingOptions`. #1164

## [3.6.1](https://github.com/ReactiveX/RxSwift/releases/tag/3.6.1)

#### Anomalies

* Fixes compilation issue with Xcode 9b3. #1341
* Fixes issues with `andThen` operator. #1347
* Improves locking behavior of `merge` and `switch` operators. #1344

## [3.6.0](https://github.com/ReactiveX/RxSwift/releases/tag/3.6.0)

* Adds `timeout` operator to `PrimitiveSequence` (`Single`, `Maybe`, `Observable`)
* Adds `delay` operator to `SharedSequence`.
* Adds `andThen` operator to `Completeable`.
* Adds `concat` operator to `Completeable`.
* Adds `RxPickerViewDataSourceType`
* Adds `UIPickerView` extensions:
    * `modelSelected`
    * `itemTitles`
    * `itemAttributedTitles`
    * `items`
* Adds `UITableView` extensions:
    * `modelDeleted`
* Adds `UICollectionView` extensions:
    * `itemHighlighted`
    * `itemUnhighlighted`
    * `willDisplayCell`
    * `didEndDisplayingCell`
    * `willDisplaySupplementaryView`
    * `didEndDisplayingSupplementaryView`
* Adds `UIScrollView` extensions:
    * `willBeginDecelerating`
    * `willBeginDragging`
    * `willBeginZooming`
    * `didEndZooming`

#### Anomalies

* Fixes deadlock anomaly in `shareReplayWhileLatest`. #1323
* Removes duplicated events swallowing in `NSControl` on macOS.

## [3.5.0](https://github.com/ReactiveX/RxSwift/releases/tag/3.5.0)

* Adds `from` operator on "SharedSequence"
* Adds `concat` operator on "Completable"
* Adds `merge` operator on "Completable"
* Adds `using` operator on "PrimitiveSequence"
* Adds `concatMap` operator.
* Adds `share(replay:scope:)` operator.
* Adds `multicast(makeSubject:)` operator.
* Adds `UIButton.image(for:)` extension.
* Adds `UIButton.backgroundImage(for:)` extension.
* fixes typos

#### Anomalies

* Improves reentrancy and synchronization checks.
* Issues with `share()` and `shareReplay(_:)`. #1111
* `.share()` inconsistent in behavior. #1242
* Fixes issues with `Driver` sometimes sending initial element async. #1253

## [3.4.1](https://github.com/ReactiveX/RxSwift/releases/tag/3.4.1) (Xcode 8.3.1 / Swift 3.1 compatible)

* Adds `UINavigationController` delegate proxy and extensions:
    * `willShow`
    * `didShow`
* Deprecates `TestScheduler.start(_:create:)` in favor of `TestScheduler.start(disposed:create:)`.
* Deprecates `TestScheduler.start(_:subscribed:disposed:create:)` in favor of `TestScheduler.start(created:subscribed:disposed:create:)`.

#### Anomalies

* Fixes observable sequence completion in case of empty arrays for `combineLatest` and `zip`. #1205
* Fixes array version of `merge` operator completing immediately in case one of the observable sequences is empty. #1221
* Adds RxTest to SPM. #1215
* Adds tuple version of operator `SharedSequence.zip` (collection).
* Adds tuple version of operator `SharedSequence.zip`.
* Adds tuple version of operator `SharedSequence.combineLatest` (collection).
* Adds tuple version of operator `SharedSequence.combineLatest`.
* Adds missing `trimOutput` parameter to `SharedSequence.debug`.
* Makes `RxImagePickerDelegateProxy` subclass of `RxNavigationControllerDelegateProxy`.


## [3.4.0](https://github.com/ReactiveX/RxSwift/releases/tag/3.4.0) (Xcode 8.3.1 / Swift 3.1 compatible)

* Xcode 8.3.1 / Swift 3.1 compatibility.
* Add subscription closures for Single, Maybe and Completable (`onSuccess`, `onError`, `onCompleted`).
* Rename Units as Traits and update the documentation for Single, Completable & Maybe.
* Deprecates `bindTo` in favor of `bind(to:)`.
* Adds [`materialize`](http://reactivex.io/documentation/operators/materialize-dematerialize.html) operator
* Adds [`dematerialize`](http://reactivex.io/documentation/operators/materialize-dematerialize.html) operator
* Adds `latest` parameter to `SharedSequence.throttle` operator.
* Adds `debug` operator to `PrimitiveSequence`.

#### Anomalies

* Fixes problem with `UICollectionView` data source caching and disposal logic. #1154

## [3.3.1](https://github.com/ReactiveX/RxSwift/releases/tag/3.3.1) (Xcode 8 / Swift 3.0 compatible)

#### Anomalies

* Fixes misspelled `Completeable` to `Completable`. #1134 

## [3.3.0](https://github.com/ReactiveX/RxSwift/releases/tag/3.3.0) (Xcode 8 / Swift 3.0 compatible)

* Adds `Single`, `Maybe`, `Completable` traits inspired by RxJava (operators):
    * `create`
    * `deferred`
    * `just`
    * `error`
    * `never`
    * `delaySubscription`
    * `delay`
    * `do`
    * `filter`
    * `map`
    * `flatMap`
    * `observeOn`
    * `subscribeOn`
    * `catchError`
    * `retry`
    * `retryWhen`
    * `zip`
* Adds `asSingle()` operator on `ObservableType`.
* Adds `asMaybe()` operator on `ObservableType`.
* Adds `asCompletable()` operator on `ObservableType`.
* Adds variadic `combineLatest` and `zip` overloads without result selector (defaults to tuple).
* Adds array `combineLatest` and `zip` overloads with result selector (defaults to array of elements)
* Adds optimized synchronous `merge` operator to observable sequence (variadic, array, collection). #579
* Adds optimized synchronous `merge` operator to shared sequence (variadic, array, collection).
* Adds `AsyncSubject` implementation.
* Adds `XCTAssertEqual` overloads to `RxTest`.
* Adds `countDownDuration` to `UIDatePicker`.
* Adds `attributedTitle(for:)` to `UIButton`.
* Adds `onSubscribed` to `do` operator.
* Adds `isUserInteractionEnabled` to `UIView`.

#### Anomalies
* Improves DelegateProxy `responds(to:)` selector logic to only respond to used selectors. #1081, #1087
* Deprecates `from()` in favor of `from(optional:)` to avoid issues with implicit conversions to optional.
* Fixes thread sanitizer reporting issues with `merge` operator. #1063
* Calls `collectionViewLayout.invalidateLayout()` after `reloadData()` as a workaround for iOS 10 bug.
* Changes `UICollectionView.rx.didUpdateFocusInContextWithAnimationCoordinator` context parameter type to `UICollectionViewFocusUpdateContext`

## [3.2.0](https://github.com/ReactiveX/RxSwift/releases/tag/3.2.0) (Xcode 8 / Swift 3.0 compatible)

* Adds `groupBy` operator
* Adds `ifEmpty(switchTo:)` operator
* Adds [`ifEmpty(default:)`]((http://reactivex.io/documentation/operators/defaultifempty.html)) operator
* Adds `Disposable` extension `disposed(by:)` equivalent to `addDisposableTo` that is meant to replace it in future 4.0 version.
* Consolidates atomic operations on Linux and Darwin platform.
* Adds DEBUG mode concurrent asserts for `Variable` and `Observable.create`.
* Adds DEBUG mode concurrent asserts for `Sink`.
* Small performance optimizations for subjects.
* Adaptations for Xcode 8.3 beta.
* Adds `numberOfPages` to `UIPageControl`.
* Adds additional resources cleanup unit tests for cases where operators are used without `DisposeBag`s. 
* Chroes:
    * Adds `final` keyword wherever applicable.
    * Remove unnecessary `import Foundation` statements.
    * Examples cleanup.

#### Anomalies

* Improves behavior of `shareReplayWhileConnected` by making sure that events emitted after disconnect are ignored even in case of fast reconnect.
* Fixes a couple of operators that were not cleaning up resources on terminal events when used without `DisposeBag`s.
* Fixes delegate proxy interaction with subclassing of `UISearchController`.
* Fixes delegate proxy interaction with subclassing of `NSTextStorage`.
* Fixes delegate proxy interaction with subclassing of `UIWebView`.
* Fixes delegate proxy interaction with subclassing of `UIPickerView`.

## [3.1.0](https://github.com/ReactiveX/RxSwift/releases/tag/3.1.0) (Xcode 8 / Swift 3.0 compatible)

* Adds `changed` property to `ControlProperty` that returns `ControlEvent` of user generated changes.
  * `textField.text.changed.map { "User changed text to \($0)" }`
* Adds optional overloads for `from` operator. `let num: Int? = 3; let sequence = Observable.from(num)`
* Improves `UIBindingObserver` by tolerating binding from non main dispatch queue. In case binding is attempted
  from non main dispatch queue it will be automagically dispathed async to main queue.
* Makes control property naming consistent for `UIDatePicker`, `UISearchBar`, `UISegmentedControl`, `UISwitch`, `UITextField`, `UITextView` (`value` property + value alias name).
* Adds missing extension to `UIScrollView`. 
    * `didScroll` 
    * `didZoom`
    * `didEndDecelerating`
    * `didEndDragging`
    * `didScrollToTop`
* Renames `refreshing` to `isRefreshing`.
* adds `UIWebView` extensions:
    * `didStartLoad`
    * `didFinishLoad`
    * `didFailLoad`
* Adds `UITabBarController` extensions
    * `willBeginCustomizing`
    * `willEndCustomizing`
    * `didEndCustomizing` 
    * `didSelect`
* Adds `UIBarButtonItem` extensions
    * `title`
* Performance optimizations
* Improves data source behavior by clearing data source proxy when forwarding delegate is `nil`.

#### Anomalies

* Fixes anomaly caused by `UITableView` invalid state caching of previous data source even after the change.
  Binding of reactive data source now triggers `layoutIfNeeded` that invalidates that internal cached state.
* Fixes issue with race in `AnyRecursiveScheduler`. #995

## [3.0.1](https://github.com/ReactiveX/RxSwift/releases/tag/3.0.1) (Xcode 8 / Swift 3.0 compatible)

#### Anomalies

* Fixes RxCocoa problems on macOS (`TextInput` now uses `NSTextInputClient`)
* Hides accidentally exposed `BagKey` structure.
* Makes `notification` extension `name` parameter optional.

## [3.0.0](https://github.com/ReactiveX/RxSwift/releases/tag/3.0.0) (Xcode 8 / Swift 3.0 compatible)

* Prefixes boolean properties with `is` and makes `String?` properties consistent.
    * `rx.hidden` -> `rx.isHidden`
    * `rx.enabled` -> `rx.isEnabled`
    ...
    also ...
    * since `rx.text` has now type `String?` to be consistent with UIKit, in case `String` is needed
    there is `rx.text.orEmpty` that has `String` type.   
* Renames `title(controlState:)` on `UIButton` to `title(for:)`.
* All data structures are now internal (`Bag`, `Queue`, `PriorityQueue` ...)
* Improves performance of `Bag`.
* Polishes RxCocoa `URLSession` extensions
    * `JSON` -> `json`
    * return type is `Any` instead of `AnyObject`
    * replaces response tuple parameters, now it's `(HTTPResponse, Data)`
    * removes name hiding for `request` parameter
* Migrates `Driver` and `NSNotification` tests to `Linux`.
* Removes RxTest from OSX + SPM integration until usable XCTest support on OSX.
* Renames `ObserverType.map` to `OberverType.mapObserver` because of possible ambigutites with subjects.
* Improves dispatch queue detection logic and replaces concept of threads in favor of dispatch queues (solves a lot
  of problems on Linux environment).
* Replaces `SectionedViewDataSourceType.model(_:)` with `SectionedViewDataSourceType.model(at:)`
* Renames `OSX` to `macOS` across the project.

#### Anomalies

* Fixes wrong casing in `#import "include/_RXObjCRuntime.h"` (was creating issues for people with
  case sensitive file system). #949
* Fixes issues with locking strategy for subjects. #936
* Fixes code example in comments of RxTableViewExtensions that didn't compile. #947
* Adds `.swift-version` to help package managers to detect Swift 3 version.

## [3.0.0-rc.1](https://github.com/ReactiveX/RxSwift/releases/tag/3.0.0-rc.1) (Xcode 8 / Swift 3.0 compatible)

* Renames `RxTests` library to `RxTest` because of problems with Swift Package Manager.
* Adds Swift Package Manager support
* Adds Linux support
* Replaces `AnyObserver` with `UIBindingObserver` in public interface.
* Renames `resourceCount` to `Resources.total`.
* Makes `rx.text` type consistent with UIKit `String?` type.

```swift
textField.rx.text          // <- now has type `ControlProperty<String?>`
textField.rx.text.orEmpty  // <- now has type `ControlProperty<String>`
```

* Adds optional overloads for `bindTo` and `drive`. Now the following works:

```swift
let text: Observable<String> = Observable.just("")

// Previously `map { $0 }` was needed because of mismatch betweeen sequence `String` type and `String?` type
// on binding `rx.text` observer.
text.bindTo(label.rx.text)  
   .disposed(by: disposeBag)

...

let text = Driver.just("")
text.drive(label.rx.text)
   .disposed(by: disposeBag)
```

* Adds trim output parameter to `debug` operator. #930
* Renames `NSDate` to `Date` everywhere.
* Renames scheduler init param `globalConcurrentQueueQOS` to `qos` and removes custom enum wrapper.
* Adds setter to `rx` property to enable mutation of base object.

## [3.0.0-beta.2](https://github.com/ReactiveX/RxSwift/releases/tag/3.0.0-beta.2) (Xcode 8 / Swift 3.0 compatible)

* Subscription disposables now only create strong references to sinks until being disposed or sequence terminates. #573

* Introduces `SharedSequence` and makes `Driver` just a specialization of `SharedSequence`.
  That means `Driver` is now just one specific `SharedSequence` and it is now possible to easily create new concepts
  that have another compile time guarantees in a couple of lines of code.
  E.g. choosing a background scheduler on which elements are delivered, or choosing `share` as a sharing strategy instead of `shareReplayLatestWhileConnected`.

* Moves `Reactive` struct and `ReactiveCompatible` from `RxCocoa` to `RxSwift` to enable third party consumers to remove `RxCocoa` dependency.

* Add `rx.` extensions on Types.

* Moves `UIImagePickerViewController` and `CLLocationManager` out of `RxCocoa` to `RxExample` project because of App Store submissions issues
  on iOS 10.

* Adds `sentMessage` got its equivalent sequence `methodInvoked` that produces elements after method is invoked (vs before method is invoked).

* Deprecates `observe` method on `DelegateProxy` in favor of `sentMessage`.
* Adds simetric `methodInvoked` method on `DelegateProxy` that enables observing after method is invoked.

* Moves all delegate extensions from using `sentMessage` to using `methodInvoked` (that fixes some problem with editing data sources)

* Fixes problem with `RxTableViewDataSourceProxy` source enabling editing of table view cells (swipe on delete) even if there weren't
any observers or `forwardToDelegate` wasn't implementing `UITableViewDataSource.tableView(_:commit:forRowAt:)`. #907

* Makes `DelegateProxy` open. #884

* Deprecates extensions that were polluting Swift collection namespaces and moves them to static functions on `Observable`
    * `Observable.combineLatest`
    * `Observable.zip`
    * `Observable.concat`
    * `Observable.catchError` (sequence version)
    * `Observable.amb`

* Deprecates extensions that were polluting Swift collection namespaces and moves them to static functions on `Driver`
    * `Driver.combineLatest`
    * `Driver.zip`
    * `Driver.concat`
    * `Driver.catchError` (sequence version)
    * `Driver.amb`

* Update Getting Started document, section on creating an observable that performs work to Swift 3.0.

* Removes stale installation instructions.

## [3.0.0-beta.1](https://github.com/ReactiveX/RxSwift/releases/tag/3.0.0-beta.1) (Xcode 8 GM compatible 8A218a)

* Adapts to new Swift 3.0 syntax.
* Corrects `throttle` operator behavior to be more consistent with other platforms. Adds `latest` flag that controls should latest element
  be emitted after dueTime.
* Adds `delay` operator.
* Adds `UISearchBar` extensions:
  * `bookmarkButtonClicked`
  * `resultsListButtonClicked`
  * `textDidBeginEditing`
  * `textDidEndEditing`
* Moves `CLLocationManager` and `UIImagePickerViewController` extensions from RxCocoa to RxExample project. #874
* Adds matrix CI builds.
=======

## [3.0.0.alpha.1](https://github.com/ReactiveX/RxSwift/releases/tag/3.0.0.alpha.1) (Xcode 8 beta 6 compatible 8S201h)

#### Features

* Modernizes API to be more consistent with Swift 3.0 API Design Guidelines
* Replaces `rx_*` prefix with `rx.*` extensions. (Inspired by `.lazy` collections API). We've tried annotate deprecated APIs with `@available(*, deprecated, renamed: "new method")` but trivial replacements aren't annotated.
	* `rx_text` -> `rx.text`
	* `rx_tap` -> `rx.tap`
	* `rx_date` -> `rx.date`
	* ...
* Deprecates `subscribeNext`, `subscribeError`, `subscribeCompleted` in favor of `subscribe(onNext:onError:onCompleted:onDisposed)` (The downsides of old extensions were inconsistencies with Swift API guidelines. They also weren't expressing that calling them actually performes additional subscriptions and thus potentially additional work beside just registering observers).
* Deprecates `doOnNext`, `doOnCompleted`, `doOnError` in favor of `do(onNext:onCompleted:onError:onSubscribe:onDisposed:)`
* Adds `onSubscribe` and `onDisposed` to `do` operator.
* Adds namespace for immutable disposables called `Disposables`
	* Deprecates `AnonymousDisposable` in favor of `Disposables.create(with:)`
	* Deprecates `NopDisposable` in favor of `Disposables.create()`
	* Deprecates `BinaryDisposable` in favor of `Disposables.create(_:_:)`
* Deprecates `toObservable` in favor of `Observable.from()`.
* Replaces old javascript automation tests with Swift UI Tests.
* ...

#### Anomalies

* There is a problem using `UISwitch` extensions because it seems that a bug exists in UIKit that causes all `UISwitch` instances to leak. https://github.com/ReactiveX/RxSwift/issues/842

## [2.6.0](https://github.com/ReactiveX/RxSwift/releases/tag/2.6.0)

#### Features

* Adds Swift 2.3 compatibility.
* Adds `UIViewController.rx_title` extension.
* Adds `UIScrollView.rx_scrollEnabled` extension.
* Resolve static analysis issues relating to non-use of an assigned value, and potential null dereferences in RxCocoa's Objective-C classes.
* Changes `forwardDelegate` property type on `DelegateProxy` from `assign` to `weak`.
* Simplifies UITable/CollectionView data source generic parameters.
* Adds simple usage examples to UITable/CollectionView data source extensions.
* Documents UITable/CollectionView data source extensions memory management and adds unit tests to cover that documentation.
* Adds `.jazzy.yml`
* Adds `UITabBar` extensions and delegate proxy wrapper
    * rx_didSelectItem
    * rx_willBeginCustomizing
    * rx_didBeginCustomizing
    * rx_willEndCustomizing
    * rx_didEndCustomizing
* Adds `UIPickerView` delegate proxy and extensions:
    * rx_itemSelected
* Adds `UIAlertAction.rx_enabled` extension.
* Adds `UIButton.rx_title(controlState: UIControlState = .Normal)` extension.
* Adds `UIPageControl.rx_currentPage` extension.
* Adds `hasObservers` property to `*Subject`.

#### Anomalies

* Fixes problem with UITable/CollectionView releasing of data sources when result subscription disposable wasn't retained.
* Fixes all Xcode analyzer warnings


## [2.5.0](https://github.com/ReactiveX/RxSwift/releases/tag/2.5.0)

#### Features

* Exposes `installForwardDelegate`.
* Adds `proxyForObject` as protocol extension and deprecates global function version.
* Improves `installForwardDelegate` assert messaging.
* Improves gesture recognizer extensions to use typed gesture recognizers in `rx_event`.
* Adds `RxTextInput` protocol to enable creating reactive extensions for `UITextInput/NSTextInput`.
* Adds `rx_willDisplayCell` and `rx_didEndDisplayingCell` extensions to `UITableView`.
* Improves playgrounds.


#### Anomalies

* Fixes in documentation.
* Turns off Bitcode for `RxTests` CocoaPods integration.
* Fixes `UITextField.rx_text` and `UITextView.rx_text` integrations to be more robust when used with two way binding.
* Fixes two way binding example code so it now properly handles IME used in Asian cultures and adds explanations how to properly perform two way bindings. https://github.com/ReactiveX/RxSwift/issues/649
* Removes `distinctUntilChanged` from control extensions. https://github.com/ReactiveX/RxSwift/issues/626


## [2.4.0](https://github.com/ReactiveX/RxSwift/releases/tag/2.4)

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
- public func rx_itemsWithCellFactory<S : Sequence, O : ObservableType where O.E == S>
      (source: O)
      (cellFactory: (UITableView, Int, S.Iterator.Element) -> UITableViewCell) -> Disposable
+ public func rx_itemsWithCellFactory<S : Sequence, O : ObservableType where O.E == S>
      (source: O)
      -> (cellFactory: (UITableView, Int, S.Iterator.Element) -> UITableViewCell) -> Disposable
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
* Deprecates `asObservable` extension of `Sequence` in favor of `toObservable`.
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
* Renames `from` to `asObservable` extension method on `Sequence`
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
