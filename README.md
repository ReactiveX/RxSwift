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
├-RxExample       - example apps: UI bindings example, Wikipedia search example ...
└-Rx.xcworkspace  - workspace that contains all of the projects hooked up
```		

This is a Swift port of Reactive extensions.

[https://github.com/Reactive-Extensions/Rx.NET](https://github.com/Reactive-Extensions/Rx.NET)

Like the original Rx, its intention is to enable easy composition of asynchronous operations and event streams.

It tries to port as many concepts from the original Rx as possible, but some concepts were adapted for more pleasant and performant integration with iOS/OSX environment.

1. [Introduction](#introduction)
1. [Build / Install / Run](#build--install--run)
1. [Comparison with ReactiveCocoa](#comparison-with-reactivecocoa)
1. [Feature comparison with other frameworks](#feature-comparison-with-other-frameworks)
1. [What problem does Rx solve?](#what-problem-does-rx-solve)
1. [Sequences solve everything](#sequences-solve-everything)
1. [Duality between Observer and Iterator / Enumerator / Generator / Sequences](#duality-between-observer-and-iterator--enumerator--generator--sequences)
1. [Base classes / interfaces](#base-classes--interfaces)
1. [Supported operators](#supported-operators)
1. [Hot and cold observables](#hot-and-cold-observables)
1. [Error Handling](#error-handling)
1. [Naming conventions and best practices](#naming-conventions-and-best-practices)
1. [Peculiarities](#peculiarities)
1. [References](#references)

## Introduction

Probably the best analogy for those who have never heard of Rx would be:


```
git diff | grep bug | less          #  linux pipes - programs communicate by sending
                                    #  sequences of bytes, words, lines, '\0' terminated strings...
```

would become if written in RxSwift

```swift
gitDiff() >- grep("bug") >- less    // rx sink (>-) operator - rx units communicate by sending
                                    // sequences of swift objects
```

Rx is modular and simple.
Integrating it comes down to just `import RxSwit`. 

```swift
let a /*: Observable<Int>*/ = Variable(1)
let b /*: Observable<Int>*/ = Variable(2)

// immediately prints: 3 is positive
combineLatest(a, b) { $0 + $1 } 
	>- filter { $0 >= 0 } 
	>- map { "\($0) is positive" }
	>- subscribeNext { println($0) }

a << -3 // doesn't print anything
b << 5 	// prints: 2 is positive
```

Something more interesting:
* bind text field value
* calculate is number prime using async API
* bind results to label

```swift
let subscription/*: Disposable */ = primeTextField.rx_text()
            >- map { WolframAlphaIsPrime($0.toInt() ?? 0) }
            >- concat
            >- map { "number \($0.n) is prime? \($0.isPrime)" }
            >- resultLabel.rx_subscribeTextTo
        
// this will set resultLabel.text! == "number 43 is prime? true"
primeTextField.text = "43"

// ...

// to unbind everything, just call
subscription.dispose()
```

Some more complex UI async validation logic with progress notifications.
All operations are cancelled the moment `disposeBag.dispose()` is called.


```swift
// bind UI control values directly
self.usernameOutlet.rx_text() >- map { username in

    // synchronous validation, nothing special here
    if count(username) == 0 {
        // convenience for constructing synchronous result
        return returnElement((valid: false, message: "Username can't be empty."))
    }

    ...

    let loadingValue = (valid: nil, message: "Checking availability ...")

    // asynchronous validation is not a problem
    // this will fire a server call to check does username exist
    return API.usernameAvailable(username) >- map { available in
        if available {
            return (true, "Username available")
        }
        else {
            return (false, "Username already taken")
        }
    }
    // use `loadingValue` until server responds
        >- prefixWith(loadingValue)
}
// use only latest data
// automatically cancels async validation on next `username` value
    >- switchLatest
// bind result to UI
    >- subscribeNext { valid in
        errorLabel.textColor = validationColor(valid)
        errorLabel.text = valid.message
    }
// automatic cleanup on dealloc
    >- disposeBag.addDisposable
```

Can't get any simpler then this.

## Build / Install / Run

Rx doesn't contain any external dependencies.

These are currently supported options:

* Open Rx.xcworkspace, choose `RxExample` and hit run. This method will build everything and run sample app
* [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html) (probably easiest for dependency management). This method will install frameworks without example app

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

## Comparison with ReactiveCocoa

So what happened, why did this project start? Two things happened:

* Almost a year ago, Apple announced Swift. That caused a torrent of new projects in the Apple ecosystem. 
* I've started to learn Haskell and listen more carefully to Erik Meijer

About the same time, ReactiveCocoa team also soon started to investigate how to incorporate Swift into ReactiveCocoa. 
Initially, ReactiveCocoa was hugely influenced by Reactive Extensions but it was also influenced by other languages. It was in kind of a gray zone, similar, but different. 

Since ReactiveCocoa was influenced hugely by Rx, I wanted to know more about the original Rx. 

I was totally blown away by Rx. It solved everything that was causing me problems in an elegant way (threading, resource management, error management, cache invalidation).

The most subtle thing that lifted a lot of cognitive load was changing the concept from signals to sequences.  It maybe looks like a trivial thing, but it has profound implications.

* It's hard to define properties of signals, but we all already know properties of sequences. (It's funny, but I don't think that ReactiveCocoa team references anywhere signal as a sequence even though they use terms like "streams of values"). 
* operator definitions become more clear, stateless by default
* resources management becomes clear, no more confusing situations what gets cancelled
* interfaces get a lot simpler, it's all about two interfaces, `Observable<Element>` and `Observer<Element>` (ReactiveCocoa v3.0-beta.1 also introduces a very significant SignalProducer)

E.g. 
```swift
returnElements(1, 2) 
	>- observeOn(operationQueueScheduler) 
	>- map { "n = \($0)" }
	>- observeOn(MainScheduler.sharedInstance) 
	>- subscribeNext { println($0) }
```

If we are talking in terms of sequences, there is no doubt that this code will print:

```
n = 1
n = 2
```

If we are talking in terms of signals, it's not clear can this code produce 

```
n = 2
n = 1
```

Since 

* ReactiveCocoa team has done an amazing job in mapping some of the APIs from Rx to Cocoa
* Rx was open source
* I wanted to learn Swift

this project got started.

## Feature comparison with other frameworks

|                                                               | Rx[Swift] |       ReactiveCocoa      | Bolts | PromiseKit |
|---------------------------------------------------------------|:---------:|:------------------------:|:-----:|:----------:|
| Language                                                      |   swift   |        objc/swift        |  objc | objc/swift |
| Basic Concept                                                 |  Sequence |  Signal / SignalProducer |  Task |   Promise  |
| Cancellation                                                  |     •     |             •            |   •   |      •     |
| Async operations                                              |     •     |             •            |   •   |      •     |
| map/filter/...                                                |     •     |             •            |   •   |            |
| cache invalidation                                            |     •     |             •            |       |            |
| cross platform                                                |     •     |                          |   •   |            |
| Unified [hot and cold observables](#hot-and-cold-observables) |     •     |                          |       |            |



## What problem does Rx solve?

Writing correct asynchronous or event driven programs is hard because every line of code has to deal with following concerns:

* Resource management (disposal of memory allocations, sockets, file handles)
* State management (invalidating caches)
* Asynchronous operations (composition, cancellation, deadlocks)
* Error handling

Thinking about those concerns over and over again is tedious and error prone experience. Rx provides a level of abstraction that hides all of that complexity and makes writing performant and correct programs easy.

It provides default implementations of most common units/operations of async programs and enables easy bridging of existing imperative APIs in a couple of lines of code.

In the context of Rx, data is modeled as sequence of objects. That includes:

* Asynchronous operations
* UI actions
* Observing of property changes
* ...

It is also pretty straightforward to create custom sequence operations.

## Sequences solve everything

Sequences are a simple concept.

Everybody is familiar with sequences. Lists/sequences are probably one of the first concepts mathematicians/programmers learn.
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

If everything is a sequence and every operation is just a transformation of input sequence into output sequence then it's pretty straightforward to compose operations.

Asynchronous or time delayed operations don't cause any problems because Rx sequences are enumerated by registering observers and are not enumerated synchronously. This can be viewed as a form of "lazy evaluation". Next elements are only accessed by registering a callback that gets called each time new element is produced. Since elements are already accessed asynchronously, that means that Rx sequences can abstract asynchronous operations. [Duality section](#duality-between-observer-and-iterator--enumerator--generator--sequences) contains further references.

Resource management is also pretty natural. Sequence can release element computation resources once the observer has unsubscribed from receiving next elements. If no observer is waiting for next element to arrive, then there isn't a need to waste resources computing next elements. Of course, it's possible to implement other resource management logic.

The way sequences are used in Rx is reminiscent to physics because to obtain experiment results one must somehow first observe the experiment.

## Duality between Observer and Iterator / Enumerator / Generator / Sequences

There is a duality between observer and generator pattern. They both describe sequences. Since sequences in Rx are implemented through observer pattern it is important to understand this duality.

In short, there are two basic ways elements of a sequence can be accessed.

* Push interface - Observer
* Pull interface - Iterator / Enumerator / Generator

To learn more about this, these videos should help

* [Erik Meijer on Rx and duality (video)](http://channel9.msdn.com/Events/Lang-NEXT/Lang-NEXT-2014/Keynote-Duality)
* [Subject/Observer is Dual to Iterator (paper)](http://csl.stanford.edu/~christos/pldi2010.fit/meijer.duality.pdf)
* [Erik Meijer on Rx and duality 2 (video)](http://channel9.msdn.com/Shows/Going+Deep/Expert-to-Expert-Brian-Beckman-and-Erik-Meijer-Inside-the-NET-Reactive-Framework-Rx)

## Base classes / interfaces

`throttle`, `distinctUntilChanged`, `switchLatest` ... are just normal functions that take `Observable<InputElement>` as input and return `Observable<OutputElement>` as output. `>-` is a sink operator that feeds `lhs` value to `rhs` function.

```
func >- <In, Out>(source: In, transform: In -> Out) -> Out {
    return transform(source)
}
```

This is actually a general purpose operator and it can be used outside the concept of `Observable<Element>` and sequences.

Sequences usually don't actually exist in memory. It is just an abstraction. Sequences of elements of type `Element` are represented by a corresponding `Observable<Element>`. Every time some element is observed it implicitly becomes next element in observed sequence of values. Even though the sequence of elements is implicit, that doesn't make it any less useful.

```
class Observable<Element> {
    func subscribe(observer: Observer<Element>) -> Disposable
}
```

To observe elements of a sequence `Observer<Element>` needs to subscribe with `Observable<Element>`.

* Every time next element of a sequence is produced `Observable<Element>` with send a `Next(Element)` notification to `Observer<Element>`.

* If sequence computation ended prematurely because of an error `Observable<Element>` with send an `Error(ErrorType)` notification to `Observer<Element>`. Computation resources have been released and this is the last message that observer will receive for that subscription.

* If sequence end was computed `Observable<Element>` will send a `Completed` notification to `Observer<Element>`. Computation resources have been released and this is the last message observer will receive for that subscription.

This means that sequence can only finish with `Completed` or `Error` message and after that no further messages will be received for that subscription.


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

## Supported operators

These operators are currently supported. Creating new operators is also pretty straightforward. Operators are by default stateless.

* map (select)
* filter (where)
* foldl (aggregate)
* multicast
* publish
* replay
* refCount
* observeSingleOn
* generation operators (returnElement, empty, never, failWith, defer)
* debug
* concat
* merge
* switchLatest
* catch
* asObservable
* distinctUntilChanged
* do
* throttle
* sample

## Hot and cold observables

There are two basic types of observables. In Rx both are represented by `Observable<Element>`.

| Hot observables                                                                                         | Cold observables                                                              |
|---------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------|
| ... are sequences                                                                                       | ... sequences                                                                 |
| Use resources ("produce heat") no matter is there any observer subscribed.                              | Don't use resources (don't produce heat) until observer subscribes.           |
| Variables / properties / constants, tap coordinates, mouse coordinates, UI control values, current time | Async operations, HTTP Connections, TCP connections, streams                  |
| Usually contain ~ N elements                                                                            | Usually contain ~ 1 element                                                   |
| Sequence elements are produced no matter is there any observer subscribed.                              | Sequence elements are produced if there is a subscribed observer.             |
| Sequence computation resources are usually shared between all of the subscribed observers.              | Sequence computation resources are usually allocated per subscribed observer. |
| Usually stateful                                                                                        | Usually stateless                                                             |


## Error handling

Error handling is pretty straightforward. If one sequence terminates with error, then all of the dependent sequences will terminate with error. It's usual short circuit logic.

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

If some action needs to be performed only after a successful computation without using its result then `>>>` is used.

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

Returning an error from a selector will cause entire graph of dependent sequence transformers to "die" and fail with error. Dying implies that it will release all of its resources and never produce another sequence value. This is usually not an obvious effect.

If there is some UITextField bound to a observable sequence that fails with error or completes, screen won't be updated ever again. 

To make those situations more obvious, RxCocoa debug build will throw an exception in case some sequence that is bound to UI control terminates with an error.

Using functions without "OrDie" suffix is usually more safe option.

There is also `catch` operator for easier error handling.

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

## References

* [Reactive Extensions GitHub (GitHub)](https://github.com/Reactive-Extensions)
* [Erik Meijer (Wikipedia)](http://en.wikipedia.org/wiki/Erik_Meijer_%28computer_scientist%29)
* [Reactive Extensions (MSDN entry)](http://msdn.microsoft.com/en-us/library/hh242985.aspx)
* [Reactive Cocoa (GitHub)](https://github.com/ReactiveCocoa/ReactiveCocoa)
* [Erik Meijer on Rx and duality (video)](http://channel9.msdn.com/Events/Lang-NEXT/Lang-NEXT-2014/Keynote-Duality)
* [Subject/Observer is Dual to Iterator (paper)](http://csl.stanford.edu/~christos/pldi2010.fit/meijer.duality.pdf)
* [Erik Meijer on Rx and duality 2 (video)](http://channel9.msdn.com/Shows/Going+Deep/Expert-to-Expert-Brian-Beckman-and-Erik-Meijer-Inside-the-NET-Reactive-Framework-Rx)
* [The Future Of ReactiveCocoa by Justin Spahr-Summers (video)](https://www.youtube.com/watch?v=ICNjRS2X8WM)
* [Rx standard sequence operators visualized (visualization tool)](http://rxmarbles.com/)
* [Haskell](https://www.haskell.org/)
