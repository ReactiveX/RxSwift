Getting Started
===============

This project tries to be consistent with [ReactiveX.io](http://reactivex.io/). The general cross platform documentation and tutorials should also be valid in case of `RxSwift`.

1. [Observables aka Sequences](#observables-aka-sequences)
1. [Creating your own `Observable` (aka sequence producers)](#creating-your-own-observable-aka-sequence-producers)
1. [Operators](#operators)
1. [Error handling](#error-handling)
1. [Debugging](#debugging)
1. [UI layer tips](#ui-layer-tips)
1. [Examples](Examples.md)

# Observables aka Sequences

## Basics
This equivalence is the most important thing to understand.

Sequences are a simple concept.

Everybody is familiar with sequences. Lists/sequences are probably one of the first concepts mathematicians/programmers learn.

Here is a sequence of numbers


```
--1--2--3--4--5--6--| // it terminates normally
```

Here is another one with characters

```
--a--b--a--a--a---d---X // it terminates with error
```

Some sequences are finite, and some are infinite, like sequence of button taps

```
---tap-tap-------tap--->
```

These diagrams are called marble diagrams.

[http://rxmarbles.com/](http://rxmarbles.com/)

If everything is a sequence and every operation is just a transformation of input sequence into output sequence then it's pretty straightforward to compose operations.

The concept of sequences lifts a lot of cognitive overload. You stop worrying about asynchronous events and how to compose them and think in terms of synchronous operations over sequences.

People are creatures with huge visual cortexes. When you can visualize something easily, it's a lot easier to reason about it.

If we were to specify sequence grammar as regular expression it would look something like this

**Next* (Error | Completed)**

This describes the following:

* sequences can have 0 or more elements
* once `Error` or `Completed` event is received sequence can't produce any other element

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

The semantics of `Event` values is pretty natural. There is one for next element, for error event and completed event.

If you are curios [why `ErrorType` isn't generic](DesignRationale.md#why-error-type-isnt-generic).

`ObserverType` is equivalent to `(Event<Element>) -> Void`

So the only thing left on the table is `Disposable`.

```
protocol Disposable
{
    func dispose()
}
```

## Disposing

There is one additional way an observed sequence can terminate. When for some reason subscriber doesn't want to receive next elements of sequence and wants to release all of the resources that were allocated to compute those elements it just calls `dispose` method for his subscription.

Here is an example with `interval` operator. [Definition of `>-` operator is here](DesignRationale.md#pipe-operator)

```
let subscription = interval(0.3, scheduler)
            >- subscribeNext { n in
                println(n)
            }

NSThread.sleepForTimeInterval(2)

subscription.dispose()

```

This will print

```
0
1
2
3
4
5
```

One thing to note here is that you usually don't want to manually call `dispose` and this is only educational example. Calling dispose manually is usually bad code smell, and there are better ways to dispose subscriptions. You can either use `DisposeBag`, `ScopedDispose`, `takeUntil` operator or some other mechanism.

So can this code print something after `dispose` call executed? The answer is, it depends.

* If the `scheduler` is **serial scheduler** (`MainScheduler` is serial scheduler) and `dispose` is called on **on the same serial scheduler**, then the answer is **no**.

* If the `scheduler` is **different** from the thread where `dispose` was being called, then the answer is potentially **yes**.

The reason why that is the case has nothing to do with Rx. You simply could have two processes happening in parallel.

* one is producing elements
* other on is disposing subscription

A few more examples just to be sure (if you don't know what `observeOn` means, you can return to this part later).

In case you have something like:

```
let subscription = interval(0.3, scheduler)
            >- observeOn(MainScheduler.sharedInstance)
            >- subscribeNext { n in
                println(n)
            }

// ....

subscription.dispose() // called from main thread

```

**After `dispose` call returns, no element will be printed. That is a guarantee.**

Also in this case:

```
let subscription = interval(0.3, scheduler)
            >- observeOn(serialScheduler)
            >- subscribeNext { n in
                println(n)
            }

// ...

subscription.dispose() // executing on same `serialScheduler`

```

**After `dispose` call returns, no element will be printed. That is a guarantee.**

**Claims for `Next` event are also valid for `Error` and `Completed` events.**

## Creating your own `Observable` (aka sequence producers)

There is one crucial thing to understand about observables.

**When observable is created it doesn't perform any work just because it has been created. `Observable`s are just a description of how to generate sequences. Nothing more.**

It is true that `Observable` can generate elements in many ways. Some of them cause side effects and some of them register into existing running processes like tapping into mouse events, etc.

**But if you just call a method that returns an `Observable`, no sequence generation is performed, and there are no side effects. Sequence generation starts when `subscribe` method is called.**

E.g. Let's say you have a method with similar prototype:

```
func searchWikipedia(searchTerm: String) -> Observable<Results> {}
```

```
let searchForMe = searchWikipedia("me")

// no requests are performed, no work is being done, no URL requests were fired

let cancel = searchForMe
  // sequence generation starts now, URL requests are fired
  >- subscribeNext { results in
      println(results)
  }

```

There are a lot of ways how you can create your own `Observable` sequence. Probably the easiest is using `create` function.

Let's code a function that creates a sequence that immediately returns one element upon subscription. That function is called 'just'.

*This is the actual implementation*

```swift
func myJust<E>(element: E) -> Observable<E> {
    return create { observer in
        sendNext(observer, element)
        sendCompleted(observer)
        return NopDisposable.instance
    }
}

myJust(0)
    >- subscribeNext { n in
      print(n)
    }
```

this will print

```
0
```

Not bad. So what is `create` function? It's just a convenience method that enables you to easily implement `subscribe` method using Swift lambda function. Like `subscribe` method it takes one argument, `observer`, and returns disposable.

So what is `sendNext` function? It's just a convenient way of calling `observer.on(.Next(RxBox(element)))`. The same is valid for `sendCompleted(observer)`.

Since in this particular case sequence element generation can't be interrupted, singleton instance of `Disposable` that does nothing is returned.

Lets now create observable that returns elements from an array.

*This is the actual implementation*

```swift
func myFrom<E>(sequence: [E]) -> Observable<E> {
    return create { observer in
        for element in sequence {
            sendNext(observer, element)
        }

        sendCompleted(observer)
        return NopDisposable.instance
    }
}

let stringCounter = myFrom(["first", "second"])

println("Started ----")

// first time
stringCounter
    >- subscribeNext { n in
        println(n)
    }

println("----")

// again
stringCounter
    >- subscribeNext { n in
        println(n)
    }

println("Ended ----")
```

This will print

```
Started ----
first
second
----
first
second
Ended ----
```

## Creating observable (sequences) that perform work

Ok, now something more interesting. Let's create that `interval` operator that was used in previous examples.

*This is equivalent of actual implementation for dispatch queue schedulers*

```
func myInterval(interval: NSTimeInterval) -> Observable<Int> {
    return create { observer in
        println("Subscribed")
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        let timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue)

        var next = 0

        dispatch_source_set_timer(timer, 0, UInt64(interval * Double(NSEC_PER_SEC)), 0)
        let cancel = AnonymousDisposable {
            println("Disposed")
            dispatch_source_cancel(timer)
        }
        dispatch_source_set_event_handler(timer, {
            if cancel.disposed {
                return
            }
            sendNext(observer, next++)
        })
        dispatch_resume(timer)

        return cancel
    }
}
```

```swift
let counter = myInterval(0.1)

println("Started ----")

let subscription = counter
    >- subscribeNext { n in
       println(n)
    }

NSThread.sleepForTimeInterval(0.5)

subscription.dispose()

println("Ended ----")
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

println("Started ----")

let subscription1 = counter
    >- subscribeNext { n in
       println("First \(n)")
    }
let subscription2 = counter
    >- subscribeNext { n in
       println("Second \(n)")
    }

NSThread.sleepForTimeInterval(0.5)

subscription1.dispose()

NSThread.sleepForTimeInterval(0.5)

subscription2.dispose()

println("Ended ----")
```

this would print

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

**Every subscriber when subscribed generates it's own sequence of elements. Operators are stateless by default.**

## Sharing subscription, refCount and variable operator

But what if you want multiple observers to share one subscription?

There are two things that need to be defined.

* How to handle historical elements (replay latest only, replay all, replay last n)
* How to control when to subscribe to shared sequence (refCount, manual or some other algorithm)

The usual choice is a combination of `replay(1) >- refCount`.

```swift
let counter = myInterval(0.1)
    >- replay(1)
    >- refCount

println("Started ----")

let subscription1 = counter
    >- subscribeNext { n in
       println("First \(n)")
    }
let subscription2 = counter
    >- subscribeNext { n in
       println("Second \(n)")
    }

NSThread.sleepForTimeInterval(0.5)

subscription1.dispose()

NSThread.sleepForTimeInterval(0.5)

subscription2.dispose()

println("Ended ----")
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

This pattern of sharing subscriptions is so common in UI layer that it has it's own operator. Instead of writing `>- replay(1) >- refCount`, you can just write `>- variable`.

Behavior for URL observables is equivalent.

This is how HTTP requests are wrapped in Rx. It's pretty much the same pattern like the `interval` operator.

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

## Operators

There are numerous operators implemented in RxSwift. Complete list can be found [here](API.md).

Marble diagrams for all operators can be found on [ReactiveX.io](http://reactivex.io/)

Almost all operators are demonstrated in [Playgrounds](../Playgrounds).

To use playgrounds please open `Rx.xcworkspace`, build `RxSwift-OSX` scheme and then open playgrounds in `Rx.xcworkspace` tree view.

In case you need an operator, and don't know how to find it there a [decision tree of operators]() http://reactivex.io/documentation/operators.html#tree).

[Supported RxSwift operators](API.md#rxswift-supported-operators) are also grouped by function they perform, so that can also help.

### Custom operators

There are two ways how you can create custom operators.

#### Easy way

All of the internal code uses highly optimized versions of operators, so they aren't the best tutorial material. That's why it's highly encouraged to use standard operators.

Fortunately there is an easier way to create operators. Creating new operators is actually all about creating observables, and previous chapter already describes how to do that.

Lets see how an unoptimized map operator can be implemented.

```
func myMap<E, R>(transform: E -> R)(source: Observable<E>) -> Observable<R> {
    return create { observer in

        let subscription = source >- subscribe { e in
                switch e {
                case .Next(let boxedValue):
                    sendNext(observer, transform(boxedValue.value))
                case .Error(let error):
                    sendError(observer, error)
                case .Completed:
                    sendCompleted(observer)
                }
            }

        return subscription
    }
}
```

So now you can use your own map:

```
let subscription = myInterval(0.1)
    >- myMap { e in
        return "This is simply \(e)"
    }
    >- subscribeNext { n in
        println(n)
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

#### Harder, more performant way

You can perform the same optimizations like we have made and create more performant operators. That usually isn't necessary, but it ofc can be done.

Disclaimer: when taking this approach you are also taking a lot more responsibility when creating operators. You will need to make sure that sequence grammar is correct and be responsible of disposing subscriptions.

There are plenty of examples in RxSwift project how to do this. I would suggest talking a look at `map` or `filter` first.

Creating your own custom operators is tricky because you have to manually handle all of the chaos of error handling, asynchronous execution and disposal, but it's not rocket science either.

Every operator in Rx is just a factory for an observable. Returned observable usually contains information about source `Observable` and parameters that are needed to transform it.

In RxSwift code, almost all optimized `Observable`s have a common parent called `Producer`. Returned observable serves as a proxy between subscribers and source observable. It usually performs these things:

* on new subscription creates a sink that performs transformations
* registers that sink as observer to source observable
* on received events proxies transformed events to original observer

### Life happens

So what if it's just too hard to solve some cases with custom operators? You can exit the Rx monad, perform actions in imperative world, and then tunnel results to Rx again using `Subject`s.

This isn't something that should be practiced often, and is a bad code smell, but you can do it.

```swift
  let magicBeings: Observable<MagicBeing> = summonFromMiddleEarth()

  magicBeings
    >- subscribeNext { being in     // exit the Rx monad  
        self.doSomeStateMagic(being)
    }
    >- disposeBag.addDisposable

  //
  //  Mess
  //
  let kitten = globalParty(   // calculate something in messy world
    being,
    UIApplication.delegate.dataSomething.attendees
  )
  sendNext(kittens, kitten)   // send result back to rx
  //
  // Another mess
  //

  let kittens: Observable<Kitten> // again back in Rx monad

  kittens
    >- map { kitten in
      return kitten.purr()
    }
    // ....
```

Every time you do this, somebody will probably write this code somewhere

```swift
  kittens
    >- subscribeNext { kitten in
      // so something with kitten
    }
    >- disposeBag.addDisposable
```

so please try not to do this.

## Error handling

The are two error mechanisms.

### Anynchronous error handling mechanism in observables

Error handling is pretty straightforward. If one sequence terminates with error, then all of the dependent sequences will terminate with error. It's usual short circuit logic.

You can recover from failure of observable by using `catch` operator. There are various overloads that enable you to specify recovery in great detail.

There is also `retry` operator that enables retries in case of errored sequence.

### Synchronous error handling

Unfortunately Swift doesn't have a concept of exceptions or some kind of built in error monad so this project introduces `RxResult` enum.
It is Swift port of Scala [`Try`](http://www.scala-lang.org/api/2.10.2/index.html#scala.util.Try) type. It is also similar to Haskell [`Either`](https://hackage.haskell.org/package/category-extras-0.52.0/docs/Control-Monad-Either.html) monad.

**This will be replaced in Swift 2.0 with try/throws**

```swift
public enum RxResult<ResultType> {
    case Success(ResultType)
    case Error(ErrorType)
}
```

To enable writing more readable code, a few `Result` operators are introduced

```swift
result1.flatMap { okValue in        // success handling block
    // executed on success
    return ?
}.recoverWith { error in            // error handling block
    //  executed on error
    return ?
}
```

### Error handling and function names

For every group of transforming functions there are versions with and without "OrDie" suffix.

**This will change in 2.0 version and map will have two overloads, with and without `throws`.**

e.g.

```swift
public func mapOrDie<E, R>
    (selector: E -> RxResult<R>)
    -> (Observable<E> -> Observable<R>) {
    return { source in
        return selectOrDie(selector)(source)
    }
}

public func map<E, R>
    (selector: E -> R)
        -> (Observable<E> -> Observable<R>) {
    return { source in
        return select(selector)(source)
    }
}
```

Returning an error from a selector will cause entire graph of dependent sequence transformers to "die" and fail with error. Dying implies that it will release all of its resources and never produce another sequence value. This is usually not an obvious effect.

If there is some `UITextField` bound to a observable sequence that fails with error or completes, screen won't be updated ever again.

To make those situations more obvious, RxCocoa debug build will throw an exception in case some sequence that is bound to UI control terminates with an error.

Using functions without "OrDie" suffix is usually a more safe option.

There is also the `catch` operator for easier error handling.

## Debugging

Using debugger alone is useful, but you can also use `>- debug`. `debug` operator will print out all events to standard output and you can add also label those events.

`debug` acts like a probe. Here is an example of using it:

```swift
let subscription = myInterval(0.1)
    >- debug("my probe")
    >- map { e in
        return "This is simply \(e)"
    }
    >- subscribeNext { n in
        println(n)
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

You can also use `subscribe` instead of `subscribeNext`

```
NSURLSession.sharedSession().rx_JSON(request)
   >- map { json in
       return parse()
   }
   >- subscribe { n in      // this subscribes on all events including error and completed
       println(n)
   }
```

## Variables

`Variable`s represent some observable state. `Variable` without containing value can't exist because initializer requires initial value.

Variable is a [`Subject`](http://reactivex.io/documentation/subject.html). More specifically a `BehaviorSubject`. The reason why `BehaviorSubject` as `Variable` alias is just for convenience.

`Variable` is both an `ObserverType` and `Observable`.

That means that you can send values to variables using `sendNext` and it will broadcast element to all subscribers.

It will also broadcast it's current value immediately on subscription.

```swift
let variable = Variable(0)

println("Before first subscription ---")

variable
    >- subscribeNext { n in
        println("First \(n)")
    }

println("Before send 1")

sendNext(variable, 1)

println("Before second subscription ---")

variable
    >- subscribeNext { n in
        println("Second \(n)")
    }

sendNext(variable, 2)

println("End ---")
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
```

There is also `>- variable` operator. `>- variable` operator is already described [here](#sharing-subscription-refcount-and-variable-operator).

So why are they both called variable?

For one, they both have internal state that all subscribers share.
When they contain value (and `Variable` always contains it), they broadcast it immediately to subscribers.

The difference is that `Variable` enables you to manually choose elements of a sequence by using `sendNext`, and you can think of `>- variable` as a kind calculated "variable".

## UI layer tips

There are certain things that your `Observable`s need to satisfy in the UI layer when binding to UIKit controls.

* They need to observe values on `MainScheduler`(UIThread). That's just a normal UIKit/Cocoa property. It is usually a good idea that you APIs return results on `MainScheduler`. In case that doesn't happen, RxCocoa will throw an exception to inform you of that and crash the app.

To fix this you need to add `>- observeOn(MainScheduler.sharedInstance)`.

**NSURLSession extensions don't return result on `MainScheduler` by default.**

* You can't bind errors to UIKit controls because that makes no sense.

It you don't know if `Observable` can fail, you can ensure it can't fail using `>-catch(valueThatIsReturnedWhenErrorHappens)`

* You usually want to share subscription

Lets say you have something like this:

```
let searchResults = searchText
    >- throttle(0.3, $.mainScheduler)
    >- distinctUntilChanged
    >- map { query in
        API.getSearchResults(query)
            >- retry(3)
            >- startWith([]) // clears results on new search term
            >- catch([])
    }
    >- switchLatest
    >- variable              // <- notice the variable
```

What you usually want is to share search results once calculated. That is what `>- variable` means.

**It is usually a good rule of thumb in the UI layer to add `>- variable` at the end of transformation chain because you really want to share calculated results, and not fire separate HTTP connections when binding `searchResults` to multiple UI elements.**

*Additional information about `>- variable` can be found [here](#sharing-subscription-refcount-and-variable-operator)*
