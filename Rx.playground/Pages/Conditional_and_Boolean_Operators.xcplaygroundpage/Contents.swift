/*:
> # IMPORTANT: To use `Rx.playground`, please:

1. Open `Rx.xcworkspace`
2. Build `RxSwift-OSX` scheme
3. And then open `Rx` playground in `Rx.xcworkspace` tree view.
4. Choose `View > Show Debug Area`
*/

//: [<< Previous](@previous) - [Index](Index)

import Cocoa
import RxSwift

/*:
## Conditional and Boolean Operators

Operators that evaluate one or more Observables or items emitted by Observables.

*/

/*:
### `takeUntil`
Discard any items emitted by an Observable after a second Observable emits an item or terminates.

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/takeuntil.png)

[More info in reactive.io website]( http://reactivex.io/documentation/operators/takeuntil.html )
*/

example("takeUntil") {
    let originalSequence = PublishSubject<Int>()
    let whenThisSendsNextWorldStops = PublishSubject<Int>()

    _ = originalSequence
        .takeUntil(whenThisSendsNextWorldStops)
        .subscribe {
            print($0)
        }

    originalSequence.on(.Next(1))
    originalSequence.on(.Next(2))
    originalSequence.on(.Next(3))
    originalSequence.on(.Next(4))

    whenThisSendsNextWorldStops.on(.Next(1))

    originalSequence.on(.Next(5))
}


/*:
### `takeWhile`

Mirror items emitted by an Observable until a specified condition becomes false

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/takewhile.png)

[More info in reactive.io website]( http://reactivex.io/documentation/operators/takewhile.html )
*/
example("takeWhile") {

    let sequence = PublishSubject<Int>()

    _ = sequence
        .takeWhile { int in
            int < 4
        }
        .subscribe {
            print($0)
        }

    sequence.on(.Next(1))
    sequence.on(.Next(2))
    sequence.on(.Next(3))
    sequence.on(.Next(4))
    sequence.on(.Next(5))
}



//: [Index](Index) - [Next >>](@next)
