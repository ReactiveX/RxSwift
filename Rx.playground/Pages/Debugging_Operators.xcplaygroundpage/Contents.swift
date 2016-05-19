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
 # Debugging Operators
 Operators to help debug Rx code.
 ## `debug`
 Prints out all subscriptions, events, and disposals.
 */
example("debug") {
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
        .debug()
        .subscribeNext { print($0) }
        .addDisposableTo(disposeBag)
}
/*:
 ----
 ## `RxSwift.resourceCount`
 Provides a count of all Rx resource allocations, which is useful for detecting leaks during development.
 */
#if NOT_IN_PLAYGROUND
#else
example("RxSwift.resourceCount") {
    print(RxSwift.resourceCount)
    
    let disposeBag = DisposeBag()
    
    print(RxSwift.resourceCount)
    
    let variable = Variable("🍎")
    
    let subscription1 = variable.asObservable().subscribeNext { print($0) }
    
    print(RxSwift.resourceCount)
    
    let subscription2 = variable.asObservable().subscribeNext { print($0) }
    
    print(RxSwift.resourceCount)
    
    subscription1.dispose()
    
    print(RxSwift.resourceCount)
    
    subscription2.dispose()
    
    print(RxSwift.resourceCount)
}
    
print(RxSwift.resourceCount)
#endif
//: > `RxSwift.resourceCount` is not enabled by default, and should generally not be enabled in Release builds. [Click here](Enable_RxSwift.resourceCount) for instructions on how to enable it.

//: [Table of Contents](Table_of_Contents)
