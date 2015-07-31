API
===

## RxSwift supported operators

In some cases there are multiple aliases for the same operator, because on different platforms / implementations, the same operation is sometimes called differently. Sometimes this is because historical reasons, sometimes because of reserved language keywords.

When lacking a strong community consensus, RxSwift will usually include multiple aliases.

Operators are stateless by default.

#### Creating Observables

 * [`asObservable`](http://reactivex.io/documentation/operators/from.html)
 * [`create`](http://reactivex.io/documentation/operators/create.html)
 * [`defer`](http://reactivex.io/documentation/operators/defer.html)
 * [`empty`](http://reactivex.io/documentation/operators/empty-never-throw.html)
 * [`failWith`](http://reactivex.io/documentation/operators/empty-never-throw.html)
 * [`from` (array)](http://reactivex.io/documentation/operators/from.html)
 * [`interval`](http://reactivex.io/documentation/operators/interval.html)
 * [`never`](http://reactivex.io/documentation/operators/empty-never-throw.html)
 * [`returnElement` / `just`](http://reactivex.io/documentation/operators/just.html)
 * [`returnElements`](http://reactivex.io/documentation/operators/from.html)
 * [`timer`](http://reactivex.io/documentation/operators/timer.html)

#### Transforming Observables
  * [`flatMap`](http://reactivex.io/documentation/operators/flatmap.html)
  * [`map` / `select`](http://reactivex.io/documentation/operators/map.html)
  * [`scan`](http://reactivex.io/documentation/operators/scan.html)

#### Filtering Observables
  * [`debounce` / `throttle`](http://reactivex.io/documentation/operators/debounce.html)
  * [`distinctUntilChanged`](http://reactivex.io/documentation/operators/distinct.html)
  * [`filter` / `where`](http://reactivex.io/documentation/operators/filter.html)
  * [`sample`](http://reactivex.io/documentation/operators/sample.html)
  * [`skip`](http://reactivex.io/documentation/operators/skip.html)
  * [`take`](http://reactivex.io/documentation/operators/take.html)

#### Combining Observables

  * [`merge`](http://reactivex.io/documentation/operators/merge.html)
  * [`startWith`](http://reactivex.io/documentation/operators/startwith.html)
  * [`switchLatest`](http://reactivex.io/documentation/operators/switch.html)
  * [`combineLatest`](http://reactivex.io/documentation/operators/combinelatest.html)
  * [`zip`](http://reactivex.io/documentation/operators/zip.html)

#### Error Handling Operators

 * [`catch`](http://reactivex.io/documentation/operators/catch.html)
 * [`retry`](http://reactivex.io/documentation/operators/retry.html)

#### Observable Utility Operators

  * [`delaySubscription`](http://reactivex.io/documentation/operators/delay.html)
  * [`do` / `doOnNext`](http://reactivex.io/documentation/operators/do.html)
  * [`observeOn` / `observeSingleOn`](http://reactivex.io/documentation/operators/observeon.html)
  * [`subscribe`](http://reactivex.io/documentation/operators/subscribe.html)
  * [`subscribeOn`](http://reactivex.io/documentation/operators/subscribeon.html)
  * debug

#### Conditional and Boolean Operators
  * [`amb`](http://reactivex.io/documentation/operators/amb.html)
  * [`takeUntil`](http://reactivex.io/documentation/operators/takeuntil.html)
  * [`takeWhile`](http://reactivex.io/documentation/operators/takewhile.html)

#### Mathematical and Aggregate Operators

  * [`concat`](http://reactivex.io/documentation/operators/concat.html)
  * [`reduce` / `aggregate`](http://reactivex.io/documentation/operators/reduce.html)

#### Connectable Observable Operators

  * [`multicast`](http://reactivex.io/documentation/operators/publish.html)
  * [`publish`](http://reactivex.io/documentation/operators/publish.html)
  * [`refCount`](http://reactivex.io/documentation/operators/refcount.html)
  * [`replay`](http://reactivex.io/documentation/operators/replay.html)
  * variable / sharedWithCachedLastResult

Creating new operators is also pretty straightforward.

## RxCocoa extensions

**iOS / OSX**

```swift

extension NSObject {

    public var rx_deallocated: Observable<Void> {}

#if !DISABLE_SWIZZLING

    public var rx_deallocating: Observable<Void> {}

#endif

}

```


```swift
extension NSObject {

    public func rx_observe<Element>(
        keyPath: String,
        options: NSKeyValueObservingOptions = .New | .Initial,
        retainSelf: Bool = true
    )  -> Observable<Element?> {}

#if !DISABLE_SWIZZLING

    public func rx_observeWeakly<Element>(
        keyPath: String,
        options: NSKeyValueObservingOptions = .New | .Initial
    ) -> Observable<Element?> {}

#endif
}
```

```swift
extension NSURLSession {

    public func rx_response(request: NSURLRequest) -> Observable<(NSData!, NSURLResponse!)> {}

    public func rx_data(request: NSURLRequest) -> Observable<NSData> {}

    public func rx_JSON(request: NSURLRequest) -> Observable<AnyObject!> {}

    public func rx_JSON(URL: NSURL) -> Observable<AnyObject!> {}

}
```

```swift
extension NSNotificationCenter {

    public func rx_notification(name: String, object: AnyObject?) -> Observable<NSNotification> {}

}
```

```swift
class DelegateProxy {

    public func observe(selector: Selector) -> Observable<[AnyObject]> {}

}
```

```swift
extension CLLocationManager {

    public var rx_delegate: DelegateProxy {}

    public var rx_didUpdateLocations: Observable<[CLLocation]!> {}

    public var rx_didFailWithError: Observable<NSError!> {}

    public var rx_didFinishDeferredUpdatesWithError: Observable<NSError!> {}

    public var rx_didPauseLocationUpdates: Observable<Void> {}

    public var rx_didResumeLocationUpdates: Observable<Void> {}

    public var rx_didUpdateHeading: Observable<CLHeading!> {}

    public var rx_didEnterRegion: Observable<CLRegion!> {}

    public var rx_didExitRegion: Observable<CLRegion!> {}

    public var rx_didDetermineStateForRegion: Observable<(state: CLRegionState, region: CLRegion!)> {}

    public var rx_monitoringDidFailForRegionWithError: Observable<(region: CLRegion!, error: NSError!)> {}

    public var rx_didStartMonitoringForRegion: Observable<CLRegion!> {}

    public var rx_didRangeBeaconsInRegion: Observable<(beacons: [CLBeacon]!, region: CLBeaconRegion!)> {}

    public var rx_rangingBeaconsDidFailForRegionWithError: Observable<(region: CLBeaconRegion!, error: NSError!)> {}

    public var rx_didVisit: Observable<CLVisit!> {}

    public var rx_didChangeAuthorizationStatus: Observable<CLAuthorizationStatus> {}

}
```

**iOS**

```swift

extension UIControl {

    public func rx_controlEvents(controlEvents: UIControlEvents) -> Observable<Void> { }

    public func rx_subscribeEnabledTo(source: Observable<Bool>) -> Disposable {}

}

```

```swift
extension UIButton {

    public var rx_tap: Observable<Void> {}

}
```

```swift
extension UITextField {

    public var rx_text: Observable<String> {}

}
```

```swift
extension UITextView {

    override func rx_createDelegateProxy() -> RxScrollViewDelegateProxy { }

    public var rx_text: Observable<String> { }

}
```

```swift
extension UISearchBar {

    public var rx_delegate: DelegateProxy {}

    public var rx_searchText: Observable<String> {}

}
```

```swift
extension UILabel {

    public func rx_subscribeTextTo(source: Observable<String>) -> Disposable {}

}
```

```swift
extension UIDatePicker {

    public var rx_date: Observable<NSDate> {}

}
```

```swift
extension UIImageView {

    public func rx_subscribeImageTo(source: Observable<UIImage?>) -> Disposable {}

    public func rx_subscribeImageTo
        (animated: Bool)
        (source: Observable<UIImage?>)
            -> Disposable {}

}
```

```swift
extension UIScrollView {

    public var rx_delegate: DelegateProxy {}

    public func rx_setDelegate(delegate: UIScrollViewDelegate) {}

    public var rx_contentOffset: Observable<CGPoint> {}

}
```

```swift
extension UIBarButtonItem {

    public var rx_tap: Observable<Void> {}

}
```

```swift
extension UISlider {

    public var rx_value: Observable<Float> {}

}
```

```swift
extension UITableView {

    public var rx_dataSource: DelegateProxy {}

    public func rx_setDataSource(dataSource: UITableViewDataSource) -> Disposable {}

    public func rx_subscribeWithReactiveDataSource<DataSource: protocol<RxTableViewDataSourceType, UITableViewDataSource>>(dataSource: DataSource)
        -> Observable<DataSource.Element> -> Disposable {}

    public func rx_subscribeItemsTo<Item>(cellFactory: (UITableView, Int, Item) -> UITableViewCell)
        -> Observable<[Item]> -> Disposable {}

    public func rx_subscribeItemsToWithCellIdentifier<Item, Cell: UITableViewCell>(cellIdentifier: String, configureCell: (NSIndexPath, Item, Cell) -> Void)
        -> Observable<[Item]> -> Disposable {}

    public var rx_itemSelected: Observable<NSIndexPath> {}

    public var rx_itemInserted: Observable<NSIndexPath> {}

    public var rx_itemDeleted: Observable<NSIndexPath> {}

    public var rx_itemMoved: Observable<ItemMovedEvent> {}

    // This method only works in case one of the `rx_subscribeItemsTo` methods was used.
    public func rx_modelSelected<T>() -> Observable<T> {}

}
```

```swift
extension UICollectionView {

    public var rx_dataSource: DelegateProxy {}

    public func rx_setDataSource(dataSource: UICollectionViewDataSource) -> Disposable {}

    public func rx_subscribeWithReactiveDataSource<DataSource: protocol<RxCollectionViewDataSourceType, UICollectionViewDataSource>>(dataSource: DataSource)
        -> Observable<DataSource.Element> -> Disposable {}

    public func rx_subscribeItemsTo<Item>(cellFactory: (UICollectionView, Int, Item) -> UICollectionViewCell)
        -> Observable<[Item]> -> Disposable {}

    public func rx_subscribeItemsToWithCellIdentifier<Item, Cell: UICollectionViewCell>(cellIdentifier: String, configureCell: (Int, Item, Cell) -> Void)
        -> Observable<[Item]> -> Disposable {}

    public var rx_itemSelected: Observable<NSIndexPath> {}

    // This method only works in case one of the `rx_subscribeItemsTo` methods was used.
    public func rx_modelSelected<T>() -> Observable<T> {}
}
```

```swift
extension UIGestureRecognizer {

    public var rx_event: Observable<UIGestureRecognizer> {}

}
```

```swift
extension UIActionSheet {

    public var rx_delegate: DelegateProxy {}

    public var rx_clickedButtonAtIndex: Observable<Int> {}

    public var rx_willDismissWithButtonIndex: Observable<Int> {}

    public var rx_didDismissWithButtonIndex: Observable<Int> {}

}
```


```swift
extension UIAlertView {

    public var rx_delegate: DelegateProxy {}

    public var rx_clickedButtonAtIndex: Observable<Int> {}

    public var rx_willDismissWithButtonIndex: Observable<Int> {}

    public var rx_didDismissWithButtonIndex: Observable<Int> {}

}
```

```swift
extension UISegmentedControl {

    public var rx_value: Observable<Int> {}

}
```

```swift
extension UISwitch {

    public var rx_value: Observable<Bool> {}

}
```

**OSX**

```swift
extension NSControl {

    public var rx_controlEvents: Observable<()> {}

}
```

```swift

extension NSSlider {

    public var rx_value: Observable<Double> {}

}
```

```swift
extension NSButton {

    public var rx_tap: Observable<Void> {}

}
```

```swift
extension NSImageView {

    public func rx_subscribeImageTo(source: Observable<NSImage?>) -> Disposable {}

    public func rx_subscribeImageTo
        (animated: Bool)
        (source: Observable<NSImage?>) -> Disposable {}
}
```

```swift
extension NSTextField {

    public var rx_delegate: DelegateProxy {}

    public var rx_text: Observable<String> {}

    public func rx_subscribeTextTo(source: Observable<String>) -> Disposable {}
}
```
