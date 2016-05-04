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


/*:
### `skipWhile`

Discard items emitted by an Observable until a specified condition becomes false

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/skipWhile.png)

[More info in reactive.io website]( http://reactivex.io/documentation/operators/skipwhile.html )
*/
example("skipWhile") {
    let subscription = Observable.of(1, 2, 3, 4, 5, 6)
        .skipWhile { integer -> Bool in
            integer < 4
        }
        .subscribe {
            print($0)
    }
}


/*:
### `skipUntil`

Discard items emitted by an Observable until a second Observable emits an item

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/skipuntil.png)

[More info in reactive.io website]( http://reactivex.io/documentation/operators/skipuntil.html )
*/
example("skipUntil") {
    let ob1: Observable<Int> = Observable.create { observer -> Disposable in
        observer.on(.Next(0))
        delay(1) {
            observer.on(.Next(1))
        }
        delay(2) {
            observer.on(.Next(2))
        }
        delay(3) {
            observer.on(.Next(3))
        }
        delay(4) {
            observer.on(.Next(4))
        }
        delay(5) {
            observer.on(.Completed)
        }
        return NopDisposable.instance
    }
    
    let ob2: Observable<String> = Observable.create { observer -> Disposable in
        delay(2) {
            observer.on(.Next("beginTakeItems"))
        }
        delay(6) {
            observer.on(.Completed)
        }
        return NopDisposable.instance
    }
    
    let subscription = ob1
        .skipUntil(ob2)
        .subscribe {
            print($0)
    }
}

playgroundShouldContinueIndefinitely()


//: [Index](Index) - [Next >>](@next)
