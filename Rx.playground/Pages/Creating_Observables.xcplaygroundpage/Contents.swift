/*:
 > # IMPORTANT: To use `Rx.playground`, please:
 
 1. Open `Rx.xcworkspace`
 2. Build `RxSwift-OSX` scheme
 3. And then open `Rx` playground in `Rx.xcworkspace` tree view.
 4. Choose `View > Show Debug Area`
 */

//: [Index](Index) - [<< Previous](@previous)

import RxSwift
import Foundation


/*:
 
 # Creating Observable sequences
 
 There are a number of functions available to make Observables. In the rest of this page, we review several methods used to create Observable sequences.
 
 
 ### empty
 `empty` creates an empty sequence. The only message it sends is the `.Completed` message.
 */

example("empty") {
    let emptySequence/* : Observable<Int> */ = Observable<Int>.empty()
    
    let subscription = emptySequence
        .subscribe { event in
            print(event)
        }
}


/*:
 ### never
 `never` creates a sequence that never sends any element or completes.
 */

example("never") {
    let neverSequence/* : Observable<Int> */ = Observable<Int>.never()
    
    let subscription = neverSequence
        .subscribe { _ in
            print("This block is never called.")
        }
}



/*:
 ### just
 `just` represents a sequence that contains just one element. It sends two messages to subscribers. The first message is the value of a single element and the second message is `.Completed`.
 */

example("just") {
    let sequenceOfJustOneRedCircle/* : Observable<String> */ = Observable<String>.just("🔴")
    
    let subscription = sequenceOfJustOneRedCircle
        .subscribe { event in
            print(event)
        }
}

/*:
 ### sequenceOf
 `sequenceOf` creates a sequence of a fixed number of elements.
 */

example("sequenceOf") {
    let sequenceOfFourCircles/* : Observable<String> */ = Observable.of("🐶","🐱","🐭","🐹")
    
    let subscription = sequenceOfFourCircles
        .subscribe { event in
            print(event)
        }
}

/*:
 ### toObservable
 `toObservable` creates a sequence out of an array.
 */

example("toObservable") {
    let sequenceOfFourCircles/* : Observable<String> */ = ["🐶","🐱","🐭","🐹"].toObservable()
    
    let subscription = sequenceOfFourCircles
        .subscribe { event in
            print(event)
        }
}

/*:
 ### create
 `create` creates sequence using a Swift closure. This examples creates a custom version of the `just` operator.
 */

example("create") {
    let myJust = { (singleElement: String) -> Observable<String> in
        return Observable.create { observer in
            observer.on(.Next(singleElement))
            observer.on(.Completed)
            
            return NopDisposable.instance
        }
    }
    
    let sequenceOfJustOneRedCircle/* : Observable<String> */ = myJust("🔴")
    
    let subscription = sequenceOfJustOneRedCircle
        .subscribe { event in
            print(event)
        }
}

/*:
 ### generate
 `generate` creates a sequence that generates values for as long as the provided condition evaluates to `true`.
 */

example("generate") {
    let generated/* : Observable<Int> */ = Observable.generate(
        initialState: 0,
        condition: { $0 < 3 },
        iterate: { $0 + 1 }
    )
    
    let subscription = generated
        .subscribe { event in
            print(event)
        }
    
}

/*:
 ### error
 create an Observable that emits no items and immediately terminates with an error
 */

example("failWith") {
    let error = NSError(domain: "Test", code: -1, userInfo: nil)
    
    let erroredSequence/* : Observable<Int> */ = Observable<Int>.error(error)
    
    let subscription = erroredSequence
        .subscribe { event in
            print(event)
        }
}

/*:
 ### `deferred`
 
 do not create the Observable until the observer subscribes, and create a fresh Observable for each observer
 
 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/defer.png)
 
 [More info in reactive.io website]( http://reactivex.io/documentation/operators/defer.html )
 */
example("deferred") {
    let deferredSequence = Observable<String>.deferred {
        print("creating")
        return Observable.create { observer in
            print("emmiting")
            observer.on(.Next("🔴"))
            observer.on(.Next("🐱"))
            observer.on(.Next("🐵"))
            
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
    let rangeSequence/* : Observable<Int> */ = Observable.range(start: 3, count: 3)
    
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
    let repeatedSequence/* : Observable<String> */  = Observable.repeatElement("🔵", scheduler: MainScheduler.instance)
        .take(5) // for example take can limit the number of repetitions
    
    let subscription = repeatedSequence
        .subscribe { event in
            print(event)
        }
}

playgroundShouldContinueIndefinitely()

/*:
 There are many more useful methods in the RxCocoa library, so check them out:
 * `rx_observe` exists on every NSObject and wraps KVO.
 * `rx_tap` exists on buttons and wraps @IBActions
 * `rx_notification` wraps NotificationCenter events
 * ... and many others
 */

//: [Index](Index) - [Next >>](@next)
