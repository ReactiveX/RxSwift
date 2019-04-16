Traits (formerly Units)
=====

This document will try to describe what traits are, why they are a useful concept, and how to use and create them.

* [General](#general)
  * [Why](#why)
  * [How they work](#how-they-work)
* [RxSwift traits](#rxswift-traits)
  * [Single](#single)
    * [Creating a Single](#creating-a-single)
  * [Completable](#completable)
    * [Creating a Completable](#creating-a-completable)
  * [Maybe](#maybe)
    * [Creating a Maybe](#creating-a-maybe)
* [RxCocoa traits](#rxcocoa-traits)
  * [Driver](#driver)
      * [Why is it named Driver](#why-is-it-named-driver)
      * [Practical usage example](#practical-usage-example)
  * [Signal](#signal)
  * [ControlProperty / ControlEvent](#controlproperty--controlevent)


## General
### Why

Swift has a powerful type system that can be used to improve the correctness and stability of applications and make using Rx a more intuitive and straightforward experience.

Traits help communicate and ensure observable sequence properties across interface boundaries, as well as provide contextual meaning, syntactical sugar and target more specific use-cases when compared to a raw Observable, which could be used in any context. **For that reason, Traits are entirely optional. You are free to use raw Observable sequences everywhere in your program as all core RxSwift/RxCocoa APIs support them.**

_**Note:** Some of the Traits described in this document (such as `Driver`) are specific only to the [RxCocoa](https://github.com/ReactiveX/RxSwift/tree/master/RxCocoa) project, while some are part of the general [RxSwift](https://github.com/ReactiveX/RxSwift) project. However, the same principles could easily be implemented in other Rx implementations, if necessary. There is no private API magic needed._

### How they work

Traits are simply a wrapper struct with a single read-only Observable sequence property.

```swift
struct Single<Element> {
    let source: Observable<Element>
}

struct Driver<Element> {
    let source: Observable<Element>
}
...
```

You can think of them as a kind of builder pattern implementation for Observable sequences. When a Trait is built, calling `.asObservable()` will transform it back into a vanilla observable sequence.

---

## RxSwift traits

### Single

A Single is a variation of Observable that, instead of emitting a series of elements, is always guaranteed to emit either _a single element_ or _an error_.

* Emits exactly one element, or an error.
* Doesn't share side effects.

One common use case for using Single is for performing HTTP Requests that could only return a response or an error, but a Single can be used to model any case where you only care for a single element, and not for an infinite stream of elements.

#### Creating a Single
Creating a Single is similar to creating an Observable.
A simple example would look like this:

```swift
func getRepo(_ repo: String) -> Single<[String: Any]> {
    return Single<[String: Any]>.create { single in
        let task = URLSession.shared.dataTask(with: URL(string: "https://api.github.com/repos/\(repo)")!) { data, _, error in
            if let error = error {
                single(.error(error))
                return
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves),
                  let result = json as? [String: Any] else {
                single(.error(DataError.cantParseJSON))
                return
            }

            single(.success(result))
        }

        task.resume()

        return Disposables.create { task.cancel() }
    }
}
```

After which you could use it in the following way:

```swift
getRepo("ReactiveX/RxSwift")
    .subscribe { event in
        switch event {
            case .success(let json):
                print("JSON: ", json)
            case .error(let error):
                print("Error: ", error)
        }
    }
    .disposed(by: disposeBag)
```

Or by using `subscribe(onSuccess:onError:)` as follows: 
```swift
getRepo("ReactiveX/RxSwift")
    .subscribe(onSuccess: { json in
                   print("JSON: ", json)
               },
               onError: { error in
                   print("Error: ", error)
               })
    .disposed(by: disposeBag)
```

The subscription provides a `SingleEvent` enumeration which could be either `.success` containing a element of the Single's type, or `.error`. No further events would be emitted beyond the first one.

It's also possible using `.asSingle()` on a raw Observable sequence to transform it into a Single.

### Completable

A Completable is a variation of Observable that can only _complete_ or _emit an error_. It is guaranteed to not emit any elements.

* Emits zero elements.
* Emits a completion event, or an error.
* Doesn't share side effects.

A useful use case for Completable would be to model any case where we only care for the fact an operation has completed, but don't care about a element resulted by that completion.
You could compare it to using an `Observable<Void>` that can't emit elements.

#### Creating a Completable
Creating a Completable is similar to creating an Observable. A simple example would look like this:

```swift
func cacheLocally() -> Completable {
    return Completable.create { completable in
       // Store some data locally
       ...
       ...

       guard success else {
           completable(.error(CacheError.failedCaching))
           return Disposables.create {}
       }

       completable(.completed)
       return Disposables.create {}
    }
}
```

After which you could use it in the following way:
```swift
cacheLocally()
    .subscribe { completable in
        switch completable {
            case .completed:
                print("Completed with no error")
            case .error(let error):
                print("Completed with an error: \(error.localizedDescription)")
        }
    }
    .disposed(by: disposeBag)
```

Or by using `subscribe(onCompleted:onError:)` as follows:
```swift
cacheLocally()
    .subscribe(onCompleted: {
                   print("Completed with no error")
               },
               onError: { error in
                   print("Completed with an error: \(error.localizedDescription)")
               })
    .disposed(by: disposeBag)
```

The subscription provides a `CompletableEvent` enumeration which could be either `.completed` - indicating the operation completed with no errors, or `.error`. No further events would be emitted beyond the first one.

### Maybe
A Maybe is a variation of Observable that is right in between a Single and a Completable. It can either emit a single element, complete without emitting an element, or emit an error.

**Note:** Any of these three events would terminate the Maybe, meaning - a Maybe that completed can't also emit an element, and a Maybe that emitted an element can't also send a Completion event.

* Emits either a completed event, a single element or an error.
* Doesn't share side effects.

You could use Maybe to model any operation that **could** emit an element, but doesn't necessarily **have to** emit an element.

#### Creating a Maybe
Creating a Maybe is similar to creating an Observable. A simple example would look like this:

```swift
func generateString() -> Maybe<String> {
    return Maybe<String>.create { maybe in
        maybe(.success("RxSwift"))

        // OR

        maybe(.completed)

        // OR

        maybe(.error(error))

        return Disposables.create {}
    }
}
```

After which you could use it in the following way:
```swift
generateString()
    .subscribe { maybe in
        switch maybe {
            case .success(let element):
                print("Completed with element \(element)")
            case .completed:
                print("Completed with no element")
            case .error(let error):
                print("Completed with an error \(error.localizedDescription)")
        }
    }
    .disposed(by: disposeBag)
```

Or by using `subscribe(onSuccess:onError:onCompleted:)` as follows:

```swift
generateString()
    .subscribe(onSuccess: { element in
                   print("Completed with element \(element)")
               },
               onError: { error in
                   print("Completed with an error \(error.localizedDescription)")
               },
               onCompleted: {
                   print("Completed with no element")
               })
    .disposed(by: disposeBag)
```

It's also possible using `.asMaybe()` on a raw Observable sequence to transform it into a `Maybe`.

---

## RxCocoa traits

### Driver

This is the most elaborate trait. Its intention is to provide an intuitive way to write reactive code in the UI layer, or for any case where you want to model a stream of data _Driving_ your application.

* Can't error out.
* Observe occurs on main scheduler.
* Shares side effects (`share(replay: 1, scope: .whileConnected)`).

#### Why is it named Driver

Its intended use case was to model sequences that drive your application.

E.g.
* Drive UI from CoreData model.
* Drive UI using values from other UI elements (bindings).
...


Like normal operating system drivers, in case a sequence errors out, your application will stop responding to user input.

It is also extremely important that those elements are observed on the main thread because UI elements and application logic are usually not thread safe.

Also, a `Driver` builds an observable sequence that shares side effects.

E.g.

#### Practical usage example

This is a typical beginner example.

```swift
let results = query.rx.text
    .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
    .flatMapLatest { query in
        fetchAutoCompleteItems(query)
    }

results
    .map { "\($0.count)" }
    .bind(to: resultCount.rx.text)
    .disposed(by: disposeBag)

results
    .bind(to: resultsTableView.rx.items(cellIdentifier: "Cell")) { (_, result, cell) in
        cell.textLabel?.text = "\(result)"
    }
    .disposed(by: disposeBag)
```

The intended behavior of this code was to:
* Throttle user input.
* Contact server and fetch a list of user results (once per query).
* Bind the results to two UI elements: results table view and a label that displays the number of results.

So, what are the problems with this code?:
* If the `fetchAutoCompleteItems` observable sequence errors out (connection failed or parsing error), this error would unbind everything and the UI wouldn't respond any more to new queries.
* If `fetchAutoCompleteItems` returns results on some background thread, results would be bound to UI elements from a background thread which could cause non-deterministic crashes.
* Results are bound to two UI elements, which means that for each user query, two HTTP requests would be made, one for each UI element, which is not the intended behavior.

A more appropriate version of the code would look like this:

```swift
let results = query.rx.text
    .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
    .flatMapLatest { query in
        fetchAutoCompleteItems(query)
            .observeOn(MainScheduler.instance)  // results are returned on MainScheduler
            .catchErrorJustReturn([])           // in the worst case, errors are handled
    }
    .share(replay: 1)                           // HTTP requests are shared and results replayed
                                                // to all UI elements

results
    .map { "\($0.count)" }
    .bind(to: resultCount.rx.text)
    .disposed(by: disposeBag)

results
    .bind(to: resultsTableView.rx.items(cellIdentifier: "Cell")) { (_, result, cell) in
        cell.textLabel?.text = "\(result)"
    }
    .disposed(by: disposeBag)
```

Making sure all of these requirements are properly handled in large systems can be challenging, but there is a simpler way of using the compiler and traits to prove these requirements are met.

The following code looks almost the same:

```swift
let results = query.rx.text.asDriver()        // This converts a normal sequence into a `Driver` sequence.
    .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
    .flatMapLatest { query in
        fetchAutoCompleteItems(query)
            .asDriver(onErrorJustReturn: [])  // Builder just needs info about what to return in case of error.
    }

results
    .map { "\($0.count)" }
    .drive(resultCount.rx.text)               // If there is a `drive` method available instead of `bind(to:)`,
    .disposed(by: disposeBag)              // that means that the compiler has proven that all properties
                                              // are satisfied.
results
    .drive(resultsTableView.rx.items(cellIdentifier: "Cell")) { (_, result, cell) in
        cell.textLabel?.text = "\(result)"
    }
    .disposed(by: disposeBag)
```

So what is happening here?

This first `asDriver` method converts the `ControlProperty` trait to a `Driver` trait.

```swift
query.rx.text.asDriver()
```

Notice that there wasn't anything special that needed to be done. `Driver` has all of the properties of the `ControlProperty` trait, plus some more. The underlying observable sequence is just wrapped as a `Driver` trait, and that's it.

The second change is:

```swift
.asDriver(onErrorJustReturn: [])
```

Any observable sequence can be converted to `Driver` trait, as long as it satisfies 3 properties:
* Can't error out.
* Observe on main scheduler.
* Sharing side effects (`share(replay: 1, scope: .whileConnected)`).

So how do you make sure those properties are satisfied? Just use normal Rx operators. `asDriver(onErrorJustReturn: [])` is equivalent to following code.

```swift
let safeSequence = xs
  .observeOn(MainScheduler.instance)        // observe events on main scheduler
  .catchErrorJustReturn(onErrorJustReturn)  // can't error out
  .share(replay: 1, scope: .whileConnected) // side effects sharing

return Driver(raw: safeSequence)            // wrap it up
```

The final piece is using `drive` instead of using `bind(to:)`.

`drive` is defined only on the `Driver` trait. This means that if you see `drive` somewhere in code, that observable sequence can never error out and it observes on the main thread, which is safe for binding to a UI element.

Note however that, theoretically, someone could still define a `drive` method to work on `ObservableType` or some other interface, so to be extra safe, creating a temporary definition with `let results: Driver<[Results]> = ...` before binding to UI elements would be necessary for complete proof. However, we'll leave it up to the reader to decide whether this is a realistic scenario or not.

### Signal

A `Signal` is similar to `Driver` with one difference, it does **not** replay the latest event on subscription, but subscribers still share the sequence's computational resources.

It can be considered a builder pattern to model Imperative Events in a Reactive way as part of your application.

A `Signal`:

* Can't error out.
* Delivers events on Main Scheduler.
* Shares computational resources (`share(scope: .whileConnected)`).
* Does NOT replay elements on subscription.

## ControlProperty / ControlEvent

### ControlProperty

Trait for `Observable`/`ObservableType` that represents property of UI element.
 
Sequence of values only represents initial control value and user initiated value changes. Programmatic value changes won't be reported.

It's properties are:

- it never fails
- `share(replay: 1)` behavior
    - it's stateful, upon subscription (calling subscribe) last element is immediately replayed if it was produced
- it will `Complete` sequence on control being deallocated
- it never errors out
- it delivers events on `MainScheduler.instance`

The implementation of `ControlProperty` will ensure that sequence of events is being subscribed on main scheduler (`subscribeOn(ConcurrentMainScheduler.instance)` behavior).

#### Practical usage example

We can find very good practical examples in the `UISearchBar+Rx` and in the `UISegmentedControl+Rx`:

```swift 
extension Reactive where Base: UISearchBar {
    /// Reactive wrapper for `text` property.
    public var value: ControlProperty<String?> {
        let source: Observable<String?> = Observable.deferred { [weak searchBar = self.base as UISearchBar] () -> Observable<String?> in
            let text = searchBar?.text
            
            return (searchBar?.rx.delegate.methodInvoked(#selector(UISearchBarDelegate.searchBar(_:textDidChange:))) ?? Observable.empty())
                    .map { a in
                        return a[1] as? String
                    }
                    .startWith(text)
        }

        let bindingObserver = Binder(self.base) { (searchBar, text: String?) in
            searchBar.text = text
        }
        
        return ControlProperty(values: source, valueSink: bindingObserver)
    }
}
```

```swift
extension Reactive where Base: UISegmentedControl {
    /// Reactive wrapper for `selectedSegmentIndex` property.
    public var selectedSegmentIndex: ControlProperty<Int> {
        return value
    }
    
    /// Reactive wrapper for `selectedSegmentIndex` property.
    public var value: ControlProperty<Int> {
        return UIControl.rx.value(
            self.base,
            getter: { segmentedControl in
                segmentedControl.selectedSegmentIndex
            }, setter: { segmentedControl, value in
                segmentedControl.selectedSegmentIndex = value
            }
        )
    }
}
```

### ControlEvent

Trait for `Observable`/`ObservableType` that represents event on UI element.

It's properties are:

- it never fails
- it won't send any initial value on subscription
- it will `Complete` sequence on control being deallocated
- it never errors out
- it delivers events on `MainScheduler.instance`

The implementation of `ControlEvent` will ensure that sequence of events is being subscribed on main scheduler (`subscribeOn(ConcurrentMainScheduler.instance)` behavior).

#### Practical usage example

This is a typical case example in which you can use it:

```swift
public extension Reactive where Base: UIViewController {
    
    /// Reactive wrapper for `viewDidLoad` message `UIViewController:viewDidLoad:`.
    public var viewDidLoad: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.viewDidLoad)).map { _ in }
        return ControlEvent(events: source)
    }
}
```

And in the `UICollectionView+Rx` we can found it in this way:

```swift

extension Reactive where Base: UICollectionView {
    
    /// Reactive wrapper for `delegate` message `collectionView:didSelectItemAtIndexPath:`.
    public var itemSelected: ControlEvent<IndexPath> {
        let source = delegate.methodInvoked(#selector(UICollectionViewDelegate.collectionView(_:didSelectItemAt:)))
            .map { a in
                return a[1] as! IndexPath
            }
        
        return ControlEvent(events: source)
    }
}
```
