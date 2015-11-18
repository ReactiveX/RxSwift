//: [Previous](@previous)

import RxSwift
import Foundation


/*:

## Introduction

### Why use RxSwift?

A vast majority of the code we write revolves around responding to external actions. When a user manipulates a control, we need to write an @IBAction to respond to that. We need to observe Notifications to detect when the keyboard changes position. We must provide blocks to execute when URL Sessions respond with data. And we use KVO to detect changes in variables.

All of these various systems makes our code needlessly complex. Wouldn't it be better if there was one consistent system that handled all of our call/response code? Rx is such a system.

### Basis

The key to understanding RxSwift is in understanding the notion of Observables. Creating them, manipulating them, and subscribing to them in order to react to changes.

The first step in understanding this library is in understanding how to create Observables. There are a number of [functions available to make Observables](Creating_Observables).

Creating an Observable is one thing, but if nothing subscribes to the observable, then nothing will come.

### Subscription

When subscribes to an Observable, it begin to emit a sequence of `emum`s of type `Event`. For this reason Observable are also known as Sequences.

```
enum Event<Element> {
    case Next(Element)    // Next element is produced
    case Error(ErrorType) // Sequence terminates with error
    case Completed        // Sequence completes sucessfully
}
```

If the Observable emit `Event.Next` can still send events, but if Observable emit `Event.Error` or `Event.Completed`, Observable's emission is interrupted forever.


### Subscribing to Observables

There are several ways for subscribe to Observable.


### subscribe
*/

example("subscribe") {
    _ = sequenceOf(1, 2, 3, 4, 5, 6, 7, 8, 9)
        .subscribe{ event in
            print(event) // note the assotiated value of .Next is not unwrapped
        }
}

/*:
### subscribe II
*/

example("subscribe") {
    _ = sequenceOf(1, 2, 3, 4, 5, 6, 7, 8, 9)
        .subscribe(onNext: { integer in
                print("The integer is: \(integer)")
            },
            onError: { error in
                print("Oops an error occurred \(error)")
            },
            onCompleted: { () -> Void in
                print("SequenceComplete")
            },
            onDisposed: { () -> Void in
                print("I'm disposed")
            })
}


/*:
### subscribeNext
*/

example("subscribeNext") {
    _ = sequenceOf(1, 2, 3, 4, 5, 6, 7, 8, 9)
        .subscribeNext { integer in
            print(integer)
    }
}


/*:
### subscribeCompleted
*/

example("subscribeCompleted") {
    _ = sequenceOf(1, 2, 3, 4, 5, 6, 7, 8, 9)
        .subscribeCompleted {
            print("Completed")
        }
}


/*:
### subscribeError
*/

example("subscribeError") {
    _ = sequenceOf(1, 2, 3, 4, 5, 6, 7, 8, 9)
        .subscribeError { error in
            print("Oops an error occurred \(error)")
        }
}


//: More info in: [Observable Utility Operators](Observable_Utility_Operators)

//: [Next](@next)
