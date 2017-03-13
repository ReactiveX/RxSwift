Units
=====

This document will try to describe what units are, why they are a useful concept, and how to use and create them.

* [Why](#why)
* [How they work](#how-they-work)
* [Why they are named Units](#why-they-are-named-units)
* [RxSwift units](#rxswift-units)
* [RxCocoa units](#rxcocoa-units)
* [Driver unit](#driver-unit)
    * [Why it's named Driver](#why-its-named-driver)
    * [Practical usage example](#practical-usage-example)

## Why

Swift has a powerful type system that can be used to improve correctness and stability of applications and make using Rx a more intuitive and straightforward experience.

**Units are specific only to the [RxCocoa](https://github.com/ReactiveX/RxSwift/tree/master/RxCocoa) project. However, the same principles could easily be implemented in other Rx implementations, if necessary. There is no private API magic needed.**

**Units are totally optional. You can use raw observable sequences everywhere in your program and all RxCocoa APIs work with observable sequences.**

Units also help communicate and ensure observable sequence properties across interface boundaries.

Here are some of the properties that are important when writing Cocoa/UIKit applications.

* Can't error out
* Observe on main scheduler
* Subscribe on main scheduler
* Sharing side effects

## How they work

It's just a wrapper struct with single read only property that contains a private reference to observable sequence.

e.g.
```
struct Single<Element> {
    let source: Observable<Element>
}
struct Driver<Element> {
    let source: Observable<Element>
}
...
```

You can think of them as a kind of builder pattern for observable sequences. When a sequence is built, calling `.asObservable()` will transform sequence builder into a vanilla observable sequence.

## Why they are named Units

Using a couple analogies will help us reason about unfamiliar concepts. Here are some analogies showing how units in physics and RxCocoa (Rx units) are similar.

Analogies:

| Measurements                        | Rx "measurement"                                                    |        |
|-------------------------------------|---------------------------------------------------------------------|--------|
| number (one value)                  | observable sequence (sequence of values)                            | value  |
| dimensional unit (m, s, m/s, N ...) | Swift struct (Driver, ControlProperty, ControlEvent, ...)           | Unit   |

The assumption is that one would model physical units of measurement in Swift in the following way. Meter example:

```
protocol Unit {
    var value { get }
    public static func +(lhs: Self, rhs: Self) -> Self
}

struct Meter: Unit {
    let value: Double
    init(value: Double) {
        self.value = value
    }
}

struct Second: Unit {
    let value: Double
    init(value: Double) {
        self.value = value
    }
}

let oneMeter = Meter(value: 1.0)
let twoMeters = oneMeter + oneMeter
let wot = Meter(value: 1.0) + Second(value: 1.0) // <-- compile time error
```

There are [other ways](https://developer.apple.com/reference/foundation/nsmeasurement) how measurements/units could be modelled, but the presented approach is closely related with Rx units model.

A physical measurement is a pair of a number and a corresponding dimensional unit (unit is represented by a type of wrapper struct).<br/>
An Rx "measurement" is a pair of an observable sequence and a corresponding wrapper struct (Unit) that describes observable sequence properties.

Numbers are the basic compositional glue when working with physical units: usually real or complex numbers.<br/>
Observable sequences are the basic compositional glue when working with Rx units.

Physical units and [dimensional analysis](https://en.wikipedia.org/wiki/Dimensional_analysis#Checking_equations_that_involve_dimensions) can alleviate certain classes of errors during complex calculations.<br/>
Type checking Rx units can alleviate certain classes of logic errors when writing reactive programs.

Numbers have operators: `+`, `-`, `*`, `/`.<br/>
Observable sequences also have operators: `map`, `filter`, `flatMap` ...

Physics units define operations by using corresponding number operations. E.g.

`/` operation on physical units is defined using `/` operation on numbers.

11 m / 0.5 s = ...
* First, convert the measurements to **numbers** and **apply** `/` **operator** `11 / 0.5 = 22`
* Then, calculate the unit (m / s)
* Lastly, combine the result = 22 m / s

Rx Units/"measurements" define operations by using corresponding observable sequence operations (this is how operators work internally). E.g.

The `map` operation on `Driver` is defined using the `map` operation on its observable sequence.

```swift
let d: Driver<Int> = Driver.just(11)
driver.map { $0 / 0.5 } = ...
```

* First, convert `Driver` to **observable sequence** and **apply** `map` **operator**
```swift
let mapped = driver.asObservable().map { $0 / 0.5 } // this `map` is defined on observable sequence
```

* Then, combine that to get the unit value
```swift
let result = Driver(mapped)
```

There is a set of basic units in physics [(`m`, `kg`, `s`, `A`, `K`, `cd`, `mol`)](https://en.wikipedia.org/wiki/SI_base_unit) that is orthogonal.<br/>
There is a set of basic interesting properties for observable sequences in `RxCocoa` that is orthogonal.

    * Can't error out
    * Observe on main scheduler
    * Subscribe on main scheduler
    * Sharing side effects

Derived units in physics sometimes have special names.<br/>
E.g.
```
N (Newton) = kg * m / s / s
C (Coulomb) = A * s
T (Tesla) = kg / A / s / s
```

Rx derived units also have special names.<br/>
E.g.
```
Driver = (can't error out) * (observe on main scheduler) * (sharing side effects)
ControlProperty = (sharing side effects) * (subscribe on main scheduler)
```

Conversion of measurements between different units in physics is done with the help of operators defined on numbers `*`, `/`.<br/>
Conversions between Rx units in done with the help of observable sequence operators.

E.g.

```
Can't error out = catchError
Observe on main scheduler = observeOn(MainScheduler.instance)
Subscribe on main scheduler = subscribeOn(MainScheduler.instance)
Sharing side effects = share* (one of the `share` operators)
```

## RxSwift units

### Single

* Contains exactly one element

### Maybe

* Contains exactly zero or one elements

### Completable

* Contains zero elements

## RxCocoa units

### Driver

* Can't error out
* Observe on main scheduler
* Sharing side effects (`shareReplayLatestWhileConnected`)

### ControlProperty / ControlEvent

* Can't error out
* Subscribe on main scheduler
* Observe on main scheduler
* Sharing side effects

## Driver

This is the most elaborate unit. Its intention is to provide an intuitive way to write reactive code in the UI layer.

### Why it's named Driver

Its intended use case was to model sequences that drive your application.

E.g.
* Drive UI from CoreData model
* Drive UI using values from other UI elements (bindings)
...


Like normal operating system drivers, in case a sequence errors out, your application will stop responding to user input.

It is also extremely important that those elements are observed on the main thread because UI elements and application logic are usually not thread safe.

Also, `Driver` unit builds an observable sequence that shares side effects.

E.g.


### Practical usage example

This is a typical beginner example.

```swift
let results = query.rx.text
    .throttle(0.3, scheduler: MainScheduler.instance)
    .flatMapLatest { query in
        fetchAutoCompleteItems(query)
    }

results
    .map { "\($0.count)" }
    .bindTo(resultCount.rx.text)
    .disposed(by: disposeBag)

results
    .bindTo(resultsTableView.rx.items(cellIdentifier: "Cell")) { (_, result, cell) in
        cell.textLabel?.text = "\(result)"
    }
    .disposed(by: disposeBag)
```

The intended behavior of this code was to:
* Throttle user input
* Contact server and fetch a list of user results (once per query)
* Bind the results to two UI elements: results table view and a label that displays the number of results

So, what are the problems with this code?:
* If the `fetchAutoCompleteItems` observable sequence errors out (connection failed or parsing error), this error would unbind everything and the UI wouldn't respond any more to new queries.
* If `fetchAutoCompleteItems` returns results on some background thread, results would be bound to UI elements from a background thread which could cause non-deterministic crashes.
* Results are bound to two UI elements, which means that for each user query, two HTTP requests would be made, one for each UI element, which is not the intended behavior.

A more appropriate version of the code would look like this:

```swift
let results = query.rx.text
    .throttle(0.3, scheduler: MainScheduler.instance)
    .flatMapLatest { query in
        fetchAutoCompleteItems(query)
            .observeOn(MainScheduler.instance)  // results are returned on MainScheduler
            .catchErrorJustReturn([])           // in the worst case, errors are handled
    }
    .shareReplay(1)                             // HTTP requests are shared and results replayed
                                                // to all UI elements

results
    .map { "\($0.count)" }
    .bindTo(resultCount.rx.text)
    .disposed(by: disposeBag)

results
    .bindTo(resultsTableView.rx.items(cellIdentifier: "Cell")) { (_, result, cell) in
        cell.textLabel?.text = "\(result)"
    }
    .disposed(by: disposeBag)
```

Making sure all of these requirements are properly handled in large systems can be challenging, but there is a simpler way of using the compiler and units to prove these requirements are met.

The following code looks almost the same:

```swift
let results = query.rx.text.asDriver()        // This converts a normal sequence into a `Driver` sequence.
    .throttle(0.3, scheduler: MainScheduler.instance)
    .flatMapLatest { query in
        fetchAutoCompleteItems(query)
            .asDriver(onErrorJustReturn: [])  // Builder just needs info about what to return in case of error.
    }

results
    .map { "\($0.count)" }
    .drive(resultCount.rx.text)               // If there is a `drive` method available instead of `bindTo`,
    .disposed(by: disposeBag)              // that means that the compiler has proven that all properties
                                              // are satisfied.
results
    .drive(resultsTableView.rx.items(cellIdentifier: "Cell")) { (_, result, cell) in
        cell.textLabel?.text = "\(result)"
    }
    .disposed(by: disposeBag)
```

So what is happening here?

This first `asDriver` method converts the `ControlProperty` unit to a `Driver` unit.

```swift
query.rx.text.asDriver()
```

Notice that there wasn't anything special that needed to be done. `Driver` has all of the properties of the `ControlProperty` unit, plus some more. The underlying observable sequence is just wrapped as a `Driver` unit, and that's it.

The second change is:

```swift
.asDriver(onErrorJustReturn: [])
```

Any observable sequence can be converted to `Driver` unit, as long as it satisfies 3 properties:
* Can't error out
* Observe on main scheduler
* Sharing side effects (`shareReplayLatestWhileConnected`)

So how do you make sure those properties are satisfied? Just use normal Rx operators. `asDriver(onErrorJustReturn: [])` is equivalent to following code.

```
let safeSequence = xs
  .observeOn(MainScheduler.instance)       // observe events on main scheduler
  .catchErrorJustReturn(onErrorJustReturn) // can't error out
  .shareReplayLatestWhileConnected         // side effects sharing
return Driver(raw: safeSequence)           // wrap it up
```

The final piece is using `drive` instead of using `bindTo`.

`drive` is defined only on the `Driver` unit. This means that if you see `drive` somewhere in code, that observable sequence can never error out and it observes on the main thread, which is safe for binding to a UI element.

Note however that, theoretically, someone could still define a `drive` method to work on `ObservableType` or some other interface, so to be extra safe, creating a temporary definition with `let results: Driver<[Results]> = ...` before binding to UI elements would be necessary for complete proof. However, we'll leave it up to the reader to decide whether this is a realistic scenario or not.
