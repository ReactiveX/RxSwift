//: [<< Previous](@previous) - [Index](Index)

import RxSwift

/*:
## Observable Utility Operators

A toolbox of useful Operators for working with Observables.



### `subscribe`

Create an Disposable which listen events from source Observable, the given closure take the Even and is responsible for the actions to perform when the it is produced.
[More info in reactive.io website]( http://reactivex.io/documentation/operators/subscribe.html )
*/

example("subscribe") {
    let intOb1 = PublishSubject<Int>()

    intOb1
        .subscribe { event in
            print(event)
        }

    sendNext(intOb1, 1)
    sendCompleted(intOb1)
}


/*:
There are several variants of the `subscribe` operator. They works over one posible event type:



### `subscribeNext`

Create an Disposable which listen only Next event from source Observable, the given closure take the Even's value and is responsible for the actions to perform only when the Next even is produced.
*/
example("subscribeNext") {
    let intOb1 = PublishSubject<Int>()

    intOb1
        .subscribeNext { int in
            print(int)
        }

    sendNext(intOb1, 1)
    sendCompleted(intOb1)
}


/*:


### `subscribeCompleted`

Create an Disposable which listen only Completed event from source Observable, the given closure take the Even's value and is responsible for the actions to perform only when the Completed even is produced.
*/
example("subscribeCompleted") {
    let intOb1 = PublishSubject<Int>()

    intOb1
        .subscribeCompleted {
            print("It's completed")
        }

    sendNext(intOb1, 1)
    sendCompleted(intOb1)
}


/*:

### `subscribeError

Create an Disposable which listen only Error event from source Observable, the given closure take the Even's value and is responsible for the actions to perform only when the Error even is produced
*/
example("subscribeError") {
    let intOb1 = PublishSubject<Int>()

    intOb1
        .subscribeError { error in
            print(error)
        }

    sendNext(intOb1, 1)
    sendError(intOb1, NSError(domain: "Examples", code: -1, userInfo: nil))
}


/*:
### `tap` a.k.a. `do`

Returns the same source Observable but the given closure responsible for the actions to perform when the even is produced. The gived closure obtain the event produced by the source observable

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/do.png)

[More info in reactive.io website]( http://reactivex.io/documentation/operators/do.html )
*/
example("tap") {
    let intOb1 = PublishSubject<Int>()

    let intOb2 = intOb1
        .tap { event in
            print("first \(event)")
        }

    intOb2
        .subscribeNext { int in
            print("second \(int)")
        }

    sendNext(intOb1, 1)
}


/*:
### `tapOnNext` a.k.a. `doOnNext`

It is a variant of the `tap` operator. Returns the same source Observable but the given closure responsible for the actions to perform when the Next even is produced. The gived closure obtain the value of the Next event produced by the source observable.
[More info in reactive.io website]( http://reactivex.io/documentation/operators/do.html )
*/
example("tapOnNext") {
    let intOb1 = PublishSubject<Int>()

    let intOb2 = intOb1
        .tapOnNext { int in
            print("first \(int)")
        }

    intOb2
        .subscribeNext { int in
            print("second \(int)")
        }

    sendNext(intOb1, 1)
}


//: [Index](Index) - [Next >>](@next)
