//: [<< Index](@previous)

import RxSwift
import Foundation


/*:

## Creating Observables

Operators that originate new Observables.


### empty
Creates an empty sequence. The only message it sends is the `.Completed` message.
*/

example("empty") {
    let emptySequence: Observable<Int> = empty()

    let subscription = emptySequence
        .subscribe { event in
            print(event)
        }
}


/*:
### never
Creates a sequence that never sends any element or completes.
*/

example("never") {
    let neverSequence: Observable<String> = never()

    let subscription = neverSequence
        .subscribe { _ in
            print("This block is never called.")
        }
}

/*:
### just
Represents sequence that contains one element. It sends two messages to subscribers. The first message is the value of single element and the second message is `.Completed`.
*/

example("just") {
    let singleElementSequence = just(32)
    
    let subscription = singleElementSequence
        .subscribe { event in
            print(event)
        }
}

/*:
### sequenceOf
Creates a sequence of a fixed number of elements.
*/

example("sequenceOf") {
    let sequenceOfElements/* : Observable<Int> */ = sequenceOf(0, 1, 2, 3, 4, 5, 6, 7, 8, 9)
    
    let subscription = sequenceOfElements
        .subscribe { event in
            print(event)
        }
}

/*:
### toObservable a.k.a. from
Creates a sequence from `SequenceType`
*/

example("toObservable") {
    let sequenceFromArray = [1, 2, 3, 4, 5].toObservable()

    let subscription = sequenceFromArray
        .subscribe { event in
            print(event)
        }
}

/*:
### create
Creates sequence using Swift closure. This examples creates custom version of `just` operator.
*/

example("create") {
    let myJust = { (singleElement: Int) -> Observable<Int> in
        return create { observer in
            observer.on(.Next(singleElement))
            observer.on(.Completed)
            
            return NopDisposable.instance
        }
    }
    
    let subscription = myJust(5)
        .subscribe { event in
            print(event)
        }
}

/*:
### failWith
Create an Observable that emits no items and terminates with an error
*/

example("failWith") {
    let error = NSError(domain: "Test", code: -1, userInfo: nil)
    
    let erroredSequence: Observable<Int> = failWith(error)
    
    let subscription = erroredSequence
        .subscribe { event in
            print(event)
        }
}

/*:
### `deferred`
Do not create the Observable until the observer subscribes, and create a fresh Observable for each observer

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/defer.png)

[More info in reactive.io website]( http://reactivex.io/documentation/operators/defer.html )
*/
example("deferred") {
    let deferredSequence: Observable<Int> = deferred {
        print("creating")
        return create { observer in
            print("emmiting")
            observer.on(.Next(0))
            observer.on(.Next(1))
            observer.on(.Next(2))

            return NopDisposable.instance
        }
    }

    _ = deferredSequence
        .subscribe { event in
            print(event)
    }

    _ = deferredSequence
        .subscribe { event in
            print(event)
        }
}

/*:
### range
create an Observable that emits a particular range of sequential integers

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/range.png)
*/

example("range") {
    let rangeSequence = range(3, 3)
    
    let subscription = rangeSequence
        .subscribe { event in
            print(event)
    }
}

/*:
### repeatElement
Create an Observable that emits a particular item multiple times

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/repeat.png)
*/

example("repeatElement") {
    let repeatedSequence = repeatElement("🔵", MainScheduler.sharedInstance)
        .take(5) // for example take can limit number of repetitions
    
    let subscription = repeatedSequence
        .subscribe { event in
            print(event)
        }
}

playgroundShouldContinueIndefinitely()

/*:
There is a lot more useful methods in the RxCocoa library, so check them out: 
* `rx_observe` exist on every NSObject and wraps KVO.
* `rx_tap` exists on buttons and wraps @IBActions
* `rx_notification` wraps NotificationCenter events
* ... and many others
*/

//: [Index](Index) - [Next >>](@next)
