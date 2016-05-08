/*:
> # IMPORTANT: To use `Rx.playground`, please:

1. Open `Rx.xcworkspace`
2. Build `RxSwift-OSX` scheme
3. And then open `Rx` playground in `Rx.xcworkspace` tree view.
4. Choose `View > Show Debug Area`
*/

//: [<< Index](@previous)

import RxSwift
import Foundation

/*:
# Introduction

## Why use RxSwift?

A vast majority of the code we write revolves around responding to external actions. When a user manipulates a control, we need to write an @IBAction to respond to that. We need to observe Notifications to detect when the keyboard changes position. We must provide blocks to execute when URL Sessions respond with data. And we use KVO to detect changes in variables.
All of these various systems makes our code needlessly complex. Wouldn't it be better if there was one consistent system that handled all of our call/response code? Rx is such a system.

 ### Concepts
 
 **Every `Observable` sequence is just a sequence. The key advantage for an `Observable` vs Swift's `SequenceType` is that it can also receive elements asynchronously. This is the kernel of the RxSwift, documentation from here is about ways that we expand on that idea.**

 * `Observable`(`ObservableType`) is equivalent to `SequenceType`
 * `ObservableType.subscribe` method is equivalent to `SequenceType.generate` method.
 * Observer (callback) needs to be passed to `ObservableType.subscribe` method to receive sequence elements instead of calling `next()` on the returned generator.
 
 If an Observable emits an `Event.Next` (an element of the sequence), it can still send events. However, if the Observable emits an `Event.Error` (the Observable sequence terminates with an error) or `Event.Completed` (the Observable sequence has completed without error), the Observable sequence won't ever emit more events to this particular subscriber.
 
 Sequence grammar explains this more concisely.
 
 `Next* (Error | Completed)?`
 

 
 ## Subscribing to Observables sequences
 
 The following closure of the Observable will never be called because there is no `subscribe` call:
 */

_/* : Observable<String>*/ = Observable<String>.create { observerOfString -> Disposable in
        print("This never will be printed")
        observerOfString.on(.Next("😬"))
        observerOfString.on(.Completed)
        return NopDisposable.instance
    }

/*:
 
 However, the subscription closure will be called once there is a subscriber:
 */

_/* : Disposable*/ = Observable<String>.create { observerOfString -> Disposable in
        print("Observable creation")
        observerOfString.on(.Next("😉"))
        observerOfString.on(.Completed)
        return NopDisposable.instance
    }
    .subscribe { print($0) }

/*:
 
 > One note to add: It can be seen that the entity returned by `subscribe`, a `Disposable`, is being ignored in this playground page for simplicity sake. In real world use cases it should be properly handled. Usually that means adding it to a `DisposeBag`. You can find more information about this in section *Disposing* of *GettingStarted.md* in *Documentation* directory.
 
 */

//: [Index](Index) - [Next >>](@next)
