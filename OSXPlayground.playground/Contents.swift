import Cocoa
import RxSwift

/*:
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
`empty` creates an observable that contains no objects. The only message it sends is the `.Completed` message.
*/

let emptyObservable: Observable<Int> = empty()

let emptySubscriber = emptyObservable >- subscribe { event in
    switch event {
    case .Next(let box):
        println("\(box.value)")
    case .Completed:
        println("completed")
    case .Error(let error):
        println("\(error)")
    }
}

/*:
As you can see, no values are ever sent to the subscriber of an empty observable. It just completes and is done.
*/

/*:
### never
`never` creates an observable that contains no objects and never completes or errors out.
*/

let neverObservable: Observable<String> = never()

let neverSubscriber = neverObservable >- subscribe { _ in
    println("This block is never called.")
}

/*:
### returnElement/just
These two functions behave identically. They send two messages to subscribers. The first message is the value and the second message is `.Complete`.
*/

let oneObservable = just(32)

let oneObservableSubscriber = oneObservable >- subscribe { event in
    switch event {
    case .Next(let box):
        println("\(box.value)")
    case .Completed:
        println("completed")
    case .Error(let error):
        println("\(error)")
    }
}

/*:
Here we see that the `.Next` event is sent just once, then the `.Completed` event is sent.
*/

/*:
### returnElements
Now we are getting to some more interesting ways to create an Observable. This function creates an observable that produces a number of values before completing.
*/

let multipleObservable = returnElements(0, 1, 2, 3, 4, 5, 6, 7, 8, 9)

let multipleObservableSubscriber = multipleObservable >- subscribe { event in
    switch event {
    case .Next(let box):
        println("\(box.value)")
    case .Completed:
        println("completed")
    case .Error(let error):
        println("\(error)")
    }
}

/*:
With the above, you will see that the `.Next` event was sent ten times, once for each element. Then `.Complete` was sent.
*/

/*:
Now these functions are all well and good, but the really useful ones are in the RxCocoa library.
`rx_observe` exist on every NSObject and wraps KVO.
`rx_tap` exists on buttons and wraps @IBActions
`rx_notification` wraps NotificationCenter events
... and so on.

Take some time and search for code matching `-> Observable` in the RxCocoa framework to get a sense of how every action can be modeled as an observable. You can even create your own functions that make Observable objects.

## Subscribing
Up to this point, I have only used the `subscribe` method to listen to Observables, but there are several others.
*/

let nextOnlySubscriber = multipleObservable >- subscribeNext { value in
    println("\(value)")
}

/*:
With the above we only interest ourselves in the values returned by the observable without regard to whether/when it completes or errors. Many of the observables that we use have an indefinite lifespan. There is also `subscribeCompleted` and `subscribeError` for when you are looking for when an observable will stop sending.

Also note that you can have multiple subscribers following to the same observable (as I did in the example above.) All the subscribers will be notified when an event occurs.
*/

/*:
## Reducing a sequence
Now that you understand how to create Observables and subscribe to them. Let's look at the various ways we can manipulate an observable sequence. First lets examine ways to reduce a sequence into fewer events.

### where/filter
The most common way to reduce a sequence is to apply a filter to it and the most generic of these is `where` or `filter`. You will see in the code below that the messages containing odd numbers are being removed so the subscriber wont see them.
*/

var onlyEvensSubscriber = multipleObservable
    >- filter {
        $0 % 2 == 0
    }
    >- subscribeNext { value in
        println("\(value)")
}

/*:
### distinctUntilChanged
This filter tracks the last value emitted and removes like values. This function is good for reducing noise in a sequence.
*/

let distinctUntilChangedSubscriber = returnElements(1, 2, 3, 1, 1, 4)
    >- distinctUntilChanged
    >- subscribeNext { value in
        println("\(value)")
}

/*:
In the example above, the values 1, 2, 3, 1, 4 will be printed. The extra 1 will be filtered out.
There are several different versions of `distinctUntilChanged`. Have a look in the file Observable+Single.swift to review them.
*/

/*:
## Aggregating a sequence

### `aggregate`
This function will perform a function on each element in the sequence until it is completed, then send a message with the aggregate value. It works much like the Swift `reduce` function works on sequences.
*/

let aggregateSubscriber = multipleObservable
    >- aggregate(0, +)
    >- subscribeNext { value in
        println("\(value)")
}

/*:
To be continued...
*/
