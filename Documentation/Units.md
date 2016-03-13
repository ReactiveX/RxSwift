Units
=====

This document will try to describe what units are, why they are a useful concept, how to use and create them.

* [Why](#why)
* [How do they work](#how-do-they-work)
* [Why are they named Units](#why-are-they-named-units)
* [RxCocoa units](#rxcocoa-units)
* [Driver unit](#driver-unit)
    * [Why was it named Driver](#why-was-it-named-driver)
    * [Practical usage example](#practical-usage-example)

## Why

Swift has a powerful type system that can be used to improve correctness and stability of applications and make using Rx a more intuitive and straightforward experience.

**Units are so far specific only to the [RxCocoa](https://github.com/ReactiveX/RxSwift/tree/master/RxCocoa) project, but the same principles could be implemented easily in other Rx implementations if necessary. There is no private API magic needed.**

**Units are totally optional, you can use raw observable sequences everywhere in your program and all RxCocoa APIs work with observable sequences.**

Units also help communicate and ensure observable sequence properties across interface boundaries.

Here are some of the properties that are important when writing Cocoa/UIKit applications.

* can't error out
* observe on main scheduler
* subscribe on main scheduler
* sharing side effects

## How do they work

In its core it's just a struct with a reference to observable sequence.

You can think of them as a kind of builder pattern for observable sequences. When sequence is built, calling `.asObservable()` will transform a unit into a vanilla observable sequence.

## Why are they named Units

Analogies help reason about unfamiliar concepts, here are some ideas how units in physics and RxCocoa (rx units) are similar.

Analogies:

| Physical units                      | Rx units                                                            |
|-------------------------------------|---------------------------------------------------------------------|
| number (one value)                  | observable sequence (sequence of values)                            |
| dimensional unit (m, s, m/s, N ...) | Swift struct (Driver, ControlProperty, ControlEvent, Variable, ...) |

Physical unit is a pair of a number and a corresponding dimensional unit.<br/>
Rx unit is a pair of an observable sequence and a corresponding struct that describes observable sequence properties.

Numbers are the basic composition glue when working with physical units: usually real or complex numbers.<br/>
Observable sequences are the basic composition glue when working with rx units.

Physical units and [dimensional analysis](https://en.wikipedia.org/wiki/Dimensional_analysis#Checking_equations_that_involve_dimensions) can alleviate certain class of errors during complex calculations.<br/>
Type checking rx units can alleviate certain class of logic errors when writing reactive programs.

Numbers have operators: `+`, `-`, `*`, `/`.<br/>
Observable sequences also have operators: `map`, `filter`, `flatMap` ...

Physics units define operations by using corresponding number operations. E.g.

`/` operation on physical units is defined using `/` operation on numbers.

11 m / 0.5 s = ...
* first convert unit to **numbers** and **apply** `/` **operator** `11 / 0.5 = 22`
* then calculate unit (m / s)
* combine the result = 22 m / s

Rx units define operations by using corresponding observable sequence operations (this is how operators work internally). E.g.

The `map` operation on `Driver` is defined using the `map` operation on its observable sequence.

```swift
let d: Driver<Int> = Drive.just(11)
driver.map { $0 / 0.5 } = ...
```

* first convert driver to **observable sequence** and **apply** `map` **operator**
```swift
let mapped = driver.asObservable().map { $0 / 0.5 } // this `map` is defined on observable sequence
```

* then combine that to get the unit value
```swift
let result = Driver(mapped)
```

There is a set of basic units in physics [(`m`, `kg`, `s`, `A`, `K`, `cd`, `mol`)](https://en.wikipedia.org/wiki/SI_base_unit) that is orthogonal.<br/>
There is a set of basic interesting properties for observable sequences in `RxCocoa` that is orthogonal.

    * can't error out
    * observe on main scheduler
    * subscribe on main scheduler
    * sharing side effects

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
Variable = (can't error out) * (sharing side effects)
```

Conversion between different units in physics is done with a help of operators defined on numbers `*`, `/`.<br/>
Conversion between different rx units in done with a help of observable sequence operators.

E.g.

```
can't error out = catchError
observe on main scheduler = observeOn(MainScheduler.instance)
subscribe on main scheduler = subscribeOn(MainScheduler.instance)
sharing side effects = share* (one of the `share` operators)
```


## RxCocoa units

### Driver unit

* can't error out
* observe on main scheduler
* sharing side effects (`shareReplayLatestWhileConnected`)

### ControlProperty / ControlEvent

* can't error out
* subscribe on main scheduler
* observe on main scheduler
* sharing side effects

### Variable

* can't error out
* sharing side effects

## Driver

This is the most elaborate unit. It's intention is to provide an intuitive way to write reactive code in UI layer.

### Why was it named Driver

It's intended use case was to model sequences that drive your application.

E.g.
* Drive UI from CoreData model
* Drive UI using values from other UI elements (bindings)
...


Like normal operating system drivers, in case one of those sequence errors out your application will stop responding to user input.

It is also extremely important that those elements are observed on main thread because UI elements and application logic are usually not thread safe.

Also, `Driver` unit builds an observable sequence that shares side effects.

E.g.


### Practical usage example

This is an typical beginner example.

```swift
let results = query.rx_text
    .throttle(0.3, scheduler: MainScheduler.instance)
    .flatMapLatest { query in
        fetchAutoCompleteItems(query)
    }

results
    .map { "\($0.count)" }
    .bindTo(resultCount.rx_text)
    .addDisposableTo(disposeBag)

results
    .bindTo(resultsTableView.rx_itemsWithCellIdentifier("Cell")) { (_, result, cell) in
        cell.textLabel?.text = "\(result)"
    }
    .addDisposableTo(disposeBag)
```

The intended behavior of this code was to:
* throttle user input
* contact server and fetch a list of user results (once per query)
* then bind the results to two UI elements, results table view and a label that displays number of results

So what are the problems with this code:
* in case the `fetchAutoCompleteItems` observable sequence errors out (connection failed, or parsing error), this error would unbind everything and UI wouldn't respond any more to new queries.
* in case `fetchAutoCompleteItems` returns results on some background thread, results would be bound to UI elements from a background thread and that could cause non deterministic crashes.
* results are bound to two UI elements, which means that for each user query two HTTP requests would be made, one for each UI element, which is not intended behavior.

A more appropriate version of the code would look like this:

```swift
let results = query.rx_text
    .throttle(0.3, scheduler: MainScheduler.instance)
    .flatMapLatest { query in
        fetchAutoCompleteItems(query)
            .observeOn(MainScheduler.instance) // results are returned on MainScheduler
            .catchErrorJustReturn([])                // in worst case, errors are handled
    }
    .shareReplay(1)                                  // HTTP requests are shared and results replayed
                                                     // to all UI elements

results
    .map { "\($0.count)" }
    .bindTo(resultCount.rx_text)
    .addDisposableTo(disposeBag)

results
    .bindTo(resultTableView.rx_itemsWithCellIdentifier("Cell")) { (_, result, cell) in
        cell.textLabel?.text = "\(result)"
    }
    .addDisposableTo(disposeBag)
```

Making sure all of these requirements are properly handled in large systems can be challenging, but there is a simpler way of using the compiler and units to prove these requirements are met.

The following code looks almost the same:

```swift
let results = query.rx_text.asDriver()        // This converts normal sequence into `Driver` sequence.
    .throttle(0.3, scheduler: MainScheduler.instance)
    .flatMapLatest { query in
        fetchAutoCompleteItems(query)
            .asDriver(onErrorJustReturn: [])  // Builder just needs info what to return in case of error.
    }

results
    .map { "\($0.count)" }
    .drive(resultCount.rx_text)               // If there is `drive` method available instead of `bindTo`,
    .addDisposableTo(disposeBag)              // that means that compiler has proved all properties
                                              // are satisfied.
results
    .drive(resultTableView.rx_itemsWithCellIdentifier("Cell")) { (_, result, cell) in
        cell.textLabel?.text = "\(result)"
    }
    .addDisposableTo(disposeBag)
```

So what is happening here?

This first `asDriver` method converts `ControlProperty` unit to `Driver` unit.

```swift
query.rx_text.asDriver()
```

Notice that there wasn't anything special that needed to be done. `Driver` has all of the properties of the `ControlProperty` unit plus some more. The underlying observable sequence is just wrapped as `Driver` unit, and that's it.

The second change is

```swift
  .asDriver(onErrorJustReturn: [])
```

Any observable sequence can be converted to `Driver` unit, it just needs to satisfy 3 properties:
* can't error out
* observe on main scheduler
* sharing side effects (`shareReplayLatestWhileConnected`)

So how to make sure those properties are satisfied? Just use normal Rx operators. `asDriver(onErrorJustReturn: [])` is equivalent to following code.

```
let safeSequence = xs
  .observeOn(MainScheduler.instance) // observe events on main scheduler
  .catchErrorJustReturn(onErrorJustReturn) // can't error out
  .shareReplayLatestWhileConnected         // side effects sharing
return Driver(raw: safeSequence)           // wrap it up
```

The final piece is `drive` instead of using `bindTo`.

`drive` is defined only on `Driver` unit. It means that if you see `drive` somewhere in code, observable sequence that can never error out and observes elements on main thread is being bound to UI element. Which is exactly what is wanted.

Theoretically, somebody could define `drive` method to work on `ObservableType` or some other interface, so creating a temporary definition with `let results: Driver<[Results]> = ...` before binding to UI elements would be necessary for complete proof, but we'll leave it up for reader to decide whether that is a realistic scenario.
