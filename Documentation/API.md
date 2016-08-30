API
===

## RxSwift supported operators

In some cases there are multiple aliases for the same operator, because on different platforms / implementations, the same operation is sometimes named differently. Sometimes this is because of historical reasons, while sometimes because of reserved language keywords.

When lacking a strong community consensus, RxSwift will usually include multiple aliases.

Operators are stateless by default.

#### Creating Observables

 * [`asObservable`](http://reactivex.io/documentation/operators/from.html)
 * [`create`](http://reactivex.io/documentation/operators/create.html)
 * [`deferred`](http://reactivex.io/documentation/operators/defer.html)
 * [`empty`](http://reactivex.io/documentation/operators/empty-never-throw.html)
 * [`error`](http://reactivex.io/documentation/operators/empty-never-throw.html)
 * [`toObservable` (array)](http://reactivex.io/documentation/operators/from.html)
 * [`interval`](http://reactivex.io/documentation/operators/interval.html)
 * [`never`](http://reactivex.io/documentation/operators/empty-never-throw.html)
 * [`just`](http://reactivex.io/documentation/operators/just.html)
 * [`of`](http://reactivex.io/documentation/operators/from.html)
 * [`range`](http://reactivex.io/documentation/operators/range.html)
 * [`repeatElement`](http://reactivex.io/documentation/operators/repeat.html)
 * [`timer`](http://reactivex.io/documentation/operators/timer.html)

#### Transforming Observables

  * [`buffer`](http://reactivex.io/documentation/operators/buffer.html)
  * [`flatMap`](http://reactivex.io/documentation/operators/flatmap.html)
  * [`flatMapFirst`](http://reactivex.io/documentation/operators/flatmap.html)
  * [`flatMapLatest`](http://reactivex.io/documentation/operators/flatmap.html)
  * [`map`](http://reactivex.io/documentation/operators/map.html)
  * [`scan`](http://reactivex.io/documentation/operators/scan.html)
  * [`window`](http://reactivex.io/documentation/operators/window.html)

#### Filtering Observables

  * [`debounce` / `throttle`](http://reactivex.io/documentation/operators/debounce.html)
  * [`distinctUntilChanged`](http://reactivex.io/documentation/operators/distinct.html)
  * [`elementAt`](http://reactivex.io/documentation/operators/elementat.html)
  * [`filter`](http://reactivex.io/documentation/operators/filter.html)
  * [`sample`](http://reactivex.io/documentation/operators/sample.html)
  * [`skip`](http://reactivex.io/documentation/operators/skip.html)
  * [`take`](http://reactivex.io/documentation/operators/take.html)
  * [`takeLast`](http://reactivex.io/documentation/operators/takelast.html)
  * [`single`](http://reactivex.io/documentation/operators/first.html)

#### Combining Observables

  * [`merge`](http://reactivex.io/documentation/operators/merge.html)
  * [`startWith`](http://reactivex.io/documentation/operators/startwith.html)
  * [`switchLatest`](http://reactivex.io/documentation/operators/switch.html)
  * [`combineLatest`](http://reactivex.io/documentation/operators/combinelatest.html)
  * [`zip`](http://reactivex.io/documentation/operators/zip.html)

#### Error Handling Operators

 * [`catch`](http://reactivex.io/documentation/operators/catch.html)
 * [`retry`](http://reactivex.io/documentation/operators/retry.html)
 * [`retryWhen`](http://reactivex.io/documentation/operators/retry.html)

#### Observable Utility Operators

  * [`delaySubscription` / `delay`](http://reactivex.io/documentation/operators/delay.html)
  * [`do` / `doOnNext`](http://reactivex.io/documentation/operators/do.html)
  * [`observeOn` / `observeSingleOn`](http://reactivex.io/documentation/operators/observeon.html)
  * [`subscribe`](http://reactivex.io/documentation/operators/subscribe.html)
  * [`subscribeOn`](http://reactivex.io/documentation/operators/subscribeon.html)
  * [`timeout`](http://reactivex.io/documentation/operators/timeout.html)
  * [`using`](http://reactivex.io/documentation/operators/using.html)
  * debug

#### Conditional and Boolean Operators

  * [`amb`](http://reactivex.io/documentation/operators/amb.html)
  * [`skipWhile`](http://reactivex.io/documentation/operators/skipwhile.html)
  * [`skipUntil`](http://reactivex.io/documentation/operators/skipuntil.html)
  * [`takeUntil`](http://reactivex.io/documentation/operators/takeuntil.html)
  * [`takeWhile`](http://reactivex.io/documentation/operators/takewhile.html)

#### Mathematical and Aggregate Operators

  * [`concat`](http://reactivex.io/documentation/operators/concat.html)
  * [`reduce` / `aggregate`](http://reactivex.io/documentation/operators/reduce.html)
  * [`toArray`](http://reactivex.io/documentation/operators/to.html)

#### Connectable Observable Operators

  * [`multicast`](http://reactivex.io/documentation/operators/publish.html)
  * [`publish`](http://reactivex.io/documentation/operators/publish.html)
  * [`refCount`](http://reactivex.io/documentation/operators/refcount.html)
  * [`replay`](http://reactivex.io/documentation/operators/replay.html)
  * [`shareReplay`](http://reactivex.io/documentation/operators/replay.html)

Creating new operators is also pretty straightforward.

## RxCocoa extensions

**iOS / OSX**

```swift

extension Reactive where Base: NSObject {

    public var deallocated: Observable<Void> {}

#if !DISABLE_SWIZZLING

    public var deallocating: Observable<Void> {}

#endif

}

```


```swift
extension Reactive where Base: NSObject {

    public func observe<Element>(
        type: E.Type,
        _ keyPath: String,
        options: NSKeyValueObservingOptions = .New | .Initial,
        retainSelf: Bool = true
    )  -> Observable<Element?> {}

#if !DISABLE_SWIZZLING

    public func observeWeakly<Element>(
        type: E.Type,
        _ keyPath: String,
        options: NSKeyValueObservingOptions = .New | .Initial
    ) -> Observable<Element?> {}

#endif
}
```

```swift
extension Reactive where Base: NSURLSession {

    public func response(request: NSURLRequest) -> Observable<(NSData, NSURLResponse)> {}

    public func data(request: NSURLRequest) -> Observable<NSData> {}

    public func JSON(request: NSURLRequest) -> Observable<AnyObject> {}

    public func JSON(URL: NSURL) -> Observable<AnyObject> {}

}
```

```swift
extension Reactive where Base: NSNotificationCenter {

    public func notification(name: String, object: AnyObject?) -> Observable<NSNotification> {}

}
```

```swift
class DelegateProxy {

    public func observe(selector: Selector) -> Observable<[AnyObject]> {}

}
```

```swift
extension Reactive where Base: CLLocationManager {

    public var delegate: DelegateProxy {}

    public var didUpdateLocations: Observable<[CLLocation]> {}

    public var didFailWithError: Observable<NSError> {}

    public var didFinishDeferredUpdatesWithError: Observable<NSError> {}

    public var didPauseLocationUpdates: Observable<Void> {}

    public var didResumeLocationUpdates: Observable<Void> {}

    public var didUpdateHeading: Observable<CLHeading> {}

    public var didEnterRegion: Observable<CLRegion> {}

    public var didExitRegion: Observable<CLRegion> {}

    public var didDetermineStateForRegion: Observable<(state: CLRegionState, region: CLRegion)> {}

    public var monitoringDidFailForRegionWithError: Observable<(region: CLRegion?, error: NSError)> {}

    public var didStartMonitoringForRegion: Observable<CLRegion> {}

    public var didRangeBeaconsInRegion: Observable<(beacons: [CLBeacon], region: CLBeaconRegion)> {}

    public var rangingBeaconsDidFailForRegionWithError: Observable<(region: CLBeaconRegion, error: NSError)> {}

    public var didVisit: Observable<CLVisit> {}

    public var didChangeAuthorizationStatus: Observable<CLAuthorizationStatus> {}

}
```

**iOS**

```swift

extension Reactive where Base: UIControl {

    public func controlEvent(controlEvents: UIControlEvents) -> ControlEvent<Void> {}

    public var enabled: ObserverOf<Bool> {}
}

```

```swift
extension Reactive where Base: UIButton {

    public var tap: ControlEvent<Void> {}

}
```

```swift
extension Reactive where Base: UITextField {

    public var text: ControlProperty<String> {}

}
```

```swift
extension Reactive where Base: UITextView {

    override func createDelegateProxy() -> RxScrollViewDelegateProxy {}

    public var text: ControlProperty<String> {}

}
```

```swift
extension Reactive where Base: UISearchBar {

    public var delegate: DelegateProxy {}

    public var searchText: ControlProperty<String> {}

}
```

```swift
extension Reactive where Base: UILabel {

    public var text: ObserverOf<String> {}

}
```

```swift
extension Reactive where Base: UIDatePicker {

    public var date: ControlProperty<NSDate> {}

}
```

```swift
extension Reactive where Base: UIImageView {

    public var image: ObserverOf<UIImage!> {}

    public func imageAnimated(transitionType: String?) -> AnyObserver<UIImage?>

}
```

```swift
extension Reactive where Base: UIScrollView {

    public var delegate: DelegateProxy {}

    public func setDelegate(delegate: UIScrollViewDelegate) {}

    public var contentOffset: ControlProperty<CGPoint> {}

}
```

```swift
extension Reactive where Base: UIBarButtonItem {

    public var tap: ControlEvent<Void> {}

}
```

```swift
extension Reactive where Base: UISlider {

    public var value: ControlProperty<Float> {}

}
```

```swift
extension Reactive where Base: UITableView {

    public var dataSource: DelegateProxy {}

    public func setDataSource(dataSource: UITableViewDataSource) -> Disposable {}

    public func itemsWithCellFactory(source: O)(cellFactory: (UITableView, Int, S.Iterator.Element) -> UITableViewCell) -> Disposable {}

    public func itemsWithCellIdentifier(cellIdentifier: String, cellType: Cell.Type = Cell.self)(source: O)(configureCell: (Int, S.Iterator.Element, Cell) -> Void) -> Disposable {}

    public func itemsWithDataSource(dataSource: DataSource)(source: O) -> Disposable {}

    public var itemSelected: ControlEvent<IndexPath> {}

    public var itemDeselected: ControlEvent<IndexPath> {}

    public var itemInserted: ControlEvent<IndexPath> {}

    public var itemDeleted: ControlEvent<IndexPath> {}

    public var itemMoved: ControlEvent<ItemMovedEvent> {}

    // This method only works in case one of the `rx.itemsWith*` methods was used, or data source implements `SectionedViewDataSourceType`
    public func modelSelected<T>(modelType: T.Type) -> ControlEvent<T> {}

    // This method only works in case one of the `rx.itemsWith*` methods was used, or data source implements `SectionedViewDataSourceType`
    public func modelDeselected<T>(modelType: T.Type) -> ControlEvent<T> {}

}
```

```swift
extension Reactive where Base: UICollectionView {

    public var dataSource: DelegateProxy {}

    public func setDataSource(dataSource: UICollectionViewDataSource) -> Disposable {}

    public func itemsWithCellFactory(source: O)(cellFactory: (UICollectionView, Int, S.Iterator.Element) -> UICollectionViewCell) -> Disposable {}

    public func itemsWithCellIdentifier(cellIdentifier: String, cellType: Cell.Type = Cell.self)(source: O)(configureCell: (Int, S.Iterator.Element, Cell) -> Void) -> Disposable {}

    public func itemsWithDataSource(dataSource: DataSource)(source: O) -> Disposable {}

    public var itemSelected: ControlEvent<IndexPath> {}

    public var itemDeselected: ControlEvent<IndexPath> {}

    // This method only works in case one of the `rx.itemsWith*` methods was used, or data source implements `SectionedViewDataSourceType`
    public func modelSelected<T>(modelType: T.Type) -> ControlEvent<T> {}

    // This method only works in case one of the `rx.itemsWith*` methods was used, or data source implements `SectionedViewDataSourceType`
    public func modelSelected<T>(modelType: T.Type) -> ControlEvent<T> {}
}
```

```swift
extension Reactive where Base: UIGestureRecognizer {

    public var event: ControlEvent<UIGestureRecognizer> {}

}
```

```swift
extension Reactive where Base: UIImagePickerController {

    public var didFinishPickingMediaWithInfo: Observable<[String : AnyObject]> {}

    public var didCancel: Observable<()> {}

}
```

```swift
extension Reactive where Base: UISegmentedControl {

    public var value: ControlProperty<Int> {}

}
```

```swift
extension Reactive where Base: UISwitch {

    public var value: ControlProperty<Bool> {}

}
```

```swift
extension Reactive where Base: UIActivityIndicatorView {

    public var animating: AnyObserver<Bool> {}

}
```

```swift
extension Reactive where Base: UINavigationItem {

    public var title: AnyObserver<String?> {}
}
```

**OSX**

```swift
extension Reactive where Base: NSControl {

    public var controlEvent: ControlEvent<()> {}

    public var enabled: AnyObserver<Bool> {}

}
```

```swift

extension Reactive where Base: NSSlider {

    public var value: ControlProperty<Double> {}

}
```

```swift
extension Reactive where Base: NSButton {

    public var tap: ControlEvent<Void> {}

    public var state: ControlProperty<Int> {}

}
```

```swift
extension Reactive where Base: NSImageView {

    public var image: ObserverOf<NSImage?> {}

    public func imageAnimated(transitionType: String?) -> AnyObserver<NSImage?>
}
```

```swift
extension Reactive where Base: NSTextField {

    public var delegate: DelegateProxy {}

    public var text: ControlProperty<String> {}

}
```

```swift
extension Reactive where Base: UITabBarItem {

    public var badgeValue: AnyObserver<String?> {}

}
```

```swift
extension Reactive where Base: UITabBar {

    public var didSelectItem: ControlEvent<UITabBarItem> {}

    public var willBeginCustomizing: ControlEvent<[UITabBarItem]> {}

    public var didBeginCustomizing: ControlEvent<[UITabBarItem]> {}

    public var willEndCustomizing: ControlEvent<(items: [UITabBarItem], changed: Bool)> {}

    public var didEndCustomizing: ControlEvent<(items: [UITabBarItem], changed: Bool)> {}

}
```
