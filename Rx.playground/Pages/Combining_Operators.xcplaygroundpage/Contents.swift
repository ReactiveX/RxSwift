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
# Combination Operators
Operators that combine multiple source `Observable`s into a single `Observable`.
## `startWith`
Emits the specified sequence of elements before beginning to emit the elements from the source `Observable`. [More info](http://reactivex.io/documentation/operators/startwith.html)
![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/startwith.png)
*/
example("startWith") {
    let disposeBag = DisposeBag()
    
    Observable.of("🐶", "🐱", "🐭", "🐹")
        .startWith("1️⃣")
        .startWith("2️⃣")
        .startWith("3️⃣", "🅰️", "🅱️")
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
}
/*:
 > As this example demonstrates, `startWith` can be chained on a last-in-first-out basis, i.e., each successive `startWith`'s elements will be prepended before the prior `startWith`'s elements.
 ----
 ## `merge`
 Combines elements from source `Observable` sequences into a single new `Observable` sequence, and will emit each element as it is emitted by each source `Observable` sequence. [More info](http://reactivex.io/documentation/operators/merge.html)
 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/merge.png)
 */
example("merge") {
    let disposeBag = DisposeBag()
    
    let subject1 = PublishSubject<String>()
    let subject2 = PublishSubject<String>()
    
    Observable.of(subject1, subject2)
        .merge()
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
    
    subject1.onNext("🅰️")
    
    subject1.onNext("🅱️")
    
    subject2.onNext("①")
    
    subject2.onNext("②")
    
    subject1.onNext("🆎")
    
    subject2.onNext("③")
}
/*:
 ----
 ## `zip`
 Combines up to 8 source `Observable` sequences into a single new `Observable` sequence, and will emit from the combined `Observable` sequence the elements from each of the source `Observable` sequences at the corresponding index. [More info](http://reactivex.io/documentation/operators/zip.html)
 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/zip.png)
 */
example("zip") {
    let disposeBag = DisposeBag()
    
    let stringSubject = PublishSubject<String>()
    let intSubject = PublishSubject<Int>()
    
    Observable.zip(stringSubject, intSubject) { stringElement, intElement in
        "\(stringElement) \(intElement)"
        }
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
    
    stringSubject.onNext("🅰️")
    stringSubject.onNext("🅱️")
    
    intSubject.onNext(1)
    
    intSubject.onNext(2)
    
    stringSubject.onNext("🆎")
    intSubject.onNext(3)
}
/*:
 ----
 ## `combineLatest`
 Combines up to 8 source `Observable` sequences into a single new `Observable` sequence, and will begin emitting from the combined `Observable` sequence the latest elements of each source `Observable` sequence once all source sequences have emitted at least one element, and also when any of the source `Observable` sequences emits a new element. [More info](http://reactivex.io/documentation/operators/combinelatest.html)
 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/combinelatest.png)
 */
example("combineLatest") {
    let disposeBag = DisposeBag()
    
    let stringSubject = PublishSubject<String>()
    let intSubject = PublishSubject<Int>()
    
    Observable.combineLatest(stringSubject, intSubject) { stringElement, intElement in
            "\(stringElement) \(intElement)"
        }
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
    
    stringSubject.onNext("🅰️")
    
    stringSubject.onNext("🅱️")
    intSubject.onNext(1)
    
    intSubject.onNext(2)
    
    stringSubject.onNext("🆎")
}
//: There is also a variant of `combineLatest` that takes an `Array` (or any other collection of `Observable` sequences):
example("Array.combineLatest") {
    let disposeBag = DisposeBag()
    
    let stringObservable = Observable.just("❤️")
    let fruitObservable = Observable.from(["🍎", "🍐", "🍊"])
    let animalObservable = Observable.of("🐶", "🐱", "🐭", "🐹")
    
    Observable.combineLatest([stringObservable, fruitObservable, animalObservable]) {
            "\($0[0]) \($0[1]) \($0[2])"
        }
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
}
/*:
 > Because the `combineLatest` variant that takes a collection passes an array of values to the selector function, it requires that all source `Observable` sequences are of the same type.
 ----
 ## `switchLatest`
 Transforms the elements emitted by an `Observable` sequence into `Observable` sequences, and emits elements from the most recent inner `Observable` sequence. [More info](http://reactivex.io/documentation/operators/switch.html)
 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/switch.png)
 */
example("switchLatest") {
    let disposeBag = DisposeBag()
    
    let subject1 = BehaviorSubject(value: "⚽️")
    let subject2 = BehaviorSubject(value: "🍎")
    
    let subjectsSubject = BehaviorSubject(value: subject1)
        
    subjectsSubject.asObservable()
        .switchLatest()
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
    
    subject1.onNext("🏈")
    subject1.onNext("🏀")
    
    subjectsSubject.onNext(subject2)
    
    subject1.onNext("⚾️")
    
    subject2.onNext("🍐")
}
/*:
 > In this example, adding ⚾️ onto `subject1` after adding `subject2` to `subjectsSubject` has no effect, because only the most recent inner `Observable` sequence (`subject2`) will emit elements.
 */

//: [Next](@next) - [Table of Contents](Table_of_Contents)
