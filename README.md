RxSwift: Reactive extensions for Swift
======================================

Xcode 6.3 / Swift 1.2 required

This is a Swift port of [Microsoft Reactive Extensions](https://github.com/Reactive-Extensions/Rx.NET).

Like the original Rx, its intention is to enable easy composition of asynchronous operations and event/data streams.

In the context of Rx, KVO observing, async operations and streams are all unified under [abstraction of sequence](#sequences-solve-everything). This is the reason why Rx is a simple, powerful and elegant.

It tries to port as many concepts from the original Rx as possible, but some concepts were adapted for more pleasant and performant integration with iOS/OSX environment.

```
RxSwift
|
├-LICENSE.md
├-README.md
├-RxSwift         - platform agnostic core
├-RxCocoa         - extensions for UI, NSURLSession, KVO ...
├-RxExample       - example apps: UI bindings example, Wikipedia search example ...
└-Rx.xcworkspace  - workspace that contains all of the projects hooked up
```		

1. [Introduction](#introduction)
1. [RxSwift supported operators](#rxswift-supported-operators)
1. [RxCocoa extensions](#rxcocoa-extensions)
1. [Build / Install / Run](#build--install--run)
1. [Comparison with ReactiveCocoa](#comparison-with-reactivecocoa)
1. [Feature comparison with other frameworks](#feature-comparison-with-other-frameworks)
1. [What problem does Rx solve?](#what-problem-does-rx-solve)
1. [Sequences solve everything](#sequences-solve-everything)
1. [Duality between Observer and Iterator / Enumerator / Generator / Sequences](#duality-between-observer-and-iterator--enumerator--generator--sequences)
1. [Base classes / interfaces](#base-classes--interfaces)
1. [Hot and cold observables](#hot-and-cold-observables)
1. [Error Handling](#error-handling)
1. [Naming conventions and best practices](#naming-conventions-and-best-practices)
1. [Pipe operator >- vs |> vs ...](#pipe-operator---vs--vs-)
1. [Roadmap](wiki/roadmap)
1. [Peculiarities](#peculiarities)
1. [References](#references)

Using RxSwift in some cool project? [Let us know](mailto:krunoslav.zaher@gmail.com?subject=[RxSwift] Doing something cool)

## Introduction

If this is your first contact with Rx, please take a look at these [step by step explanations of examples](Documentation/GettingStarted.md). [References section](#references) also contains plenty of useful information for beginners.

Probably the best analogy for those who have never heard of Rx would be:


```bash
git diff | grep bug | less          #  linux pipes - programs communicate by sending
                                    #  sequences of bytes, words, lines, ...
```

would become if written in RxSwift

```swift
gitDiff() >- grep("bug") >- less    // rx pipe `>-` operator - rx units communicate by 
                                    // sending sequences of swift objects
                                    // unfortunately `|` is reserved in swift 
                                    // for logical or
```

This is the definition of `>-` operator

```swift
func >- <In, Out>(lhs: In, rhs: In -> Out) -> Out {
    return rhs(lhs)
}
```
More practical explanation

```
a >- b >- c equals c(b(a))
```

`>-` is left associative function application. In the presented example it doesn't transform values, it transforms operations, but the principle is the same. If you are wondering is it really that simple, yes, you can check out the [source code](RxSwift/RxSwift/Rx.swift).

Here is an example of calculated variable:

```swift
let a = Variable(1)
let b = Variable(2)

combineLatest(a, b) { $0 + $1 } 
    >- filter { $0 >= 0 } 
    >- map { "\($0) is positive" }
    >- subscribeNext { println($0) }    // prints: 3 is positive

a.next(4)                               // prints: 6 is positive

b.next(-8)                              // doesn't print anything

a.next(9)                               // prints: 1 is positive
```

[Here is a more detailed explanation](Documentation/GettingStarted.md#getting-started-examples) of the presented example.

[Here is a rationale](#pipe-operator---vs--vs-) why `>-` was chosen and more about how to use your own function application operator (`|>`, `~>`, ...) with RxSwift.

If you have a `|>` operator defined as a pipe operator in your project, you can use it too instead of `>-` operator

```swift
let a = Variable(1)
let b = Variable(2)

// immediately prints: 3 is positive
combineLatest(a, b) { $0 + $1 } 
    |> filter { $0 >= 0 } 
    |> map { "\($0) is positive" }
    |> subscribeNext { println($0) }

// ...
```

The choice is yours.

Now something a little more interesting:

* instead of binding to variables, let's bind to text field values (rx_text)
* next, parse that into an int and calculate if the number is prime using an async API (map)
* if text field value is changed before async call completes, new async call will be enqueued (concat)
* bind results to label (resultLabel.rx_subscribeTextTo)

```swift
let subscription/*: Disposable */ = primeTextField.rx_text()    // type is Observable<String>
            >- map { WolframAlphaIsPrime($0.toInt() ?? 0) }     // type is Observable<Observable<Prime>>
            >- concat                                           // type is Observable<Prime>
            >- map { "number \($0.n) is prime? \($0.isPrime)" } // type is Observable<String>
            >- resultLabel.rx_subscribeTextTo                   // return Disposable that can be used to unbind everything
        
// This will set resultLabel.text to "number 43 is prime? true" after
// server call completes.
primeTextField.text = "43"

// ...

// to unbind everything, just call
subscription.dispose()
```

All of the operators used in this example are the same operators used in the first example with variables. Nothing special about it.

If you are new to Rx, next example will probably be a little overwhelming, but it's here to demonstrate how RxSwift code looks like in real world examples. I suggest to take a look at [practical examples](RxExample) in the repository.

The third example is a real world, complex UI async validation logic, with progress notifications.
All operations are cancelled the moment `disposeBag.dispose()` is called.

Let's give it a shot.

```swift
// bind UI control values directly
// use username from `usernameOutlet` as username values source
self.usernameOutlet.rx_text() >- map { username in

    // synchronous validation, nothing special here
    if count(username) == 0 {
        // Convenience for constructing synchronous result.
        // In case there is mixed synchronous and asychronous code inside the same
        // method, this will construct an async result that is resolved immediatelly.
        return returnElement((valid: false, message: "Username can't be empty."))
    }

    ...

    // Every user interface probably shows some state while async operation
    // is executing.
    // Let's assume that we want to show "Checking availability" while waiting for result.
    // valid parameter can be 
    //  * true  - is valid
    //  * false - not valid
    //  * nil   - validation pending
    let loadingValue = (valid: nil, message: "Checking availability ...")

    // This will fire a server call to check if the username already exists.
    // Guess what, its type is `Observable<ValidationResult>`
    return API.usernameAvailable(username) >- map { available in
        if available {
            return (true, "Username available")
        }
        else {
            return (false, "Username already taken")
        }
    }
    // use `loadingValue` until server responds
        >- startWith(loadingValue)
}
// Since we now have `Observable<Observable<ValidationResult>>`
// we somehow need to return to normal `Observable` world.
// We could use `concat` operator from second example, but we really 
// want to cancel pending asynchronous operation if new username is
// provided.
// That's what `switchLatest` does
    >- switchLatest
// Not we need to bind that to the user interface somehow.
// Good old `subscribeNext` can do that
// That's the end of `Observable` chain.
// This will produce a `Disposable` object that can unbind everything and cancel
// pending async operations.
    >- subscribeNext { valid in
        errorLabel.textColor = validationColor(valid)
        errorLabel.text = valid.message
    }
// Why would we do it manually, that's tedious, 
// let's dispose everything automagically on view controller dealloc.
    >- disposeBag.addDisposable
```

Can't get any simpler than this. There are more examples in the repository, so feel free to check them out. 

They include examples on how to use it in the context of MVVM pattern or without it.

## RxSwift supported operators

In some cases there are multiple aliases for the same operator, because on different platforms / implementations, the same operation is sometimes called differently. Sometimes this is because historical reasons, sometimes because of reserved language keywords.

When lacking a strong community consensus, RxSwift will usually include multiple aliases.

Operators are stateless by default.

* map / select
* filter / where
* foldl / aggregate
* multicast
* publish
* replay
* refCount
* observeSingleOn
* generation operators (returnElement/just, empty, never, failWith, defer)
* debug
* concat
* merge
* switchLatest
* catch
* asObservable
* distinctUntilChanged
* do / doOnNext
* throttle
* sample
* startWith
* variable / sharedWithCachedLastResult

Creating new operators is also pretty straightforward. 

## RxCocoa extensions

**iOS / OSX**

```swift
extension NSObject {

    public func rx_observe<Element>(path: String) -> Observable<Element?> { }

    public func rx_observe<Element>(path: String, options: NSKeyValueObservingOptions) -> Observable<Element?> { }

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

**iOS**

```swift
extension UIButton {

    public func rx_tap() -> Observable<Void> {}

}
```

```swift
extension UITextField {

    public func rx_text() -> Observable<String> {}

}
```

```swift
extension UISearchBar {

    public func rx_searchText() -> Observable<String> {}

}
```

```swift
extension UILabel {

    public func rx_subscribeTextTo(source: Observable<String>) -> Disposable {}

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

    public func rx_contentOffset() -> Observable<CGPoint> {}

}
```

```swift
extension UITableView {

    public func rx_elementTap<E>() -> Observable<E> {}

    public func rx_rowTap() -> Observable<(UITableView, Int)> {}

    public func rx_subscribeRowsTo<E where E: AnyObject>
        (dataSource: TableViewDataSource)
        (source: Observable<[E]>)
            -> Disposable {}

    public func rx_subscribeRowsTo<E where E : AnyObject>
        (cellFactory: (UITableView, NSIndexPath, E) -> UITableViewCell)
        (source: Observable<[E]>)
            -> Disposable {}

    public func rx_subscribeRowsToCellWithIdentifier<E, Cell where E : AnyObject, Cell: UITableViewCell>
        (cellIdentifier: String, configureCell: (UITableView, NSIndexPath, E, Cell) -> Void)
        (source: Observable<[E]>) 
            -> Disposable {}

}
```

```swift
extension UICollectionView {

    public func rx_itemTap() -> Observable<(UICollectionView, Int)> {}

    public func rx_elementTap<E>() -> Observable<E> {}

    public func rx_subscribeItemsTo<E where E: AnyObject>
        (dataSource: CollectionViewDataSource)
        (source: Observable<[E]>)
            -> Disposable {}

    public func rx_subscribeItemsTo<E where E : AnyObject>
        (cellFactory: (UICollectionView, NSIndexPath, E) -> UICollectionViewCell)
        (source: Observable<[E]>) 
            -> Disposable {}

    public func rx_subscribeItemsWithIdentifierTo<E, Cell where E : AnyObject, Cell : UICollectionViewCell>
        (cellIdentifier: String, configureCell: (UICollectionView, NSIndexPath, E, Cell) -> Void)
        (source: Observable<[E]>)
            -> Disposable {}

}
```
**OSX**

```swift
extension NSButton {

    public func rx_tap() -> Observable<Void> { }

}
```

```swift
extension NSImageView {

    public func rx_subscribeImageTo(source: Observable<NSImage?>) -> Disposable { }
    
    public func rx_subscribeImageTo
        (animated: Bool)
        (source: Observable<NSImage?>) -> Disposable { }
}
```

```swift
extension NSTextField {

    public func rx_subscribeTextTo(source: Observable<String>) -> Disposable { }

    public func rx_text() -> Observable<String> { }

} 
```

## Build / Install / Run

Rx doesn't contain any external dependencies.

These are currently supported options:

* Open Rx.xcworkspace, choose `RxExample` and hit run. This method will build everything and run sample app
* [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

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

This is of course valid for query operations or commands that are scheduled for future execution. For commands that have already started to mutate state, the situation is little more complex and depends on the particular case.

## Duality between Observer and Iterator / Enumerator / Generator / Sequences

There is a duality between observer and generator pattern. They both describe sequences. Since sequences in Rx are implemented through observer pattern, it is important to understand this duality.

In short, there are two basic ways elements of a sequence can be accessed.

* Push interface - Observer
* Pull interface - Iterator / Enumerator / Generator

To learn more about this, these videos should help

* [Erik Meijer on Rx and duality (video)](http://channel9.msdn.com/Events/Lang-NEXT/Lang-NEXT-2014/Keynote-Duality)
* [Subject/Observer is Dual to Iterator (paper)](http://csl.stanford.edu/~christos/pldi2010.fit/meijer.duality.pdf)
* [Erik Meijer on Rx and duality 2 (video)](http://channel9.msdn.com/Shows/Going+Deep/Expert-to-Expert-Brian-Beckman-and-Erik-Meijer-Inside-the-NET-Reactive-Framework-Rx)

## Base classes / interfaces

`throttle`, `distinctUntilChanged`, `switchLatest` ... are just normal functions that take `Observable<InputElement>` as input and return `Observable<OutputElement>` as output. `>-` is a pipe operator that feeds `lhs` value to `rhs` function.

```swift
func >- <In, Out>(source: In, transform: In -> Out) -> Out {
    return transform(source)
}
```

This is actually a general purpose operator and it can be used outside the concept of `Observable<Element>` and sequences.

Sequences usually don't actually exist in memory. It is just an abstraction. Sequences of elements of type `Element` are represented by a corresponding `Observable<Element>`. Every time some element is observed it implicitly becomes next element in the observed sequence of values. Even though the sequence of elements is implicit, that doesn't make it any less useful.

```
class Observable<Element> {
    func subscribe(observer: Observer<Element>) -> Disposable
}
```

To observe elements of a sequence, `Observer<Element>` needs to subscribe with `Observable<Element>`.

* Every time the next element of a sequence is produced, `Observable<Element>` will send a `Next(Element)` notification to `Observer<Element>`.

* If sequence computation ended prematurely because of an error, `Observable<Element>` will send an `Error(ErrorType)` notification to `Observer<Element>`. Computation resources have been released and this is the last message that observer will receive for that subscription.

* If sequence end was computed, `Observable<Element>` will send a `Completed` notification to `Observer<Element>`. Computation resources have been released and this is the last message observer will receive for that subscription.

This means that a sequence can only finish with `Completed` or `Error` message and after that no further messages will be received for that subscription.


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

When `Observer<Element>` wants to unsubscribe notifications from `Observable<Element>` it needs to call `dispose` on the `Disposable` object it received while subscribing.

```
protocol Disposable
{
    func dispose()
}
```

## Hot and cold observables

There are two basic types of observables. In Rx both are represented by `Observable<Element>`.

| Hot observables                                                                                         | Cold observables                                                              |
|---------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------|
| ... are sequences                                                                                       | ... are sequences                                                             |
| Use resources ("produce heat") no matter if there is any observer subscribed.                           | Don't use resources (don't produce heat) until observer subscribes.            |
| Variables / properties / constants, tap coordinates, mouse coordinates, UI control values, current time | Async operations, HTTP Connections, TCP connections, streams                 |
| Usually contains ~ N elements                                                                           | Usually contains ~ 1 element                                                  |
| Sequence elements are produced no matter if there is any observer subscribed.                           | Sequence elements are produced only if there is a subscribed observer.       |
| Sequence computation resources are usually shared between all of the subscribed observers.              | Sequence computation resources are usually allocated per subscribed observer. |
| Usually stateful                                                                                        | Usually stateless                                                             |


## Error handling

Error handling is pretty straightforward. If one sequence terminates with error, then all of the dependent sequences will terminate with error. It's usual short circuit logic.

Unfortunately Swift doesn't have a concept of exceptions or some kind of built in error monad so this project introduces `Result` enum.
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

_`>==` and `>>>` were chosen because they are the closest sequence of characters to standard monadic bind `>>=` and `>>` function (`>>=` is already reserved for logical shift and assign).
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

If there is some `UITextField` bound to a observable sequence that fails with error or completes, screen won't be updated ever again. 

To make those situations more obvious, RxCocoa debug build will throw an exception in case some sequence that is bound to UI control terminates with an error.

Using functions without "OrDie" suffix is usually a more safe option.

There is also the `catch` operator for easier error handling.

## Pipe operator >- vs |> vs ...

Unfortunately, as far as I'm aware of there isn't any default left associative function application swift operator. If there was (please let me know) or if you have created your own left associative function application operator, you can use it immediately with RxSwift.

This is the default one:

```swift
func >- <In, Out>(lhs: In, rhs: In -> Out) -> Out {
    return rhs(lhs)
}
```

```
a >- b >- c is equivalent to c(b(a))
```

All of the Rx public interfaces don't depend at all on the `>-` operator. 

It was actually introduced quite late and you can use Rx operators (map, filter ...) without it. 

This is how Rx code would look like without `>-` operator

```
subscribeNext({ println($0) })(map({ "\($0) is positive" })(filter({ $0 >= 0 })(a)))
```

but it's highly unlikely that anybody would want to code like this, even though the code is technically correct, and will produce wanted results.

If you dislike `>-` operator and want to use `|>` or `~>` operators, just define them in your project in this form:

```swift
infix operator |> { associativity left precedence 91 }

public func |> <In, Out>(source: In, @noescape transform: In -> Out) -> Out {
    return transform(source)
}
```

or 

```
infix operator ~> { associativity left precedence 91 }

public func ~> <In, Out>(source: In, @noescape transform: In -> Out) -> Out {
    return transform(source)
}
```

and you can use them instead of `>-` operator.

```swift
let a /*: Observable<Int>*/ = Variable(1)
let b /*: Observable<Int>*/ = Variable(2)

combineLatest(a, b) { $0 + $1 } 
    |> filter { $0 >= 0 } 
    |> map { "\($0) is positive" }
    |> subscribeNext { println($0) }
```

```swift
let a /*: Observable<Int>*/ = Variable(1)
let b /*: Observable<Int>*/ = Variable(2)

combineLatest(a, b) { $0 + $1 } 
    ~> filter { $0 >= 0 } 
    ~> map { "\($0) is positive" }
    ~> subscribeNext { println($0) }
```

So why was `>-` chosen in the end? Well, it was a difficult decision.

Why wasn't standard function application operator used?

I've first tried to find a similar operator in swift core libraries, but couldn't find it. That meant that I'll need to define something myself or find some third party library that contains reference function application operator definition and use it.
Otherwise all of the example code would be unreadable.

Why wasn't some standard library used for that operator?

Well, I'm not sure there is a clear consensus in the community about funtion application operators or libraries that define them.

Why wasn't function application operator defined only for `Observables` and `Disposables`?

One of the solutions could have been to provide a specialized operator that just works for `Observables` and `Disposables`.
In that case, if an identically named general purpose function application operator is defined somewhere else, there would still be collision, priority or ambiguity problems.

Why wasn't some more standard operator like `|>` or `~>` used?

`|>` or `~>` are probably more commonly used operators in swift, so if there was another definition for them in Rx as general purpose function application operators, there is a high probability they would collide with definitions in other frameworks or project.

The same logic applies for other operators `>==`, `>>!` that are defined on `Result` enum only.

The simplest and safest solution IMHO was to create some new operator that made sense in this context and there is a low probability anyone else uses it.
In case the operator naming choice was wrong, name is rare and community eventually reaches consensus on the matter, it's more easier to find and replace it in user projects.

I have experimented for a week with different operators and in the end these are the reasons why `>-` was chosen

* It's short, only two characters
* It looks like a sink to the right, which is a function it actually performs, so it's intuitive.
* It doesn't create a lot of visual noise. `|>` compared to `>-` IMHO looks a lot more intrusive. When my visual cortex parses `|>` it creates an illusion of a filled triangle, and when it parses `>-`, it sees three lines that don't cover any surface area, but are easily recognizable. Of course, that experience can be different for other people, but since I really wanted to create something that's pleasurable for me to use, that's a good argument. I'm just hoping that other people have the same experience.
* In the worst case scenario, if this operator is awkward to somebody, they can easily replace it using instructions above.

## Peculiarities

* Swift support for generic enums is limited. That's why there is the `Box` hack in `Result` and `Event` enums
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
* [http://reactivex.io/](http://reactivex.io/)
* [Reactive Cocoa (GitHub)](https://github.com/ReactiveCocoa/ReactiveCocoa)
* [Erik Meijer on Rx and duality (video)](http://channel9.msdn.com/Events/Lang-NEXT/Lang-NEXT-2014/Keynote-Duality)
* [Subject/Observer is Dual to Iterator (paper)](http://csl.stanford.edu/~christos/pldi2010.fit/meijer.duality.pdf)
* [Erik Meijer on Rx and duality 2 (video)](http://channel9.msdn.com/Shows/Going+Deep/Expert-to-Expert-Brian-Beckman-and-Erik-Meijer-Inside-the-NET-Reactive-Framework-Rx)
* [The Future Of ReactiveCocoa by Justin Spahr-Summers (video)](https://www.youtube.com/watch?v=ICNjRS2X8WM)
* [Rx standard sequence operators visualized (visualization tool)](http://rxmarbles.com/)
* [Haskell](https://www.haskell.org/)
