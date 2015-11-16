<img src="assets/Rx_Logo_M.png" width="36" height="36"> RxSwift: ReactiveX for Swift
======================================

[![Travis CI](https://travis-ci.org/ReactiveX/RxSwift.svg?branch=master)](https://travis-ci.org/ReactiveX/RxSwift)

Xcode 7 beta 6 (7A192o) / Swift 2.0 required

**This README.md describes beta version of RxSwift 2.0.**

**You can find RxSwift 1.9 for Swift 1.2 [here](https://github.com/ReactiveX/RxSwift/tree/rxswift-1.0).**

**Don't worry, we will be applying critical hotfixes to 1.9 version, but since the entire ecosystem is migrating towards Swift 2.0, we will be focusing on adding new features only to RxSwift 2.0 version.**

**We will support all environments where Swift 2.0 will run.**

### Change Log (from 1.9 version)

* Removes deprecated APIs
* Adds `ObservableType`
* Moved from using `>-` operator to protocol extensions `.`
* Adds support for Swift 2.0 error handling `try`/`do`/`catch`

You can now just write

```swift
    API.fetchData(URL)
      .map { rawData in
          if invalidData(rawData) {
              throw myParsingError
          }

          ...

          return parsedData
      }
```

* RxCocoa introduces `bindTo` extensions

```swift
    combineLatest(firstName.rx_text, lastName.rx_text) { $0 + " " + $1 }
            .map { "Greeting \($0)" }
            .bindTo(greetingLabel.rx_text)
```

... works for `UITableView`/`UICollectionView` too

```swift
viewModel.rows
            .bindTo(resultsTableView.rx_itemsWithCellIdentifier("WikipediaSearchCell")) { (_, viewModel, cell: WikipediaSearchCell) in
                cell.viewModel = viewModel
            }
            .addDisposableTo(disposeBag)
```

* Adds new operators (array version of `zip`, array version of `combineLatest`, ...)
* Renames `catch` to `catchError`
* Change from `disposeBag.addDisposable` to `disposable.addDisposableTo`
* Deprecates `aggregate` in favor of `reduce`
* Deprecates `variable` in favor of `shareReplay(1)` (to be consistent with RxJS version)

Check out [Migration guide to RxSwift 2.0](Documentation/Migration.md)

## About Rx

Rx is a [generic abstraction of computation](https://youtu.be/looJcaeboBY) expressed through `Observable<Element>` interface.

This is a Swift version of [Rx](https://github.com/Reactive-Extensions/Rx.NET).

It tries to port as many concepts from the original version as possible, but some concepts were adapted for more pleasant and performant integration with iOS/OSX environment.

Cross platform documentation can be found on [ReactiveX.io](http://reactivex.io/).

Like the original Rx, its intention is to enable easy composition of asynchronous operations and event/data streams.

KVO observing, async operations and streams are all unified under [abstraction of sequence](Documentation/GettingStarted.md#observables-aka-sequences). This is the reason why Rx is so simple, elegant and powerful.


```
RxSwift
|
├-LICENSE.md
├-README.md
├-RxSwift         - platform agnostic core
├-RxCocoa         - extensions for UI, NSURLSession, KVO ...
├-RxBlocking      - set of blocking operators for unit testing
├-RxExample       - example apps: taste of Rx
└-Rx.xcworkspace  - workspace that contains all of the projects hooked up
```

Hang out with us on [rxswift.slack.com](http://slack.rxswift.org) <img src="http://slack.rxswift.org/badge.svg">

1. [Why](#why)
  1. [State](#state)
  1. [Bindings](#bindings)
  1. [Retries](#retries)
  1. [Transient state](#transient-state)
  1. [Aggregating network requests](#aggregating-network-requests)
  1. [Easy integration](#easy-integration)
  1. [Compositional disposal](#compositional-disposal)
  1. [Delegates](#delegates)
  1. [Notifications](#notifications)
  1. [KVO](#kvo)
  1. [Benefits](#benefits)
  1. [It's not all or nothing](#its-not-all-or-nothing)
1. [Getting started](Documentation/GettingStarted.md)
1. [Creating observable sequences](Documentation/GettingStarted.md#creating-your-own-observable-aka-observable-sequence)
1. [Examples](Documentation/Examples.md)
1. [API - RxSwift operators / RxCocoa extensions](Documentation/API.md)
1. [Build / Install / Run](#build--install--run)
1. [Math behind](Documentation/MathBehindRx.md)
1. [Hot and cold observables](Documentation/HotAndColdObservables.md)
1. [Units](Documentation/Units.md)
1. [Feature comparison with other frameworks](#feature-comparison-with-other-frameworks)
1. [Roadmap](https://github.com/ReactiveX/RxSwift/wiki/roadmap)
1. [Playgrounds](#playgrounds)
1. [RxExamples](#rxexamples)
1. [References](#references)

## Why

Producing stable code fast is usually unexpectedly hard using just your vanilla language of choice.

There are many unexpected pitfalls that can ruin all of your hard work and halt development of new features.

### State

Languages that allow mutation make it easy to access global state and mutate it. Uncontrolled mutations of shared global state can easily cause [combinatorial explosion] (https://en.wikipedia.org/wiki/Combinatorial_explosion#Computing).

But on the other hand, when used in smart way, imperative languages can enable writing more efficient code closer to hardware.

The usual way to battle combinatorial explosion is to keep state as simple as possible, and use [unidirectional data flows](https://developer.apple.com/videos/wwdc/2014/#229) to model derived data.

This is what Rx really shines at.

Rx is that sweet spot between functional and imperative world. It enables you to use immutable definitions and pure functions to process snapshots of mutable state in a reliable composable way.

So what are some of the practical examples?

### Bindings

When writing embedded UI applications you would ideally want your program interface to be just a [pure function](https://en.wikipedia.org/wiki/Pure_function) of the [truth of the system](https://developer.apple.com/videos/wwdc/2014/#229). In that way user interface could be optimally redrawn only when truth changes, and there wouldn't be any inconsistencies.

These are so called bindings and Rx can help you model your system that way.

```swift
combineLatest(firstName.rx_text, lastName.rx_text) { $0 + " " + $1 }
            .map { "Greeting \($0)" }
            .bindTo(greetingLabel.rx_text)
```

** Official suggestion is to always use `.addDisposableTo(disposeBag)` even though that's not necessary for simple bindings.**

### Retries

It would be great if APIs wouldn't fail, but unfortunately they do. Let's say there is an API method

```swift
func doSomethingIncredible(forWho: String) throws -> IncredibleThing
```

If you are using this function as it is, it's really hard to do retries in case it fails. Not to mention complexities modelling [exponential backoffs](https://en.wikipedia.org/wiki/Exponential_backoff). Sure it's possible, but code would probably contain a lot of transient states that you really don't care about, and it won't be reusable.

You would ideally want to capture the essence of retrying, and to be able to apply it to any operation.

This is how you can do simple retries with Rx

```swift
  doSomethingIncredible("me")
    .retry(3)
```

You can also easily create custom retry operators.

### Transient state

There is also a lot of problems with transient state when writing async programs. Typical example is autocomplete search box.

If you were to write the autocomplete code without Rx, first problem that probably needs to be solved is when `c` in `abc` is typed, and there is a pending request for `ab`, pending request gets cancelled. Ok, that shouldn't be too hard to solve, you just create additional variable to hold reference to pending request.

The next problem is if the request fails, you need to do that messy retry logic. But ok, a couple of more fields that capture number of retries that need to be cleaned up.

It would be great if program would wait for some time before firing that request to server, after all, we don't want to spam our servers in case somebody is in the process of fast typing something very long. Additional timer field maybe?

There is also a question of what needs to be shown on screen while that search is executing, and also what needs to be shown in case we fail even with all of the retries.

Writing all of this and properly testing it would be tedious. This is that same logic written with Rx.

```swift
  searchTextField.rx_text
    .throttle(0.3, MainScheduler.sharedInstance)
    .distinctUntilChanged()
    .flatMapLatest { query in
        API.getSearchResults(query)
            .retry(3)
            .startWith([]) // clears results on new search term
            .catchErrorJustReturn([])
    }
    .subscribeNext { results in
      // bind to ui
    }
```

There is no additional flags or fields required. Rx takes care of all that transient mess.

### Aggregating network requests

What if you need to fire two requests, and aggregate results when they have both finished?

Well, there is of course `zip` operator

```swift
  let userRequest: Observable<User> = API.getUser("me")
  let friendsRequest: Observable<Friends> = API.getFriends("me")

  zip(userRequest, friendsRequest) { user, friends in
      return (user, friends)
    }
    .subscribeNext { user, friends in
        // bind them to user interface
    }
```

So what if those APIs return results on a background thread, and binding has to happen on main UI thread? There is `observeOn`.

```swift
  let userRequest: Observable<User> = API.getUser("me")
  let friendsRequest: Observable<[Friend]> = API.getFriends("me")

  zip(userRequest, friendsRequest) { user, friends in
      return (user, friends)
    }
    .observeOn(MainScheduler.sharedInstance)
    .subscribeNext { user, friends in
        // bind them to user interface
    }
```

There are many more practical use cases where Rx really shines.

### Easy integration

And what if you need to create your own observable? It's pretty easy. This code is taken from RxCocoa and that's all you need to wrap HTTP requests with `NSURLSession`

```swift
extension NSURLSession {
    public func rx_response(request: NSURLRequest) -> Observable<(NSData!, NSURLResponse!)> {
        return create { observer in
            let task = self.dataTaskWithRequest(request) { (data, response, error) in
                if data == nil || response == nil {
                    observer.on(.Error(error ?? UnknownError))
                }
                else {
                    observer.on(.Next(data, response))
                    observer.on(.Completed)
                }
            }

            task.resume()

            return AnonymousDisposable {
                task.cancel()
            }
        }
    }
}
```

### Compositional disposal

Lets assume that there is a scenario where you want to display blurred images in a table view. The images should be first fetched from URL, then decoded and then blurred.

It would also be nice if that entire process could be cancelled if cell exists visible table view area because bandwidth and processor time for blurring are expensive.

It would also be nice if we didn't just immediately start to fetch image once the cell enters visible area because if user swipes really fast there could be a lot of requests fired and cancelled.

It would be also nice if we could limit the number of concurrent image operations because blurring images is an expensive operation.

This is how we can do it using Rx.

```swift

let imageSubscripton = imageURLs
    .throttle(0.2, MainScheduler.sharedInstance)
    .flatMap { imageURL in
        API.fetchImage(imageURL)
    }
    .observeOn(operationScheduler)
    .map { imageData in
        return decodeAndBlurImage(imageData)
    }
    .observeOn(MainScheduler.sharedInstance)
    .subscribeNext { blurredImage in
        imageView.image = blurredImage
    }
    .addDisposableTo(reuseDisposeBag)
```

This code will do all that, and when `imageSubscription` is disposed it will cancel all dependent async operations and make sure no rogue image is bound to UI.


### Delegates

Delegates can be used both as a hook for customizing behavior and as an observing mechanism.

Each usage has it's drawbacks, but Rx can help remedy some of the problem with using delegates as a observing mechanism.

Using delegates and optional methods to report changes can be problematic because there can be usually only one delegate registered, so there is no way to register multiple observers.

Also, delegates usually don't fire initial value upon invoking delegate setter, so you'll also need to read that initial value in some other way. That is kind of tedious.

RxCocoa not only provides wrappers for popular UIKit/Cocoa classes, but it also provides a generic mechanism called `DelegateProxy` that enables wrapping your own delegates and exposing them as observable sequences.

This is real code taken from `UISearchBar` integration.

It uses delegate as a notification mechanism to create an `Observable<String>` that immediately returns current search text upon subscription, and then emits changed search values.

```swift
extension UISearchBar {

    public var rx_delegate: DelegateProxy {
        return proxyForObject(self) as RxSearchBarDelegateProxy
    }

    public var rx_text: Observable<String> {
        return defer { [weak self] in
            let text = self?.text ?? ""

            return self?.rx_delegate.observe("searchBar:textDidChange:") ?? empty()
                    .map { a in
                        return a[1] as? String ?? ""
                    }
                    .startWith(text)
        }
    }
}
```

Definition of `RxSearchBarDelegateProxy` can be found [here](RxCocoa/iOS/Proxies/RxSearchBarDelegateProxy.swift)

This is how that API can be now used

```swift

searchBar.rx_text
    .subscribeNext { searchText in
        print("Current search text '\(searchText)'")
    }

```

### Notifications

Notifications enable registering multiple observers easily, but they are also untyped. Values need to be extracted from either `userInfo` or original target once they fire.

They are just a notification mechanism, and initial value usually has to be acquired in some other way.

That leads to this tedious pattern:

```swift
let initialText = object.text

doSomething(initialText)

// ....

func controlTextDidChange(notification: NSNotification) {
    doSomething(object.text)
}

```

You can use `rx_notification` to create an observable sequence with wanted properties in a similar fashion like `searchText` was constructed in delegate example, and thus reduce scattering of logic and duplication of code.

### KVO

KVO is a handy observing mechanism, but not without flaws. It's biggest flaw is confusing memory management.

In case of observing a property on some object, the object has to outlive the KVO observer registration otherwise your system will crash with an exception.

```
`TickTock` was deallocated while key value observers were still registered with it. Observation info was leaked, and may even become mistakenly attached to some other object.
```

There are some rules that you can follow when observing some object that is a direct descendant or ancestor in ownership chain, but if that relation is unknown, then it becomes tricky.

It also has a really awkward callback method that needs to be implemented

```objc
-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context
```

RxCocoa provides a really convenient observable sequence that solves those issues called [`rx_observe` and `rx_observeWeakly`](Documentation/GettingStarted.md#kvo)

This is how they can be used:

```swift
view.rx_observe("frame")
    .subscribeNext { (frame: CGRect?) in
        print("Got new frame \(frame)")
    }
```

or

```swift
someSuspiciousViewController.rx_observeWeakly("behavingOk")
    .subscribeNext { (behavingOk: Bool?) in
        print("Cats can purr? \(behavingOk)")
    }
```

### Benefits

In short using Rx will make your code:

* composable <- because Rx is composition's nick name
* reusable <- because it's composable
* declarative <- because definitions are immutable and only data changes
* understandable and concise <- raising level of abstraction and removing transient states
* stable <- because Rx code is thoroughly unit tested
* less stateful <- because you are modeling application as unidirectional data flows
* without leaks <- because resource management is easy

### It's not all or nothing

It is usually a good idea to model as much of your application as possible using Rx.

But what if you don't know all of the operators and does there even exist some operator that models your particular case?

Well, all of the Rx operators are based on math and should be intuitive.

The good news is that about 10-15 operators cover most typical use cases. And that list already includes some of the familiar ones like `map`, `filter`, `zip`, `observeOn` ...

There is a huge list of [all Rx operators](http://reactivex.io/documentation/operators.html) and list of all of the [currently supported RxSwift operators](Documentation/API.md).

For each operator there is [marble diagram](http://reactivex.io/documentation/operators/retry.html) that helps to explain how does it work.

But what if you need some operator that isn't on that list? Well, you can make your own operator.

What if creating that kind of operator is really hard for some reason, or you have some legacy stateful piece of code that you need to work with? Well, you've got yourself in a mess, but you can [jump out of Rx monad](Documentation/GettingStarted.md#life-happens) easily, process the data, and return back into it.

## Build / Install / Run

Rx doesn't contain any external dependencies.

These are currently supported options:

### Manual

Open Rx.xcworkspace, choose `RxExample` and hit run. This method will build everything and run sample app

### [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

**:warning: IMPORTANT! For tvOS support CocoaPods `0.39` is required. :warning:**

```
# Podfile
use_frameworks!

pod 'RxSwift', '~> 2.0.0-beta'
pod 'RxCocoa', '~> 2.0.0-beta'
pod 'RxBlocking', '~> 2.0.0-beta'
```

type in `Podfile` directory

```
$ pod install
```

### [Carthage](https://github.com/Carthage/Carthage)

**Xcode 7.1 required**

Add this to `Cartfile`

```
github "ReactiveX/RxSwift" "2.0.0-beta.3"
```

```
$ carthage update
```

### Manually using git submodules

* Add RxSwift as a submodule

```
$ git submodule add git@github.com:ReactiveX/RxSwift.git
```

* Drag `Rx.xcodeproj` into Project Navigator
* Go to `Project > Targets > Build Phases > Link Binary With Libraries`, click `+` and select `RxSwift-[Platform]` and `RxCocoa-[Platform]` targets

### iOS 7

iOS 7 is little tricky, but it can be done. The main problem is that iOS 7 doesn't support dynamic frameworks.

These are the steps to include RxSwift/RxCocoa projects in an iOS7 project

* RxSwift/RxCocoa projects have no external dependencies so just manually **including all of the `.swift`, `.m`, `.h` files** in build target should import all of the necessary source code.

You can either do that by copying the files manually or using git submodules.

`git submodule add git@github.com:ReactiveX/RxSwift.git`

After you've included files from `RxSwift` and `RxCocoa` directories, you'll need to remove files that are platform specific.

If you are compiling for **`iOS`**, please **remove references** to OSX specific files located in **`RxCocoa/OSX`**.

If you are compiling for **`OSX`**, please **remove references** to iOS specific files located in **`RxCocoa/iOS`**.

* Add **`RX_NO_MODULE`** as a custom Swift preprocessor flag

Go to your target's `Build Settings > Swift Compiler - Custom Flags` and add `-D RX_NO_MODULE`

* Include **`RxCocoa.h`** in your bridging header

If you already have a bridging header, adding `#import "RxCocoa.h"` should be sufficient.

If you don't have a bridging header, you can go to your target's `Build Settings > Swift Compiler - Code Generation > Objective-C Bridging Header` and point it to `[path to RxCocoa.h parent directory]/RxCocoa.h`.

## Feature comparison with other frameworks

|                                                           | Rx[Swift] |      ReactiveCocoa     | Bolts | PromiseKit |
|:---------------------------------------------------------:|:---------:|:----------------------:|:-----:|:----------:|
| Language                                                  |   swift   |       objc/swift       |  objc | objc/swift |
| Basic Concept                                             |  Sequence | Signal SignalProducer  |  Task |   Promise  |
| Cancellation                                              |     •     |            •           |   •   |      •     |
| Async operations                                          |     •     |            •           |   •   |      •     |
| map/filter/...                                            |     •     |            •           |   •   |            |
| cache invalidation                                        |     •     |            •           |       |            |
| cross platform                                            |     •     |                        |   •   |            |
| blocking operators for unit testing                       |     •     |                        |  N/A  |     N/A    |
| Lockless single sequence operators (map, filter, ...)     |     •     |                        |  N/A  |     N/A    |
| Unified hot and cold observables                          |     •     |                        |  N/A  |     N/A    |
| RefCount                                                  |     •     |                        |  N/A  |     N/A    |
| Concurrent schedulers                                     |     •     |                        |  N/A  |     N/A    |
| Generated optimized narity operators (combineLatest, zip) |     •     |                        |  N/A  |     N/A    |
| Reentrant operators                                       |     •     |                        |  N/A  |     N/A    |

** Comparison with RAC with respect to v3.0-RC.1

## Playgrounds

To use playgrounds:

* Open `Rx.xcworkspace`
* Build `RxSwift-OSX` scheme
* And then open `Rx` playground in `Rx.xcworkspace` tree view.
* Choose `View > Show Debug Area`

## RxExamples

To use playgrounds:

* Open `Rx.xcworkspace`
* Choose one of example schemes and hit `Run`.

## References

* [http://reactivex.io/](http://reactivex.io/)
* [Reactive Extensions GitHub (GitHub)](https://github.com/Reactive-Extensions)
* [Erik Meijer (Wikipedia)](http://en.wikipedia.org/wiki/Erik_Meijer_%28computer_scientist%29)
* [Expert to Expert: Brian Beckman and Erik Meijer - Inside the .NET Reactive Framework (Rx) (video)](https://youtu.be/looJcaeboBY)
* [Subject/Observer is Dual to Iterator (paper)](http://csl.stanford.edu/~christos/pldi2010.fit/meijer.duality.pdf)
* [Rx standard sequence operators visualized (visualization tool)](http://rxmarbles.com/)
* [Haskell](https://www.haskell.org/)
