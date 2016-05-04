//: [Index](Index) -  [<< Previous](@previous)

import RxSwift
import Foundation

/*:
# Subscribing to Observable sequences

There are several ways to subscribe to Observable sequences. Here are a few examples:

*/

example("subscribe to receive raw events") {
    let sequenceOfJustOneRedCircle/* : Observable<String> */ = Observable.just("🔴")
    
    let subscription = sequenceOfJustOneRedCircle
        .subscribe { event in
            print("Sequence emit \(event)")
        }
}


example("subscribe with optional callbacks per event type") {
    let sequenceOfJustOneRedCircle/* : Observable<String> */ = Observable.just("🔴")
    
    let subscription = sequenceOfJustOneRedCircle
        .subscribe(onNext: {
            print("Emission element of sequence is \($0)")
            },
            onError: {
                print("Oops an error occurred \($0)")
            },
            onCompleted: {
                print("Sequence completed")
            }, onDisposed: {
                print("Sequence disposed")
        })
}


example("subscribe only to emitted elements") {
    let sequenceOfJustOneRedCircle/* : Observable<String> */ = Observable.just("🔴")
    
    let subscription = sequenceOfJustOneRedCircle
        .subscribeNext {
            print("Emitted element of sequence is \($0)")
    }
}


example("subscribe only to the completed event") {
    let sequenceOfJustOneRedCircle/* : Observable<String> */ = Observable.just("🔴")
    
    let subscription = sequenceOfJustOneRedCircle
        .subscribeCompleted {
            print("Sequence completed")
    }
}


example("subscribe only to the error event, (no error ocurred so nothing is printed)") {
    let sequenceOfJustOneRedCircle/* : Observable<String> */ = Observable.just("🔴")
    
    let subscription = sequenceOfJustOneRedCircle
        .subscribeError { error in
            print("Oops an error occurred \(error)")
    }
}




/*:
## Side effects

It is not advisable to leave the Rx monad. (That is not pure reactive programming). But, if desired there is the `doOn` operator.


### `doOn`

register an action to take upon a variety of Observable lifecycle events

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/do.png)

[More info in reactive.io website]( http://reactivex.io/documentation/operators/do.html )
*/
example("doOn") {
    let sequenceOfInts = PublishSubject<String>()
    
    _ = sequenceOfInts
        .doOn {
            print("Intercepted event \($0)")
        }
        .subscribe {
            print("Sequence emit event \($0)")
    }
    
    sequenceOfInts.on(.Next("🍐"))
    sequenceOfInts.on(.Completed)
}

//: [Index](Index) - [Next >>](@next)
