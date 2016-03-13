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

## Observables
The key to understanding RxSwift is in understanding the notion of Observables. Creating them, manipulating them, and subscribing to them in order to react to changes.

## Creating and Subscribing to Observables
The first step in understanding this library is in understanding how to create Observables. There are a number of functions available to make Observables.
Creating an Observable is one thing, but if nothing subscribes to the observable, then nothing will come of it so both are explained simultaneously.
*/

/*:
### empty
`empty` creates an empty sequence. The only message it sends is the `.Completed` message.
*/

example("empty") {
    let emptySequence = Observable<Int>.empty()

    let subscription = emptySequence
        .subscribe { event in
            print(event)
        }
}


/*:
### never
`never` creates a sequence that never sends any element or completes.
*/

example("never") {
    let neverSequence = Observable<Int>.never()

    let subscription = neverSequence
        .subscribe { _ in
            print("This block is never called.")
        }
}

/*:
### just
`just` represents sequence that contains one element. It sends two messages to subscribers. The first message is the value of single element and the second message is `.Completed`.
*/

example("just") {
    let singleElementSequence = Observable.just(32)

    let subscription = singleElementSequence
        .subscribe { event in
            print(event)
        }
}

/*:
### sequenceOf
`sequenceOf` creates a sequence of a fixed number of elements.
*/

example("sequenceOf") {
    let sequenceOfElements/* : Observable<Int> */ = Observable.of(0, 1, 2, 3, 4, 5, 6, 7, 8, 9)
    
    let subscription = sequenceOfElements
        .subscribe { event in
            print(event)
        }
}

/*:
### from
`from` creates a sequence from `SequenceType`
*/

example("toObservable") {
    let sequenceFromArray = [1, 2, 3, 4, 5].toObservable()

    let subscription = sequenceFromArray
        .subscribe { event in
            print(event)
        }
}

/*:
### create
`create` creates sequence using Swift closure. This examples creates custom version of `just` operator.
*/

example("create") {
    let myJust = { (singleElement: Int) -> Observable<Int> in
        return Observable.create { observer in
            observer.on(.Next(singleElement))
            observer.on(.Completed)
            
            return NopDisposable.instance
        }
    }
    
    let subscription = myJust(5)
        .subscribe { event in
            print(event)
        }
}

/*:
### generate
`generate` creates sequence that generates its values and determines when to terminate based on its previous values.
*/

example("generate") {
    let generated = Observable.generate(
        initialState: 0,
        condition: { $0 < 3 },
        iterate: { $0 + 1 }
    )

    let subscription = generated
        .subscribe { event in
            print(event)
        }
}

/*:
### failWith
create an Observable that emits no items and terminates with an error
*/

example("failWith") {
    let error = NSError(domain: "Test", code: -1, userInfo: nil)
    
    let erroredSequence = Observable<Int>.error(error)
    
    let subscription = erroredSequence
        .subscribe { event in
            print(event)
        }
}

/*:
### `deferred`

do not create the Observable until the observer subscribes, and create a fresh Observable for each observer

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/defer.png)

[More info in reactive.io website]( http://reactivex.io/documentation/operators/defer.html )
*/
example("deferred") {
    let deferredSequence: Observable<Int> = Observable.deferred {
        print("creating")
        return Observable.create { observer in
            print("emmiting")
            observer.on(.Next(0))
            observer.on(.Next(1))
            observer.on(.Next(2))

            return NopDisposable.instance
        }
    }

    _ = deferredSequence
        .subscribe { event in
            print(event)
    }

    _ = deferredSequence
        .subscribe { event in
            print(event)
        }
}

/*:
There is a lot more useful methods in the RxCocoa library, so check them out: 
* `rx_observe` exist on every NSObject and wraps KVO.
* `rx_tap` exists on buttons and wraps @IBActions
* `rx_notification` wraps NotificationCenter events
* ... and many others
*/

//: [Index](Index) - [Next >>](@next)
