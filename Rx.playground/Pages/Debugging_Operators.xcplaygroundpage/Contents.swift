/*:
 > # IMPORTANT: To use **Rx.playground**:
 1. Open **Rx.xcworkspace**.
 1. Build the **RxSwift-macOS** scheme (**Product** → **Build**).
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
            observer.onError(TestError.test)
            print("Error encountered")
            count += 1
        }
        
        observer.onNext("🐶")
        observer.onNext("🐱")
        observer.onNext("🐭")
        observer.onCompleted()
        
        return Disposables.create()
    }
    
    sequenceThatErrors
        .retry(3)
        .debug()
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
}
/*:
 ----
 ## `RxSwift.Resources.total`
 Provides a count of all Rx resource allocations, which is useful for detecting leaks during development.
 */
#if NOT_IN_PLAYGROUND
#else
example("RxSwift.Resources.total") {
    print(RxSwift.Resources.total)
    
    let disposeBag = DisposeBag()
    
    print(RxSwift.Resources.total)
    
    let variable = Variable("🍎")
    
    let subscription1 = variable.asObservable().subscribe(onNext: { print($0) })
    
    print(RxSwift.Resources.total)
    
    let subscription2 = variable.asObservable().subscribe(onNext: { print($0) })
    
    print(RxSwift.Resources.total)
    
    subscription1.dispose()
    
    print(RxSwift.Resources.total)
    
    subscription2.dispose()
    
    print(RxSwift.Resources.total)
}
    
print(RxSwift.Resources.total)
#endif
//: > `RxSwift.Resources.total` is not enabled by default, and should generally not be enabled in Release builds. [Click here](Enable_RxSwift.Resources.total) for instructions on how to enable it.

//: [Next](@next) - [Table of Contents](Table_of_Contents)
