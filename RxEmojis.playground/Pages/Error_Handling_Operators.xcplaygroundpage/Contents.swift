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
    let sequenceThatFails = PublishSubject<String>()
    let recoverySequence = Observable.of("🍎","🍐","🍊","🍋")

    _ = sequenceThatFails
        .catchError { error in
            return recoverySequence
        }
        .subscribe {
            print($0)
        }

    sequenceThatFails.on(.Next("🔴"))
    sequenceThatFails.on(.Next("🔵"))
    sequenceThatFails.on(.Next("⚪️"))
    sequenceThatFails.on(.Next("㊗️"))
    sequenceThatFails.on(.Error(NSError(domain: "Test", code: 0, userInfo: nil)))
}


example("catchError 2") {
    let sequenceThatFails = PublishSubject<String>()

    _ = sequenceThatFails
        .catchErrorJustReturn("🍋")
        .subscribe {
            print($0)
        }
    
    sequenceThatFails.on(.Next("🔴"))
    sequenceThatFails.on(.Next("🔵"))
    sequenceThatFails.on(.Next("⚪️"))
    sequenceThatFails.on(.Next("㊗️"))
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
    let funnyLookingSequence = Observable<String>.create { observer in
        let error = NSError(domain: "Test", code: 0, userInfo: nil)
        observer.on(.Next("🏉"))
        observer.on(.Next("🎱"))
        observer.on(.Next("🏐"))
        if count < 2 {
            observer.on(.Error(error))
            count += 1
        }
        observer.on(.Next("🏈"))
        observer.on(.Next("🏀"))
        observer.on(.Next("⚽️"))
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
