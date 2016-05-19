/*:
 > # IMPORTANT: To use **Rx.playground**:
 1. Open **Rx.xcworkspace**.
 1. Build the **RxSwift-OSX** scheme (**Product** → **Build**).
 1. Open **Rx** playground in the **Project navigator**.
 1. Show the Debug Area (**View** → **Debug Area** → **Show Debug Area**).
 ----
 [Previous](@previous) - [Table of Contents](Table_of_Contents)
 */
import RxSwift
/*:
# Error Handling Operators
Operators that help to recover from error notifications from an Observable.
## `catchErrorJustReturn`
Recovers from an Error event by returning an `Observable` sequence that emits a single element and then terminates. [More info](http://reactivex.io/documentation/operators/catch.html)
![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/catch.png)
*/
example("catchErrorJustReturn") {
    let disposeBag = DisposeBag()
    
    let sequenceThatFails = PublishSubject<String>()
    
    sequenceThatFails
        .catchErrorJustReturn("😊")
        .subscribe { print($0) }
        .addDisposableTo(disposeBag)
    
    sequenceThatFails.onNext("😬")
    sequenceThatFails.onNext("😨")
    sequenceThatFails.onNext("😡")
    sequenceThatFails.onNext("🔴")
    sequenceThatFails.onError(Error.Test)
}
/*:
 ----
 ## `catchError`
 Recovers from an Error event by switching to the provided recovery `Observable` sequence. [More info](http://reactivex.io/documentation/operators/catch.html)
 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/catch.png)
 */
example("catchError") {
    let disposeBag = DisposeBag()
    
    let sequenceThatErrors = PublishSubject<String>()
    let recoverySequence = PublishSubject<String>()
    
    sequenceThatErrors
        .catchError {
            print("Error:", $0)
            return recoverySequence
        }
        .subscribe { print($0) }
        .addDisposableTo(disposeBag)
    
    sequenceThatErrors.onNext("😬")
    sequenceThatErrors.onNext("😨")
    sequenceThatErrors.onNext("😡")
    sequenceThatErrors.onNext("🔴")
    sequenceThatErrors.onError(Error.Test)
    
    recoverySequence.onNext("😊")
}
/*:
 ----
 ## `retry`
 Recovers repeatedly Error events by rescribing to the `Observable` sequence, indefinitely. [More info](http://reactivex.io/documentation/operators/retry.html)
 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/retry.png)
 */
example("retry") {
    let disposeBag = DisposeBag()
    var count = 1
    
    let sequenceThatErrors = Observable<String>.create { observer in
        observer.onNext("🍎")
        observer.onNext("🍐")
        observer.onNext("🍊")
        
        if count == 1 {
            observer.onError(Error.Test)
            print("Error encountered")
            count += 1
        }
        
        observer.onNext("🐶")
        observer.onNext("🐱")
        observer.onNext("🐭")
        observer.onCompleted()
        
        return NopDisposable.instance
    }
    
    sequenceThatErrors
        .retry()
        .subscribeNext { print($0) }
        .addDisposableTo(disposeBag)
}
/*:
 ----
 ## `retry(_:)`
Recovers repeatedly from Error events by resubscribing to the `Observable` sequence, up to `maxAttemptCount` number of retries. [More info](http://reactivex.io/documentation/operators/retry.html)
 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/retry.png)
 */
example("retry maxAttemptCount") {
    let disposeBag = DisposeBag()
    var count = 1
    
    let sequenceThatErrors = Observable<String>.create { observer in
        observer.onNext("🍎")
        observer.onNext("🍐")
        observer.onNext("🍊")
        
        if count < 5 {
            observer.onError(Error.Test)
            print("Error encountered")
            count += 1
        }
        
        observer.onNext("🐶")
        observer.onNext("🐱")
        observer.onNext("🐭")
        observer.onCompleted()
        
        return NopDisposable.instance
    }
    
    sequenceThatErrors
        .retry(3)
        .subscribeNext { print($0) }
        .addDisposableTo(disposeBag)
}

//: [Next](@next) - [Table of Contents](Table_of_Contents)
