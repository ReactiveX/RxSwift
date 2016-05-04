//: [Index](Index)

import RxSwift
import Foundation

/*:
# Introduction

## Why use RxSwift?

A vast majority of the code we write revolves around responding to external actions. When a user manipulates a control, we need to write an @IBAction to respond to that. We need to observe Notifications to detect when the keyboard changes position. We must provide blocks to execute when URL Sessions respond with data. Finally, we use KVO to detect changes in variables.
All of these various systems makes our code needlessly complex. Wouldn't it be better if there was one consistent system that handled all of our call/response code? Rx is such a system.

### Concepts

The key to understanding RxSwift is by understanding the notion of Observables as **sequences** of elements.
The next step is to learn how to **create** them, **manipulate** them, and finally **subscribe** to them. Subscribing is needed in order to start the computation and the reception of the elements.
If an Observable emits an `Event.Next` (an element of the sequence), it can still send events. However, if the Observable emits an `Event.Error` (the Observable sequece terminates with an error) or `Event.Completed` (the Observable sequence has completed without error), the Observable won't ever emit more events.

Sequence grammar explains this more concisely.

`Next* (Error | Completed)?`


## Subscription to Observables sequences


Creating an Observable is one thing, but if nothing subscribes to the observable then nothing will happen. In other words, an arbitrary number of `Next` events (sequence elements) will only be emitted after at least one subscription has been made. No more events will be produced after an `Error` or `Completed` has been emitted.

The following closure of the Observable will never be called:
*/

_/* : Observable<String>*/ = Observable<String>.create { observerOfString -> Disposable in
        print("This never will be printed")
        observerOfString.on(.Next("😬"))
        observerOfString.on(.Completed)
        return NopDisposable.instance
    }

/*:

However, the closure in the following is called:
*/

_/* : Observable<String>*/ = Observable<String>.create { observerOfString -> Disposable in
        print("Observable creation")
        observerOfString.on(.Next("😉"))
        observerOfString.on(.Completed)
        return NopDisposable.instance
    }
    .subscribe { print($0) }

/*:


The subscription will be present in the whole Rx.playground.

*/

//: [Index](Index) - [Next >>](@next)
