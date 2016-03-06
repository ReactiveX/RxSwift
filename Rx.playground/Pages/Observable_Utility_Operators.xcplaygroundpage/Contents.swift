/*:
> # IMPORTANT: To use `Rx.playground`, please:

1. Open `Rx.xcworkspace`
2. Build `RxSwift-OSX` scheme
3. And then open `Rx` playground in `Rx.xcworkspace` tree view.
4. Choose `View > Show Debug Area`
*/

//: [<< Previous](@previous) - [Index](Index)

import RxSwift
import Foundation
/*:
## Observable Utility Operators

A toolbox of useful Operators for working with Observables.

*/

/*:
### `subscribe`

[More info in reactive.io website]( http://reactivex.io/documentation/operators/subscribe.html )
*/

example("subscribe") {
    let sequenceOfInts = PublishSubject<Int>()

    _ = sequenceOfInts
        .subscribe {
            print($0)
        }

    sequenceOfInts.on(.Next(1))
    sequenceOfInts.on(.Completed)
}


/*:
There are several variants of the `subscribe` operator.
*/

/*:

### `subscribeNext`

*/
example("subscribeNext") {
    let sequenceOfInts = PublishSubject<Int>()

    _ = sequenceOfInts
        .subscribeNext {
            print($0)
        }

    sequenceOfInts.on(.Next(1))
    sequenceOfInts.on(.Completed)
}


/*:

### `subscribeCompleted`

*/
example("subscribeCompleted") {
    let sequenceOfInts = PublishSubject<Int>()

    _ = sequenceOfInts
        .subscribeCompleted {
            print("It's completed")
        }

    sequenceOfInts.on(.Next(1))
    sequenceOfInts.on(.Completed)
}


/*:

### `subscribeError`

*/
example("subscribeError") {
    let sequenceOfInts = PublishSubject<Int>()

    _ = sequenceOfInts
        .subscribeError { error in
            print(error)
        }

    sequenceOfInts.on(.Next(1))
    sequenceOfInts.on(.Error(NSError(domain: "Examples", code: -1, userInfo: nil)))
}


/*:
### `doOn`

register an action to take upon a variety of Observable lifecycle events

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/do.png)

[More info in reactive.io website]( http://reactivex.io/documentation/operators/do.html )
*/
example("doOn") {
    let sequenceOfInts = PublishSubject<Int>()

    _ = sequenceOfInts
        .doOn {
            print("Intercepted event \($0)")
        }
        .subscribe {
            print($0)
        }

    sequenceOfInts.on(.Next(1))
    sequenceOfInts.on(.Completed)
}

//: [Index](Index) - [Next >>](@next)
