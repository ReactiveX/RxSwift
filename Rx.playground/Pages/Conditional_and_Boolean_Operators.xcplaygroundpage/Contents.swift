//: [<< Previous](@previous) - [Index](Index)

import Cocoa
import RxSwift

/*:
## Conditional and Boolean Operators

Operators that evaluate one or more Observables or items emitted by Observables.



### `takeUntil`
Discard any items emitted by an Observable after a second Observable emits an item or terminates.

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/takeuntil.png)

[More info in reactive.io website]( http://reactivex.io/documentation/operators/takeuntil.html )
*/

example("takeUntil") {
    let observable1 = PublishSubject<Int>()
    let observable2 = PublishSubject<Int>()

    observable1
        .takeUntil(observable2)
        .subscribeNext { int in
            print(int)
    }

    sendNext(observable1, 1)
    sendNext(observable1, 2)
    sendNext(observable1, 3)
    sendNext(observable1, 4)

    sendNext(observable2, 1)

    sendNext(observable1, 5)
}


/*:
### `takeWhile`

Mirror items emitted by an Observable until a specified condition becomes false

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/takewhile.png)

[More info in reactive.io website]( http://reactivex.io/documentation/operators/takewhile.html )
*/
example("takeWhile") {

    let observable1 = PublishSubject<Int>()

    observable1
        .takeWhile { int in
            int < 4
        }
        .subscribeNext { int in
            print(int)
    }

    sendNext(observable1, 1)
    sendNext(observable1, 2)
    sendNext(observable1, 3)
    sendNext(observable1, 4)
    sendNext(observable1, 5)
}



//: [Index](Index) - [Next >>](@next)
