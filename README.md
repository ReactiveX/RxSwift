<img src="assets/Rx_Logo_M.png" width="36" height="36"> RxSwift: ReactiveX for Swift
======================================

Xcode 6.3 / Swift 1.2 required

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
1. [Getting started](Documentation/GettingStarted.md)
1. [Examples](Documentation/Examples.md)
1. [API - RxSwift operators / RxCocoa extensions](Documentation/API.md)
1. [Build / Install / Run](#build--install--run)
1. [Math behind](Documentation/MathBehindRx.md)
1. [Hot and cold observables](Documentation/HotAndColdObservables.md)
1. [Feature comparison with other frameworks](#feature-comparison-with-other-frameworks)
1. [Roadmap](https://github.com/kzaher/RxSwift/wiki/roadmap)
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

[Definition of `>-` operator is here](Documentation/DesignRationale.md#pipe-operator)

```swift
combineLatest(firstName.rx_text, lastName.rx_text) { $0 + " " + $1 }
            >- map { "Greeting \($0)" }
            >- subscribeNext { greeting in
                greetingLabel.text = greeting
            }
```

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
    >- retry(3)
```

You can also easily create custom retry operators.

### Transient state

There is also a lot of problems with transient state when writing async programs. Typical example is autocomplete search box.

If you were to write the autocomplete code without Rx, first problem that probably needs to be solved is when `c` in `abc` is typed, and there is a pending request for `ab`, pending request gets cancelled. Ok, that shouldn't be too hard to solve, you just create additional variable to hold reference to pending request.

The next problem is if the request fails, you need to do that messy retry logic. But ok, a couple of more fields that capture number of retries that need to be cleaned up.

It would be great if program would wait for some time before firing that request to server, after all, we don't want to spam our servers. Additional field timer maybe?

There is also a question of what needs to be shown on screen while that search is executing, and also what needs to be shown in case we fail even with all of the retries.

Writing all of this and properly testing it would be tedious. This is that same logic written with Rx.

```swift
  searchTextField.rx_text
    >- throttle(0.3, MainScheduler.sharedInstance)
    >- distinctUntilChanged
    >- map { query in
        API.getSearchResults(query)
            >- retry(3)
            >- startWith([]) // clears results on new search term
            >- catch([])
    }
    >- switchLatest
    >- map { results in
      // bind to ui
    }
```

There is no additional flags or fields required. Rx takes care of all that transient mess.

### Other use cases

But what if you need to fire two requests, and aggregate results when they have both finished?

Well, there is of course `zip` operator

```swift
  let userRequest: Observable<User> = API.getUser("me")
  let friendsRequest: Observable<Friends> = API.getFriends("me")

  zip(userRequest, friendsRequest) { user, friends in
      return (user, friends)
    }
    >- subscribeNext { user, friends in
        // bind them to user interface
    }
```

So what if those API return results on a background thread, and binding has to happen on main UI thread? There is `observeOn`.

```swift
  let userRequest: Observable<User> = API.getUser("me")
  let friendsRequest: Observable<[Friend]> = API.getFriends("me")

  zip(userRequest, friendsRequest) { user, friends in
      return (user, friends)
    }
    >- observeOn(MainScheduler.sharedInstance)
    >- subscribeNext { user, friends in
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
                    sendError(observer, error ?? UnknownError)
                }
                else {
                    sendNext(observer, (data, response))
                    sendCompleted(observer)
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

It would be also nice if we could limit the number of concurrent image operations because blurring images is expensive operation.

This is how we can do it using Rx.

```swift
let imageSubscripton = just(imageURL)
    >- throttle(0.2, MainScheduler.sharedInstance)
    >- flatMap { imageURL in
        API.fetchImage(imageURL)
    }
    >- observeOn(operationScheduler)
    >- map { imageData in
        return decodeAndBlurImage(imageData)
    }
    >- observeOn(MainScheduler.sharedInstance)
    >- subscribeNext { blurredImage in
        imageView.image = blurredImage
    }

//

override func prepareForReuse() {
    imageSubscripton.dispose()
}
```

This code will do all that, and when `imageSubscription` is disposed it will cancel all dependent async operations and make sure no rogue image is bound to UI.

### Benefits

In short, the parts where you use Rx will be:

* composable <- because Rx is built for composition
* reusable <- because it's composable
* declarative <- because definitions are immutable and handle different state in a same way
* understandable and concise <- because you are raising level of abstraction
* stable <- because Rx code is thoroughly unit tested, and handles transient states
* less statefull <- because you are modeling application as unidirectional data flows
* without leaks <- because resource management is easy

### It's not all or nothing

It is usually a good idea to model as much of your application as possible using Rx.

But what if you don't know all of the operators and does there even exist some operator that models your particular case. Well, all of the Rx operators are based on math and should be intuitive.

The good news is that about 10-15 operators cover most typical use cases. And that list already includes some of the familiar ones like `map`, `filter`, `zip`, `observeOn` ...

There is a huge list of [all Rx operators](http://reactivex.io/documentation/operators.html) and list of all of the [currently supported RxSwift operators](Documentation/API.md).

For each operator there is [marble diagram](http://reactivex.io/documentation/operators/retry.html) that helps to explain how does it work.

But what if you need some operator that isn't on that list? Well, you can make your own operator.

What if creating that kind of operator is really hard for some reason, or you have some legacy stateful that you need to work with? Well, you've got yourself in a mess, but you can [jump out of Rx monad](Documentation/GettingStarted.md#life-happens) easily, process the data, and return back into it.

## Build / Install / Run

Rx doesn't contain any external dependencies.

These are currently supported options:

### Manual

Open Rx.xcworkspace, choose `RxExample` and hit run. This method will build everything and run sample app

### [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

```
# Podfile
use_frameworks!

pod 'RxSwift'
pod 'RxCocoa'
```

type in `Podfile` directory

```
$ pod install
```

### [Carthage](https://github.com/Carthage/Carthage)

It's little tricky, but possible. Carthage still has troubles resolving multiple targets inside same repository (https://github.com/Carthage/Carthage/issues/395).

This is the workaround:

```
git "git@github.com:kzaher/RxSwift.git" "latest-carthage/rxswift"
git "git@github.com:kzaher/RxSwift.git" "latest-carthage/rxcocoa"
```

Unfortunatelly, you can update only one target at a time beecause Carthage doesn't know how to resolve them properly. You'll probably need to do something like:

```
git "git@github.com:kzaher/RxSwift.git" "latest-carthage/rxswift"
#git "git@github.com:kzaher/RxSwift.git" "latest-carthage/rxcocoa"
```

```bash
carthage update
```

```
#git "git@github.com:kzaher/RxSwift.git" "latest-carthage/rxswift"
git "git@github.com:kzaher/RxSwift.git" "latest-carthage/rxcocoa"
```

```bash
carthage update
```

### iOS 7

iOS 7 is little tricky, but it can be done. The main problem is that iOS 7 doesn't support dynamic frameworks.

RxSwift/RxCocoa projects have no external dependencies so it should come down to just manually including all of the `.swift`, `.m`, `.h` files in build target.

**If you are including `RxCocoa` project you should also find replace `import RxSwift` with `` because now you aren't using modules.**

Is someone knows a smarter way to do this, please share.

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

## References

* [http://reactivex.io/](http://reactivex.io/)
* [Reactive Extensions GitHub (GitHub)](https://github.com/Reactive-Extensions)
* [Erik Meijer (Wikipedia)](http://en.wikipedia.org/wiki/Erik_Meijer_%28computer_scientist%29)
* [Expert to Expert: Brian Beckman and Erik Meijer - Inside the .NET Reactive Framework (Rx) (video)](https://youtu.be/looJcaeboBY)
* [Subject/Observer is Dual to Iterator (paper)](http://csl.stanford.edu/~christos/pldi2010.fit/meijer.duality.pdf)
* [Rx standard sequence operators visualized (visualization tool)](http://rxmarbles.com/)
* [Haskell](https://www.haskell.org/)
