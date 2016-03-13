Getting Started
===============

This project tries to be consistent with [ReactiveX.io](http://reactivex.io/). The general cross platform documentation and tutorials should also be valid in case of `RxSwift`.

1. [Observables aka Sequences](#observables-aka-sequences)
1. [Disposing](#disposing)
1. [Implicit `Observable` guarantees](#implicit-observable-guarantees)
1. [Creating your first `Observable` (aka observable sequence)](#creating-your-own-observable-aka-observable-sequence)
1. [Creating an `Observable` that performs work](#creating-an-observable-that-performs-work)
1. [Sharing subscription and `shareReplay` operator](#sharing-subscription-and-sharereplay-operator)
1. [Operators](#operators)
1. [Playgrounds](#playgrounds)
1. [Custom operators](#custom-operators)
1. [Error handling](#error-handling)
1. [Debugging Compile Errors](#debugging-compile-errors)
1. [Debugging](#debugging)
1. [Debugging memory leaks](#debugging-memory-leaks)
1. [KVO](#kvo)
1. [UI layer tips](#ui-layer-tips)
1. [Making HTTP requests](#making-http-requests)
1. [RxDataSources](#rxdatasources)
1. [Driver](Units.md#driver-unit)
1. [Examples](Examples.md)

# Observables aka Sequences

## Basics
The [Equivalence](MathBehindRx.md) of observer patterns (`Observable<Element>`) and sequences (`Generator`s)
is one of the most important things to understand about Rx.

The observer pattern is needed because we want to model asynchronous behavior.
That equivalence enables the implementation of high level sequence operations as operators on `Observable`s.

Sequences are a simple, familiar concept that is **easy to visualize**.

People are creatures with huge visual cortexes. When we can visualize a concept easily, it's a lot easier to reason about it.

We can lift a lot of the cognitive load from trying to simulate event state machines inside every Rx operator onto high level operations over sequences.

If we don't use Rx but model asynchronous systems, that probably means that our code is full of state machines and transient states that we need to simulate instead of abstracting away.

Lists and sequences are probably one of the first concepts mathematicians and programmers learn.

Here is a sequence of numbers:


```
--1--2--3--4--5--6--| // terminates normally
```

Another sequence, with characters:

```
--a--b--a--a--a---d---X // terminates with error
```

Some sequences are finite and others are infinite, like a sequence of button taps:

```
---tap-tap-------tap--->
```

These are called marble diagrams. There are more marble diagrams at [rxmarbles.com](http://rxmarbles.com).

If we were to specify sequence grammar as a regular expression it would look like:

**Next* (Error | Completed)?**

This describes the following:

* **Sequences can have 0 or more elements.**
* **Once an `Error` or `Completed` event is received, the sequence cannot produce any other element.**

Sequences in Rx are described by a push interface (aka callback).

```swift
enum Event<Element>  {
    case Next(Element)      // next element of a sequence
    case Error(ErrorType)   // sequence failed with error
    case Completed          // sequence terminated successfully
}

class Observable<Element> {
    func subscribe(observer: Observer<Element>) -> Disposable
}

protocol ObserverType {
    func on(event: Event<Element>)
}
```

**When a sequence sends the `Complete` or `Error` event all internal resources that compute sequence elements will be freed.**

**To cancel production of sequence elements and free resources immediately, call `dispose` on the returned subscription.**

If a sequence terminates in finite time, not calling `dispose` or not using `addDisposableTo(disposeBag)` won't cause any permanent resource leaks. However, those resources will be used until the sequence completes, either by finishing production of elements or returning an error.

If a sequence does not terminate in some way, resources will be allocated permanently unless `dispose` is called manually, automatically inside of a `disposeBag`, `takeUntil` or in some other way.

**Using dispose bags or `takeUntil` operator is a robust way of making sure resources are cleaned up. We recommend using them in production even if the sequences will terminate in finite time.**

In case you are curious why `ErrorType` isn't generic, you can find explanation [here](DesignRationale.md#why-error-type-isnt-generic).

## Disposing

There is one additional way an observed sequence can terminate. When we are done with a sequence and we want to release all of the resources allocated to compute the upcoming elements, we can call `dispose` on a subscription.

Here is an example with the `interval` operator.

```swift
let subscription = Observable<Int>.interval(0.3, scheduler: scheduler)
    .subscribe { event in
        print(event)
    }

NSThread.sleepForTimeInterval(2)

subscription.dispose()

```

This will print:

```
0
1
2
3
4
5
```

Note the you usually do not want to manually call `dispose`; this is only educational example. Calling dispose manually is usually a bad code smell. There are better ways to dispose subscriptions. We can use `DisposeBag`, the `takeUntil` operator, or some other mechanism.

So can this code print something after the `dispose` call executed? The answer is: it depends.

* If the `scheduler` is a **serial scheduler** (ex. `MainScheduler`) and `dispose` is called on **on the same serial scheduler**, the answer is **no**.

* Otherwise it is **yes**.

You can find out more about schedulers [here](Schedulers.md).

You simply have two processes happening in parallel.

* one is producing elements
* the other is disposing the subscription

The question "Can something be printed after?" does not even make sense in the case that those processes are on different schedulers.

A few more examples just to be sure (`observeOn` is explained [here](Schedulers.md)).

In case we have something like:

```swift
let subscription = Observable<Int>.interval(0.3, scheduler: scheduler)
            .observeOn(MainScheduler.instance)
            .subscribe { event in
                print(event)
            }

// ....

subscription.dispose() // called from main thread

```

**After the `dispose` call returns, nothing will be printed. That is guaranteed.**

Also, in this case:

```swift
let subscription = Observable<Int>.interval(0.3, scheduler: scheduler)
            .observeOn(serialScheduler)
            .subscribe { event in
                print(event)
            }

// ...

subscription.dispose() // executing on same `serialScheduler`

```

**After the `dispose` call returns, nothing will be printed. That is guaranteed.**

### Dispose Bags

Dispose bags are used to return ARC like behavior to RX.

When a `DisposeBag` is deallocated, it will call `dispose` on each of the added disposables.

It does not have a `dispose` method and therefore does not allow calling explicit dispose on purpose. If immediate cleanup is required, we can just create a new bag.

```swift
  self.disposeBag = DisposeBag()
```

This will clear old references and cause disposal of resources.

If that explicit manual disposal is still wanted, use `CompositeDisposable`. **It has the wanted behavior but once that `dispose` method is called, it will immediately dispose any newly added disposable.**

### Take until

Additional way to automatically dispose subscription on dealloc is to use `takeUntil` operator.

```swift
sequence
    .takeUntil(self.rx_deallocated)
    .subscribe {
        print($0)
    }
```

## Implicit `Observable` guarantees

There is also a couple of additional guarantees that all sequence producers (`Observable`s) must honor.

It doesn't matter on which thread they produce elements, but if they generate one element and send it to the observer `observer.on(.Next(nextElement))`, they can't send next element until `observer.on` method has finished execution.

Producers also cannot send terminating `.Completed` or `.Error` in case `.Next` event hasn't finished.

In short, consider this example:

```swift
someObservable
  .subscribe { (e: Event<Element>) in
      print("Event processing started")
      // processing
      print("Event processing ended")
  }
```

this will always print:

```
Event processing started
Event processing ended
Event processing started
Event processing ended
Event processing started
Event processing ended
```

it can never print:

```
Event processing started
Event processing started
Event processing ended
Event processing ended
```

## Creating your own `Observable` (aka observable sequence)

There is one crucial thing to understand about observables.

**When an observable is created, it doesn't perform any work simply because it has been created.**

It is true that `Observable` can generate elements in many ways. Some of them cause side effects and some of them tap into existing running processes like tapping into mouse events, etc.

**But if you just call a method that returns an `Observable`, no sequence generation is performed, and there are no side effects. `Observable` is just a definition how the sequence is generated and what parameters are used for element generation. Sequence generation starts when `subscribe` method is called.**

E.g. Let's say you have a method with similar prototype:

```swift
func searchWikipedia(searchTerm: String) -> Observable<Results> {}
```

```swift
let searchForMe = searchWikipedia("me")

// no requests are performed, no work is being done, no URL requests were fired

let cancel = searchForMe
  // sequence generation starts now, URL requests are fired
  .subscribeNext { results in
      print(results)
  }

```

There are a lot of ways how you can create your own `Observable` sequence. Probably the easiest way is using `create` function.

Let's create a function which creates a sequence that returns one element upon subscription. That function is called 'just'.

*This is the actual implementation*

```swift
func myJust<E>(element: E) -> Observable<E> {
    return Observable.create { observer in
        observer.on(.Next(element))
        observer.on(.Completed)
        return NopDisposable.instance
    }
}

myJust(0)
    .subscribeNext { n in
      print(n)
    }
```

this will print:

```
0
```

Not bad. So what is the `create` function?

It's just a convenience method that enables you to easily implement `subscribe` method using Swift closures. Like `subscribe` method it takes one argument, `observer`, and returns disposable.

Sequence implemented this way is actually synchronous. It will generate elements and terminate before `subscribe` call returns disposable representing subscription. Because of that it doesn't really matter what disposable it returns, process of generating elements can't be interrupted.

When generating synchronous sequences, the usual disposable to return is singleton instance of `NopDisposable`.

Lets now create an observable that returns elements from an array.

*This is the actual implementation*

```swift
func myFrom<E>(sequence: [E]) -> Observable<E> {
    return Observable.create { observer in
        for element in sequence {
            observer.on(.Next(element))
        }

        observer.on(.Completed)
        return NopDisposable.instance
    }
}

let stringCounter = myFrom(["first", "second"])

print("Started ----")

// first time
stringCounter
    .subscribeNext { n in
        print(n)
    }

print("----")

// again
stringCounter
    .subscribeNext { n in
        print(n)
    }

print("Ended ----")
```

This will print:

```
Started ----
first
second
----
first
second
Ended ----
```

## Creating an `Observable` that performs work

Ok, now something more interesting. Let's create that `interval` operator that was used in previous examples.

*This is equivalent of actual implementation for dispatch queue schedulers*

```swift
func myInterval(interval: NSTimeInterval) -> Observable<Int> {
    return Observable.create { observer in
        print("Subscribed")
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        let timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue)

        var next = 0

        dispatch_source_set_timer(timer, 0, UInt64(interval * Double(NSEC_PER_SEC)), 0)
        let cancel = AnonymousDisposable {
            print("Disposed")
            dispatch_source_cancel(timer)
        }
        dispatch_source_set_event_handler(timer, {
            if cancel.disposed {
                return
            }
            observer.on(.Next(next))
            next += 1
        })
        dispatch_resume(timer)

        return cancel
    }
}
```

```swift
let counter = myInterval(0.1)

print("Started ----")

let subscription = counter
    .subscribeNext { n in
       print(n)
    }

NSThread.sleepForTimeInterval(0.5)

subscription.dispose()

print("Ended ----")
```

This will print
```
Started ----
Subscribed
0
1
2
3
4
Disposed
Ended ----
```

What if you would write

```swift
let counter = myInterval(0.1)

print("Started ----")

let subscription1 = counter
    .subscribeNext { n in
       print("First \(n)")
    }
let subscription2 = counter
    .subscribeNext { n in
       print("Second \(n)")
    }

NSThread.sleepForTimeInterval(0.5)

subscription1.dispose()

NSThread.sleepForTimeInterval(0.5)

subscription2.dispose()

print("Ended ----")
```

this would print:

```
Started ----
Subscribed
Subscribed
First 0
Second 0
First 1
Second 1
First 2
Second 2
First 3
Second 3
First 4
Second 4
Disposed
Second 5
Second 6
Second 7
Second 8
Second 9
Disposed
Ended ----
```

**Every subscriber upon subscription usually generates it's own separate sequence of elements. Operators are stateless by default. There are vastly more stateless operators than stateful ones.**

## Sharing subscription and `shareReplay` operator

But what if you want that multiple observers share events (elements) from only one subscription?

There are two things that need to be defined.

* How to handle past elements that have been received before the new subscriber was interested in observing them (replay latest only, replay all, replay last n)
* How to decide when to fire that shared subscription (refCount, manual or some other algorithm)

The usual choice is a combination of `replay(1).refCount()` aka `shareReplay()`.

```swift
let counter = myInterval(0.1)
    .shareReplay(1)

print("Started ----")

let subscription1 = counter
    .subscribeNext { n in
       print("First \(n)")
    }
let subscription2 = counter
    .subscribeNext { n in
       print("Second \(n)")
    }

NSThread.sleepForTimeInterval(0.5)

subscription1.dispose()

NSThread.sleepForTimeInterval(0.5)

subscription2.dispose()

print("Ended ----")
```

this will print

```
Started ----
Subscribed
First 0
Second 0
First 1
Second 1
First 2
Second 2
First 3
Second 3
First 4
Second 4
First 5
Second 5
Second 6
Second 7
Second 8
Second 9
Disposed
Ended ----
```

Notice how now there is only one `Subscribed` and `Disposed` event.

Behavior for URL observables is equivalent.

This is how HTTP requests are wrapped in Rx. It's pretty much the same pattern like the `interval` operator.

```swift
extension NSURLSession {
    public func rx_response(request: NSURLRequest) -> Observable<(NSData, NSURLResponse)> {
        return Observable.create { observer in
            let task = self.dataTaskWithRequest(request) { (data, response, error) in
                guard let response = response, data = data else {
                    observer.on(.Error(error ?? RxCocoaURLError.Unknown))
                    return
                }

                guard let httpResponse = response as? NSHTTPURLResponse else {
                    observer.on(.Error(RxCocoaURLError.NonHTTPResponse(response: response)))
                    return
                }

                observer.on(.Next(data, httpResponse))
                observer.on(.Completed)
            }

            task.resume()

            return AnonymousDisposable {
                task.cancel()
            }
        }
    }
}
```

## Operators

There are numerous operators implemented in RxSwift. The complete list can be found [here](API.md).

Marble diagrams for all operators can be found on [ReactiveX.io](http://reactivex.io/)

Almost all operators are demonstrated in [Playgrounds](../Rx.playground).

To use playgrounds please open `Rx.xcworkspace`, build `RxSwift-OSX` scheme and then open playgrounds in `Rx.xcworkspace` tree view.

In case you need an operator, and don't know how to find it there a [decision tree of operators]() http://reactivex.io/documentation/operators.html#tree).

[Supported RxSwift operators](API.md#rxswift-supported-operators) are also grouped by function they perform, so that can also help.

### Custom operators

There are two ways how you can create custom operators.

#### Easy way

All of the internal code uses highly optimized versions of operators, so they aren't the best tutorial material. That's why it's highly encouraged to use standard operators.

Fortunately there is an easier way to create operators. Creating new operators is actually all about creating observables, and previous chapter already describes how to do that.

Lets see how an unoptimized map operator can be implemented.

```swift
extension ObservableType {
    func myMap<R>(transform: E -> R) -> Observable<R> {
        return Observable.create { observer in
            let subscription = self.subscribe { e in
                    switch e {
                    case .Next(let value):
                        let result = transform(value)
                        observer.on(.Next(result))
                    case .Error(let error):
                        observer.on(.Error(error))
                    case .Completed:
                        observer.on(.Completed)
                    }
                }

            return subscription
        }
    }
}
```

So now you can use your own map:

```swift
let subscription = myInterval(0.1)
    .myMap { e in
        return "This is simply \(e)"
    }
    .subscribeNext { n in
        print(n)
    }
```

and this will print

```
Subscribed
This is simply 0
This is simply 1
This is simply 2
This is simply 3
This is simply 4
This is simply 5
This is simply 6
This is simply 7
This is simply 8
...
```

### Life happens

So what if it's just too hard to solve some cases with custom operators? You can exit the Rx monad, perform actions in imperative world, and then tunnel results to Rx again using `Subject`s.

This isn't something that should be practiced often, and is a bad code smell, but you can do it.

```swift
  let magicBeings: Observable<MagicBeing> = summonFromMiddleEarth()

  magicBeings
    .subscribeNext { being in     // exit the Rx monad  
        self.doSomeStateMagic(being)
    }
    .addDisposableTo(disposeBag)

  //
  //  Mess
  //
  let kitten = globalParty(   // calculate something in messy world
    being,
    UIApplication.delegate.dataSomething.attendees
  )
  kittens.on(.Next(kitten))   // send result back to rx
  //
  // Another mess
  //

  let kittens = Variable(firstKitten) // again back in Rx monad

  kittens.asObservable()
    .map { kitten in
      return kitten.purr()
    }
    // ....
```

Every time you do this, somebody will probably write this code somewhere

```swift
  kittens
    .subscribeNext { kitten in
      // so something with kitten
    }
    .addDisposableTo(disposeBag)
```

so please try not to do this.

## Playgrounds

If you are unsure how exactly some of the operators work, [playgrounds](../Rx.playground) contain almost all of the operators already prepared with small examples that illustrate their behavior.

**To use playgrounds please open Rx.xcworkspace, build RxSwift-OSX scheme and then open playgrounds in Rx.xcworkspace tree view.**

**To view the results of the examples in the playgrounds, please open the `Assistant Editor`. You can open `Assistant Editor` by clicking on `View > Assistant Editor > Show Assistant Editor`**

## Error handling

The are two error mechanisms.

### Asynchronous error handling mechanism in observables

Error handling is pretty straightforward. If one sequence terminates with error, then all of the dependent sequences will terminate with error. It's usual short circuit logic.

You can recover from failure of observable by using `catch` operator. There are various overloads that enable you to specify recovery in great detail.

There is also `retry` operator that enables retries in case of errored sequence.

## Debugging Compile Errors

When writing elegant RxSwift/RxCocoa code, you are probably relying heavily on compiler to deduce types of `Observable`s. This is one of the reasons why Swift is awesome, but it can also be frustrating sometimes.

```swift
images = word
    .filter { $0.containsString("important") }
    .flatMap { word in
        return self.api.loadFlickrFeed("karate")
            .catchError { error in
                return just(JSON(1))
            }
      }
```

If compiler reports that there is an error somewhere in this expression, I would suggest first annotating return types.

```swift
images = word
    .filter { s -> Bool in s.containsString("important") }
    .flatMap { word -> Observable<JSON> in
        return self.api.loadFlickrFeed("karate")
            .catchError { error -> Observable<JSON> in
                return just(JSON(1))
            }
      }
```

If that doesn't work, you can continue adding more type annotations until you've localized the error.

```swift
images = word
    .filter { (s: String) -> Bool in s.containsString("important") }
    .flatMap { (word: String) -> Observable<JSON> in
        return self.api.loadFlickrFeed("karate")
            .catchError { (error: NSError) -> Observable<JSON> in
                return just(JSON(1))
            }
      }
```

**I would suggest first annotating return types and arguments of closures.**

Usually after you have fixed the error, you can remove the type annotations to clean up your code again.

## Debugging

Using debugger alone is useful, but usually using `debug` operator will be more efficient. `debug` operator will print out all events to standard output and you can add also label those events.

`debug` acts like a probe. Here is an example of using it:

```swift
let subscription = myInterval(0.1)
    .debug("my probe")
    .map { e in
        return "This is simply \(e)"
    }
    .subscribeNext { n in
        print(n)
    }

NSThread.sleepForTimeInterval(0.5)

subscription.dispose()
```

will print

```
[my probe] subscribed
Subscribed
[my probe] -> Event Next(Box(0))
This is simply 0
[my probe] -> Event Next(Box(1))
This is simply 1
[my probe] -> Event Next(Box(2))
This is simply 2
[my probe] -> Event Next(Box(3))
This is simply 3
[my probe] -> Event Next(Box(4))
This is simply 4
[my probe] dispose
Disposed
```

You can also easily create your version of the `debug` operator.

```swift
extension ObservableType {
    public func myDebug(identifier: String) -> Observable<Self.E> {
        return Observable.create { observer in
            print("subscribed \(identifier)")
            let subscription = self.subscribe { e in
                print("event \(identifier)  \(e)")
                switch e {
                case .Next(let value):
                    observer.on(.Next(value))

                case .Error(let error):
                    observer.on(.Error(error))

                case .Completed:
                    observer.on(.Completed)
                }
            }
            return AnonymousDisposable {
                   print("disposing \(identifier)")
                   subscription.dispose()
            }
        }
    }
 }
 ```

## Debugging memory leaks

In debug mode Rx tracks all allocated resources in a global variable `resourceCount`.

In case you want to have some resource leak detection logic, the simplest method is just printing out `RxSwift.resourceCount` periodically to output.

```swift
    /* add somewhere in
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    */
    _ = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
        .subscribeNext { _ in
        print("Resource count \(RxSwift.resourceCount)")
    }
```

Most efficient way to test for memory leaks is:
* navigate to your screen and use it
* navigate back
* observe initial resource count
* navigate second time to your screen and use it
* navigate back
* observe final resource count

In case there is a difference in resource count between initial and final resource counts, there might be a memory
leak somewhere.

The reason why 2 navigations are suggested is because first navigation forces loading of lazy resources.

## Variables

`Variable`s represent some observable state. `Variable` without containing value can't exist because initializer requires initial value.

Variable wraps a [`Subject`](http://reactivex.io/documentation/subject.html). More specifically it is a `BehaviorSubject`.  Unlike `BehaviorSubject`, it only exposes `value` interface, so variable can never terminate or fail.

It will also broadcast it's current value immediately on subscription.

After variable is deallocated, it will complete the observable sequence returned from `.asObservable()`.

```swift
let variable = Variable(0)

print("Before first subscription ---")

_ = variable.asObservable()
    .subscribe(onNext: { n in
        print("First \(n)")
    }, onCompleted: {
        print("Completed 1")
    })

print("Before send 1")

variable.value = 1

print("Before second subscription ---")

_ = variable.asObservable()
    .subscribe(onNext: { n in
        print("Second \(n)")
    }, onCompleted: {
        print("Completed 2")
    })

variable.value = 2

print("End ---")
```

will print

```
Before first subscription ---
First 0
Before send 1
First 1
Before second subscription ---
Second 1
First 2
Second 2
End ---
Completed 1
Completed 2
```

## KVO

KVO is an Objective-C mechanism. That means that it wasn't built with type safety in mind. This project tries to solve some of the problems.

There are two built in ways this library supports KVO.

```swift
// KVO
extension NSObject {
    public func rx_observe<E>(type: E.Type, _ keyPath: String, options: NSKeyValueObservingOptions, retainSelf: Bool = true) -> Observable<E?> {}
}

#if !DISABLE_SWIZZLING
// KVO
extension NSObject {
    public func rx_observeWeakly<E>(type: E.Type, _ keyPath: String, options: NSKeyValueObservingOptions) -> Observable<E?> {}
}
#endif
```

Example how to observe frame of `UIView`.

**WARNING: UIKit isn't KVO compliant, but this will work.**

```swift
view
  .rx_observe(CGRect.self, "frame")
  .subscribeNext { frame in
    ...
  }
```

or

```swift
view
  .rx_observeWeakly(CGRect.self, "frame")
  .subscribeNext { frame in
    ...
  }
```

### `rx_observe`

`rx_observe` is more performant because it's just a simple wrapper around KVO mechanism, but it has more limited usage scenarios

* it can be used to observe paths starting from `self` or from ancestors in ownership graph (`retainSelf = false`)
* it can be used to observe paths starting from descendants in ownership graph (`retainSelf = true`)
* the paths have to consist only of `strong` properties, otherwise you are risking crashing the system by not unregistering KVO observer before dealloc.

E.g.

```swift
self.rx_observe(CGRect.self, "view.frame", retainSelf: false)
```

### `rx_observeWeakly`

`rx_observeWeakly` has somewhat slower than `rx_observe` because it has to handle object deallocation in case of weak references.

It can be used in all cases where `rx_observe` can be used and additionally

* because it won't retain observed target, it can be used to observe arbitrary object graph whose ownership relation is unknown
* it can be used to observe `weak` properties

E.g.

```swift
someSuspiciousViewController.rx_observeWeakly(Bool.self, "behavingOk")
```

### Observing structs

KVO is an Objective-C mechanism so it relies heavily on `NSValue`.

**RxCocoa has built in support for KVO observing of `CGRect`, `CGSize` and `CGPoint` structs.**

When observing some other structures it is necessary to extract those structures from `NSValue` manually.

[Here](../RxCocoa/Common/KVORepresentable+CoreGraphics.swift) are examples how to extend KVO observing mechanism and `rx_observe*` methods for other structs by implementing `KVORepresentable` protocol.

## UI layer tips

There are certain things that your `Observable`s need to satisfy in the UI layer when binding to UIKit controls.

### Threading

`Observable`s need to send values on `MainScheduler`(UIThread). That's just a normal UIKit/Cocoa requirement.

It is usually a good idea for you APIs to return results on `MainScheduler`. In case you try to bind something to UI from background thread, in **Debug** build RxCocoa will usually throw an exception to inform you of that.

To fix this you need to add `observeOn(MainScheduler.instance)`.

**NSURLSession extensions don't return result on `MainScheduler` by default.**

### Errors

You can't bind failure to UIKit controls because that is undefined behavior.

If you don't know if `Observable` can fail, you can ensure it can't fail using `catchErrorJustReturn(valueThatIsReturnedWhenErrorHappens)`, **but after an error happens the underlying sequence will still complete**.

If the wanted behavior is for underlying sequence to continue producing elements, some version of `retry` operator is needed.

### Sharing subscription

You usually want to share subscription in the UI layer. You don't want to make separate HTTP calls to bind the same data to multiple UI elements.

Let's say you have something like this:

```swift
let searchResults = searchText
    .throttle(0.3, $.mainScheduler)
    .distinctUntilChanged
    .flatMapLatest { query in
        API.getSearchResults(query)
            .retry(3)
            .startWith([]) // clears results on new search term
            .catchErrorJustReturn([])
    }
    .shareReplay(1)              // <- notice the `shareReplay` operator
```

What you usually want is to share search results once calculated. That is what `shareReplay` means.

**It is usually a good rule of thumb in the UI layer to add `shareReplay` at the end of transformation chain because you really want to share calculated results. You don't want to fire separate HTTP connections when binding `searchResults` to multiple UI elements.**

**Also take a look at `Driver` unit. It is designed to transparently wrap those `shareReply` calls, make sure elements are observed on main UI thread and that no error can be bound to UI.**

## Making HTTP requests

Making http requests is one of the first things people try.

You first need to build `NSURLRequest` object that represents the work that needs to be done.

Request determines is it a GET request, or a POST request, what is the request body, query parameters ...

This is how you can create a simple GET request

```swift
let request = NSURLRequest(URL: NSURL(string: "http://en.wikipedia.org/w/api.php?action=parse&page=Pizza&format=json")!)
```

If you want to just execute that request outside of composition with other observables, this is what needs to be done.

```swift
let responseJSON = NSURLSession.sharedSession().rx_JSON(request)

// no requests will be performed up to this point
// `responseJSON` is just a description how to fetch the response

let cancelRequest = responseJSON
    // this will fire the request
    .subscribeNext { json in
        print(json)
    }

NSThread.sleepForTimeInterval(3)

// if you want to cancel request after 3 seconds have passed just call
cancelRequest.dispose()

```

**NSURLSession extensions don't return result on `MainScheduler` by default.**

In case you want a more low level access to response, you can use:

```swift
NSURLSession.sharedSession().rx_response(myNSURLRequest)
    .debug("my request") // this will print out information to console
    .flatMap { (data: NSData!, response: NSURLResponse!) -> Observable<String> in
        if let response = response as? NSHTTPURLResponse {
            if 200 ..< 300 ~= response.statusCode {
                return just(transform(data))
            }
            else {
                return failWith(yourNSError)
            }
        }
        else {
            rxFatalError("response = nil")
            return failWith(yourNSError)
        }
    }
    .subscribe { event in
        print(event) // if error happened, this will also print out error to console
    }
```
### Logging HTTP traffic

In debug mode RxCocoa will log all HTTP request to console by default. In case you want to change that behavior, please set `Logging.URLRequests` filter.

```swift
// read your own configuration
public struct Logging {
    public typealias LogURLRequest = (NSURLRequest) -> Bool

    public static var URLRequests: LogURLRequest =  { _ in
    #if DEBUG
        return true
    #else
        return false
    #endif
    }
}
```

## RxDataSources

... is a set of classes that implement fully functional reactive data sources for `UITableView`s and `UICollectionView`s.

RxDataSources are bundled [here](https://github.com/RxSwiftCommunity/RxDataSources).

Fully functional demonstration how to use them is included in the [RxExample](../RxExample) project.
