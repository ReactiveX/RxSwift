//: [<< Previous](@previous) - [Index](Index)

import RxSwift

/*:
## Transforming Observables

Operators that transform items that are emitted by an Observable.
*/

/*:
### `map` / `select`

Transform the items emitted by an Observable by applying a function to each item

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/map.png)

[More info in reactive.io website]( http://reactivex.io/documentation/operators/map.html )
*/

example("map") {
    let originalSequence = Observable.of(Character("A"), Character("B"), Character("C"))

    _ = originalSequence
        .map { char in
            char.hashValue
        }
        .subscribe { print($0) }
}


/*:
### `flatMap`

Transform the items emitted by an Observable into Observables, then flatten the emissions from those into a single Observable

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/flatmap.png)

[More info in reactive.io website]( http://reactivex.io/documentation/operators/flatmap.html )
*/
example("flatMap") {
    let sequenceInt = Observable.of(1, 2, 3)

    let sequenceString = Observable.of("A", "B", "C", "D", "E", "F", "--")

    _ = sequenceInt
        .flatMap { (x:Int) -> Observable<String> in
            print("from sequenceInt \(x)")
            return sequenceString
        }
        .subscribe {
            print($0)
        }
}


/*:
### `scan`

Apply a function to each item emitted by an Observable, sequentially, and emit each successive value

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/scan.png)

[More info in reactive.io website]( http://reactivex.io/documentation/operators/scan.html )
*/
example("scan") {
    let sequenceToSum = Observable.of(0, 1, 2, 3, 4, 5)

    _ = sequenceToSum
        .scan(0) { acum, elem in
            acum + elem
        }
        .subscribe {
            print($0)
        }
}


//: [Index](Index) - [Next >>](@next)
