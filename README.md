RxSwift: Reactive extensions for Swift
======================================

Xcode 6.3 / Swift 1.2 required


```
RxSwift
|
├-LICENSE.md
├-README.md
├-RxSwift         - platform agnostic core
├-RxCocoa         - extensions for UI (iOS only for now), NSURLSession, KVO ...
├-RxExample       - example app, Wikipedia image scraper
└-Rx.xcworkspace  - workspace that contains all of the projects hooked up
```		

This is a Swift port of Reactive extensions.

[https://github.com/Reactive-Extensions/Rx.NET](https://github.com/Reactive-Extensions/Rx.NET)

Like the original Rx, its intention is to enable easy composition of asynchronous operations and event streams.

It tries to port as many concepts from the original Rx as possible, but some concepts were adapted for more pleasant and performant integration with iOS/OSX environment.

Probably the best analogy for those who have never heard of Rx would be:


```
git diff | grep bug | less          #  linux pipes - programs communicate by sending
                                    #  sequences of bytes, words, lines, '\0' terminated strings...
```

would become if written in RxSwift

```
gitDiff() >- grep("bug") >- less    // rx sink (>-) operator - rx units communicate by sending
                                    // sequences of swift objects
```

Rx is implemented as a slightly modified version of observer pattern.

[http://en.wikipedia.org/wiki/Observer_pattern](http://en.wikipedia.org/wiki/Observer_pattern)

It probably sounds little weird at first, but those abstractions are equivalent. Following paragraphs explain that in more detail.

## But first, why would somebody want to use Rx?

Writing correct asynchronous programs is hard because every line of code has to deal with following concerns:

* Resource management (disposal of memory allocations, sockets, file handles)
* Asynchronous operations (composition, cancellation, deadlocks)
* Error handling

Thinking about those concerns over and over again is tedious and error prone experience. Rx provides a level of abstraction that hides all of that complexity and makes writing performant and correct programs easy.

It provides default implementations of most common units/operations of async programs and enables easy bridging of existing imperative APIs in a couple of lines of code.

In the context of Rx, data is modeled as "lazy evaluated" sequence of swift objects. That includes:

* Asynchronous operations
* UI actions
* Observing of property changes
* ...

It is also pretty straightforward to create custom sequence transformers.

## What's so special about sequences? 

Everybody is familiar with sequences. Lists/sequences are probably one of the first concepts programmers learn.
They are easy to visualize and easy to reason about.

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

## How do sequences solve anything? 

If everything is a sequence, and every operation is just a transformation of input sequence into output sequence then it's pretty straightforward to compose operations.

Asynchronous or time delayed operations don't cause any problems because elements of Rx sequences are accessed by registering observers and are not enumerated immediatelly. This can be viewed as a "lazy evaluation" implementation technique.

Resource management is also pretty natural. Sequence can release element computation resources once the observer has unsubscribed from receiving next elements. If no observer is waiting for next element to arrive, then it doesn't make sense to waste resources computing next elements. Of course, it's possible to implement other resource management logic.

## Example

This is Rx code taken from Rx example app inside repository. Example app transforms Wikipedia into a image search engine. It scrapes wikipedia pages for image URLs, and displayes all of the images in search results.

```swift
results =   searchText >- throttle(300, $.mainScheduler) 
            >- distinctUntilChanged >- map { query in
                API.getSearchResults(query)
            } 
            >- switchLatest >- map { results in
                convertResults(results)
            }
```

On a conceptual level, this is the explanation of applied transformations:

* throttle - after new search value arrives, wait for 300 ms, if meanwhile new value is received, wait for another 300 ms
* distinctUntilChanged - if received value is different then the last one, forward it, otherwise don't send anything
* map - transforms sequence of search queries into a sequence of asynchronous URL requests
* switchLatest - if a new search request arrives and old request hasn't finished, old request is cancelled and new search request starts
* map - transforms a sequence of search results into view models suitable for user interface ingestion

That code alone won't actually start any request to server. It will only create a "template" of transformations that will be performed once somebody starts to observe results of that expression.

To start search requests, somebody needs to call something equivalent to. 

```
// starts listening for search results
subscription =  results >- subscribeNext { results in               
                    println("Here are search results \(results)")
                }
sleep(10)
// stops listening for search results
subscription.dispose()                                              
```

So ...

## How does that work?

`throttle`, `distinctUntilChanged`, `switchLatest` ... are just normal functions that take `Observable<InputElement>` as input and return `Observable<OutputElement>` as output. `>-` is a sink operator that feeds `lhs` value to `rhs` function.

```
func >- <In, Out>(source: In, transform: In -> Out) -> Out {
    return transform(source)
}
```
This is actually a general purpose operator and it can be used outside the concept of `Observable<Element>` and sequences.

Sequences usually don't actually exist in memory. It is just an abstraction. Sequences of elements of type `Element` are represented by a corresponding `Observable<Element>`. Every time some element is observed it implicitly becomes next element in observed sequence of values. Even though the sequence of elements is implicit, that doesn't make it any less usefull.

```
class Observable<Element> {
    func subscribe(observer: Observer<Element>) -> Disposable
}
```

To observe elements of a sequence `Observer<Element>` needs to subscribe to `Observable<Element>`. Every time next element of a sequence is produced, sequence terminates or fails with error, `Observable<Element>` with fire a notification to `Observer<Element>`.

```
enum Event<Element>  {
    case Next(Element)      // next element of a sequence
    case Error(ErrorType)   // sequence failed with error
    case Completed          // sequence terminated successfully
}

protocol ObserverType {
    func on(event: Event<Element>)
}

```

When `Observer<Element>` wants to unsubscribe notifications from `Observable<Element>` it needs to call `dispose` on `Disposable` it received while subscribing.

```
protocol Disposable
{
    func dispose()
}
```

## Error handling

Error handling is pretty straightforward. If one sequence terminates with error, then all of the dependant sequences will terminate with error. It's usual short circuit logic.

Swift doesn't have a concept of exceptions so this project introduces `Result` enum.
_(Haskell [`Either`](https://hackage.haskell.org/package/category-extras-0.52.0/docs/Control-Monad-Either.html) monad)_

```
public enum Result<ResultType> {
    case Success(ResultType)
    case Error(ErrorType)
}
```

To enable writing more readable code, a few `Result` operators are introduced

```
result1 >== { okValue in    // success chaining operator
    // executed on success
    return ?
} >>! { error in            // error chaining operator
    //  executed on error
    return ?
} 
```

If some action needs to be peformed only after a successfull computation without using its result then `>>>` is used.

```
result1 >>> {              
    // executed on success
    return ?
}
```

_`>==` and `>>>` were chosen because they are the closest sequence of characters to standard monadic bind `>>=` and `>>` function.
`>>!` was chosen because `!` is easily associated with error._

## Naming conventions and best practices

For every group of transforming functions there are versions with and without "OrDie" suffix.

e.g.

```
public func mapOrDie<E, R>
    (selector: E -> Result<R>)
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

Returning an error from a selector will cause entire graph of dependant sequence transformers to "die" and fail with error. Dying implies that it will release all of its resources and never produce another sequence value. This is usually not an obvious effect.

If there is some UITextField bound to a observable sequence that fails with error or completes, screen won't be updated ever again. 

To make those situations more obvious, RxCocoa will throw an exception in case some sequence that is bound to UI control terminates with an error.

Using functions without "OrDie" suffix is usually a preferred option.

Best practice would be to use `Result` enum as a `Element` type in observable sequence. This is how example app works. In that way, errors can be safely propagated to UI and observing sequences will continue to produce values in case of some transient server error.

## Build / Install / Run

These are the supported options

* Open Rx.xcworkspace, hit run. This method will build everything and you can run sample app
* [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html) (probably easiest for dependancy management). This method will install frameworks without example app

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

## Peculiarities

* Swift support for generic enums is limited. That's why there is `Box` hack in `Result` and `Event` enums
``` 
unimplemented IR generation feature non-fixed multi-payload enum layout
```
* Swift compiler had troubles with curried functions in release mode
```
// These two functions are equivalent, although second option is more readable IMHO

public func map<E, R>  // this is ok
    (selector: E -> R)
        -> (Observable<E> -> Observable<R>) {
    return { source in
        return select(selector)(source)
    }
}

public func map<E, R>           // this will cause crashes in release version 
    (selector: E -> R)          // of your program if >- operator is used
    (source: Observable<E>)
        -> Observable<R> {
    return select(selector)(source)
}
```
