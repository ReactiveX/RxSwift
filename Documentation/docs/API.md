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

  * [`delaySubscription`](http://reactivex.io/documentation/operators/delay.html)
  * [`do` / `doOnNext`](http://reactivex.io/documentation/operators/do.html)
  * [`observeOn` / `observeSingleOn`](http://reactivex.io/documentation/operators/observeon.html)
  * [`subscribe`](http://reactivex.io/documentation/operators/subscribe.html)
  * [`subscribeOn`](http://reactivex.io/documentation/operators/subscribeon.html)
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

    public func rx_controlEvents(controlEvents: UIControlEvents) -> ControlEvent<Void> {}

    public var rx_enabled: ObserverOf<Bool> {}
}

```

```swift
extension UIButton {

    public var rx_tap: ControlEvent<Void> {}

}
```

```swift
extension UITextField {

    public var rx_text: ControlProperty<String> {}

}
```

```swift
extension UITextView {

    override func rx_createDelegateProxy() -> RxScrollViewDelegateProxy {}

    public var rx_text: ControlProperty<String> {}

}
```

```swift
extension UISearchBar {

    public var rx_delegate: DelegateProxy {}

    public var rx_searchText: ControlProperty<String> {}

}
```

```swift
extension UILabel {

    public var rx_text: ObserverOf<String> {}

}
```

```swift
extension UIDatePicker {

    public var rx_date: ControlProperty<NSDate> {}

}
```

```swift
extension UIImageView {

    public var rx_image: ObserverOf<UIImage!> {}

    public func rx_imageAnimated(animated: Bool) -> ObserverOf<UIImage!> {}

}
```

```swift
extension UIScrollView {

    public var rx_delegate: DelegateProxy {}

    public func rx_setDelegate(delegate: UIScrollViewDelegate) {}

    public var rx_contentOffset: ControlProperty<CGPoint> {}

}
```

```swift
extension UIBarButtonItem {

    public var rx_tap: ControlEvent<Void> {}

}
```

```swift
extension UISlider {

    public var rx_value: ControlProperty<Float> {}

}
```

```swift
extension UITableView {

    public var rx_dataSource: DelegateProxy {}

    public func rx_setDataSource(dataSource: UITableViewDataSource) -> Disposable {}

    public func rx_itemsWithCellFactory(source: O)(cellFactory: (UITableView, Int, S.Generator.Element) -> UITableViewCell) -> Disposable {}

    public func rx_itemsWithCellIdentifier(cellIdentifier: String)(source: O)(configureCell: (Int, S.Generator.Element, Cell) -> Void) -> Disposable {}

    public func rx_itemsWithDataSource(dataSource: DataSource)(source: O) -> Disposable {}

    public var rx_itemSelected: ControlEvent<NSIndexPath> {}

    public var rx_itemInserted: ControlEvent<NSIndexPath> {}

    public var rx_itemDeleted: ControlEvent<NSIndexPath> {}

    public var rx_itemMoved: ControlEvent<ItemMovedEvent> {}

    // This method only works in case one of the `rx_itemsWith*` methods was used.
    public func rx_modelSelected<T>() -> ControlEvent<T> {}

}
```

```swift
extension UICollectionView {

    public var rx_dataSource: DelegateProxy {}

    public func rx_setDataSource(dataSource: UICollectionViewDataSource) -> Disposable {}

    public func rx_itemsWithCellFactory(source: O)(cellFactory: (UICollectionView, Int, S.Generator.Element) -> UICollectionViewCell) -> Disposable {}

    public func rx_itemsWithCellIdentifier(cellIdentifier: String)(source: O)(configureCell: (Int, S.Generator.Element, Cell) -> Void) -> Disposable {}

    public func rx_itemsWithDataSource(dataSource: DataSource)(source: O) -> Disposable {}

    public var rx_itemSelected: ControlEvent<NSIndexPath> {}

    // This method only works in case one of the `rx_itemsWith*` methods was used.
    public func rx_modelSelected<T>() -> ControlEvent<T> {}
}
```

```swift
extension UIGestureRecognizer {

    public var rx_event: ControlEvent<UIGestureRecognizer> {}

}
```

```swift
extension UIActionSheet {

    public var rx_delegate: DelegateProxy {}

    public var rx_clickedButtonAtIndex: ControlEvent<Int> {}

    public var rx_willDismissWithButtonIndex: ControlEvent<Int> {}

    public var rx_didDismissWithButtonIndex: ControlEvent<Int> {}

}
```


```swift
extension UIAlertView {

    public var rx_delegate: DelegateProxy {}

    public var rx_clickedButtonAtIndex: ControlEvent<Int> {}

    public var rx_willDismissWithButtonIndex: ControlEvent<Int> {}

    public var rx_didDismissWithButtonIndex: ControlEvent<Int> {}

}
```

```swift
extension UISegmentedControl {

    public var rx_value: ControlProperty<Int> {}

}
```

```swift
extension UISwitch {

    public var rx_value: ControlProperty<Bool> {}

}
```

**OSX**

```swift
extension NSControl {

    public var rx_controlEvents: ControlEvent<()> {}

}
```

```swift

extension NSSlider {

    public var rx_value: ControlProperty<Double> {}

}
```

```swift
extension NSButton {

    public var rx_tap: ControlEvent<Void> {}

}
```

```swift
extension NSImageView {

    public var rx_image: ObserverOf<NSImage!> {}

    public func rx_imageAnimated(animated: Bool) -> ObserverOf<NSImage!> {}
}
```

```swift
extension NSTextField {

    public var rx_delegate: DelegateProxy {}

    public var rx_text: ControlProperty<String> {}

}
```
