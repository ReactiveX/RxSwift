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
## Error Handling Operators

Operators that help to recover from error notifications from an Observable.
*/

/*:
### `catchError`

Recover from an `Error` notification by continuing the sequence without error

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/catch.png)

[More info in reactive.io website]( http://reactivex.io/documentation/operators/catch.html )
*/
example("catchError 1") {
    let sequenceThatFails = PublishSubject<Int>()
    let recoverySequence = Observable.of(100, 200, 300, 400)

    _ = sequenceThatFails
        .catchError { error in
            return recoverySequence
        }
        .subscribe {
            print($0)
        }

    sequenceThatFails.on(.Next(1))
    sequenceThatFails.on(.Next(2))
    sequenceThatFails.on(.Next(3))
    sequenceThatFails.on(.Next(4))
    sequenceThatFails.on(.Error(NSError(domain: "Test", code: 0, userInfo: nil)))
}


example("catchError 2") {
    let sequenceThatFails = PublishSubject<Int>()

    _ = sequenceThatFails
        .catchErrorJustReturn(100)
        .subscribe {
            print($0)
        }

    sequenceThatFails.on(.Next(1))
    sequenceThatFails.on(.Next(2))
    sequenceThatFails.on(.Next(3))
    sequenceThatFails.on(.Next(4))
    sequenceThatFails.on(.Error(NSError(domain: "Test", code: 0, userInfo: nil)))
}



/*:
### `retry`

If a source Observable emits an error, resubscribe to it in the hopes that it will complete without error

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/retry.png)

[More info in reactive.io website]( http://reactivex.io/documentation/operators/retry.html )
*/
example("retry") {
    var count = 1 // bad practice, only for example purposes
    let funnyLookingSequence = Observable<Int>.create { observer in
        let error = NSError(domain: "Test", code: 0, userInfo: nil)
        observer.on(.Next(0))
        observer.on(.Next(1))
        observer.on(.Next(2))
        if count < 2 {
            observer.on(.Error(error))
            count += 1
        }
        observer.on(.Next(3))
        observer.on(.Next(4))
        observer.on(.Next(5))
        observer.on(.Completed)

        return NopDisposable.instance
    }

    _ = funnyLookingSequence
        .retry()
        .subscribe {
            print($0)
        }
}


//: [Index](Index) - [Next >>](@next)
