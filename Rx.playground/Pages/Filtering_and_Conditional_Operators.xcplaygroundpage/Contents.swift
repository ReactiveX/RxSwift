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
# Filtering and Conditional Operators
Operators that selectively emit elements from a source `Observable` sequence.
## `filter`
Emits only those elements from an `Observable` sequence that meet the specified condition. [More info](http://reactivex.io/documentation/operators/filter.html)
![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/filter.png)
*/
example("filter") {
    let disposeBag = DisposeBag()
    
    Observable.of(
        "🐱", "🐰", "🐶",
        "🐸", "🐱", "🐰",
        "🐹", "🐸", "🐱")
        .filter {
            $0 == "🐱"
        }
        .subscribeNext { print($0) }
        .addDisposableTo(disposeBag)
}
/*:
 ----
## `distinctUntilChanged`
 Suppresses sequential duplicate elements emitted by an `Observable` sequence. [More info](http://reactivex.io/documentation/operators/distinct.html)
![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/distinct.png)
*/
example("distinctUntilChanged") {
    let disposeBag = DisposeBag()
    
    Observable.of("🐱", "🐷", "🐱", "🐱", "🐱", "🐵", "🐱")
        .distinctUntilChanged()
        .subscribeNext { print($0) }
        .addDisposableTo(disposeBag)
}
/*:
 ----
 ## `elementAt`
 Emits only the element at the specified index of all elements emitted by an `Observable` sequence. [More info](http://reactivex.io/documentation/operators/elementat.html)
 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/elementat.png)
 */
example("elementAt") {
    let disposeBag = DisposeBag()
    
    Observable.of("🐱", "🐰", "🐶", "🐸", "🐷", "🐵")
        .elementAt(3)
        .subscribeNext { print($0) }
        .addDisposableTo(disposeBag)
}
/*:
 ----
 ## `single`
 Emits only the first element (or the first element that meets a condition) emitted by an `Observable` sequence. Will throw an error if the `Observable` sequence does not emit exactly one element.
 */
example("single") {
    let disposeBag = DisposeBag()
    
    Observable.of("🐱", "🐰", "🐶", "🐸", "🐷", "🐵")
        .single()
        .subscribeNext { print($0) }
        .addDisposableTo(disposeBag)
}

example("single with conditions") {
    let disposeBag = DisposeBag()
    
    Observable.of("🐱", "🐰", "🐶", "🐸", "🐷", "🐵")
        .single { $0 == "🐸" }
        .subscribe { print($0) }
        .addDisposableTo(disposeBag)
    
    Observable.of("🐱", "🐰", "🐶", "🐱", "🐰", "🐶")
        .single { $0 == "🐰" }
        .subscribe { print($0) }
        .addDisposableTo(disposeBag)
    
    Observable.of("🐱", "🐰", "🐶", "🐸", "🐷", "🐵")
        .single { $0 == "🔵" }
        .subscribe { print($0) }
        .addDisposableTo(disposeBag)
}
/*:
 ----
 ## `take`
 Emits only the specified number of elements from the beginning of an `Observable` sequence. [More info](http://reactivex.io/documentation/operators/take.html)
 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/take.png)
 */
example("take") {
    let disposeBag = DisposeBag()
    
    Observable.of("🐱", "🐰", "🐶", "🐸", "🐷", "🐵")
        .take(3)
        .subscribeNext { print($0) }
        .addDisposableTo(disposeBag)
}
/*:
 ----
 ## `takeLast`
 Emits only the specified number of elements from the end of an `Observable` sequence. [More info](http://reactivex.io/documentation/operators/takelast.html)
 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/takelast.png)
 */
example("takeLast") {
    let disposeBag = DisposeBag()
    
    Observable.of("🐱", "🐰", "🐶", "🐸", "🐷", "🐵")
        .takeLast(3)
        .subscribeNext { print($0) }
        .addDisposableTo(disposeBag)
}
/*:
 ----
 ## `takeWhile`
 Emits elements from the beginning of an `Observable` sequence as long as the specified condition evaluates to `true`. [More info](http://reactivex.io/documentation/operators/takewhile.html)
 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/takewhile.png)
 */
example("takeWhile") {
    let disposeBag = DisposeBag()
    
    Observable.of(1, 2, 3, 4, 5, 6)
        .takeWhile { $0 < 4 }
        .subscribeNext { print($0) }
        .addDisposableTo(disposeBag)
}
/*:
 ----
 ## `takeUntil`
 Emits elements from a source `Observable` sequence until a reference `Observable` sequence emits an element. [More info](http://reactivex.io/documentation/operators/takeuntil.html)
 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/takeuntil.png)
 */
example("takeUntil") {
    let disposeBag = DisposeBag()
    
    let sourceSequence = PublishSubject<String>()
    let referenceSequence = PublishSubject<String>()
    
    sourceSequence
        .takeUntil(referenceSequence)
        .subscribe { print($0) }
        .addDisposableTo(disposeBag)
    
    sourceSequence.onNext("🐱")
    sourceSequence.onNext("🐰")
    sourceSequence.onNext("🐶")
    
    referenceSequence.onNext("🔴")
    
    sourceSequence.onNext("🐸")
    sourceSequence.onNext("🐷")
    sourceSequence.onNext("🐵")
}
/*:
 ----
 ## `skip`
 Suppresses emitting the specified number of elements from the beginning of an `Observable` sequence. [More info](http://reactivex.io/documentation/operators/skip.html)
 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/skip.png)
 */
example("skip") {
    let disposeBag = DisposeBag()
    
    Observable.of("🐱", "🐰", "🐶", "🐸", "🐷", "🐵")
        .skip(2)
        .subscribeNext { print($0) }
        .addDisposableTo(disposeBag)
}
/*:
 ----
 ## `skipWhile`
 Suppresses emitting the elements from the beginning of an `Observable` sequence that meet the specified condition. [More info](http://reactivex.io/documentation/operators/skipwhile.html)
 ![](http://reactivex.io/documentation/operators/images/skipWhile.c.png)
 */
example("skipWhile") {
    let disposeBag = DisposeBag()
    
    Observable.of(1, 2, 3, 4, 5, 6)
        .skipWhile { $0 < 4 }
        .subscribeNext { print($0) }
        .addDisposableTo(disposeBag)
}
/*:
 ----
 ## `skipWhileWithIndex`
 Suppresses emitting the elements from the beginning of an `Observable` sequence that meet the specified condition, and emits the remaining elements. The closure is also passed each element's index.
 */
example("skipWhileWithIndex") {
    let disposeBag = DisposeBag()
    
    Observable.of("🐱", "🐰", "🐶", "🐸", "🐷", "🐵")
        .skipWhileWithIndex { element, index in
            index < 3
        }
        .subscribeNext { print($0) }
        .addDisposableTo(disposeBag)
}
/*:
 ----
 ## `skipUntil`
 Suppresses emitting the elements from a source `Observable` sequence until a reference `Observable` sequence emits an element. [More info](http://reactivex.io/documentation/operators/skipuntil.html)
 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/skipuntil.png)
 */
example("skipUntil") {
    let disposeBag = DisposeBag()
    
    let sourceSequence = PublishSubject<String>()
    let referenceSequence = PublishSubject<String>()
    
    sourceSequence
        .skipUntil(referenceSequence)
        .subscribeNext { print($0) }
        .addDisposableTo(disposeBag)
    
    sourceSequence.onNext("🐱")
    sourceSequence.onNext("🐰")
    sourceSequence.onNext("🐶")
    
    referenceSequence.onNext("🔴")
    
    sourceSequence.onNext("🐸")
    sourceSequence.onNext("🐷")
    sourceSequence.onNext("🐵")
}

//: [Next](@next) - [Table of Contents](Table_of_Contents)
