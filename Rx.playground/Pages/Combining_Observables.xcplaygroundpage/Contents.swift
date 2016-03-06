/*:
> # IMPORTANT: To use `Rx.playground`, please:

1. Open `Rx.xcworkspace`
2. Build `RxSwift-OSX` scheme
3. And then open `Rx` playground in `Rx.xcworkspace` tree view.
4. Choose `View > Show Debug Area`
*/

//: [<< Previous](@previous) - [Index](Index)

import RxSwift

/*:
## Combination operators

Operators that work with multiple source Observables to create a single Observable.
*/

/*:

### `startWith`

emit a specified sequence of items before beginning to emit the items from the source Observable

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/startwith.png)

[More info in reactive.io website]( http://reactivex.io/documentation/operators/startwith.html )
*/
example("startWith") {

    let subscription = Observable.of(4, 5, 6, 7, 8, 9)
        .startWith(3)
        .startWith(2)
        .startWith(1)
        .startWith(0)
        .subscribe {
            print($0)
        }
}


/*:
### `combineLatest`

when an item is emitted by either of two Observables, combine the latest item emitted by each Observable via a specified function and emit items based on the results of this function

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/combinelatest.png)

[More info in reactive.io website]( http://reactivex.io/documentation/operators/combinelatest.html )

*/
example("combineLatest 1") {
    let intOb1 = PublishSubject<String>()
    let intOb2 = PublishSubject<Int>()

    _ = Observable.combineLatest(intOb1, intOb2) {
        "\($0) \($1)"
        }
        .subscribe {
            print($0)
        }

    intOb1.on(.Next("A"))

    intOb2.on(.Next(1))

    intOb1.on(.Next("B"))

    intOb2.on(.Next(2))
}


//: To produce output, at least one element has to be received from each sequence in arguements.

example("combineLatest 2") {
    let intOb1 = Observable.just(2)
    let intOb2 = Observable.of(0, 1, 2, 3, 4)

    _ = Observable.combineLatest(intOb1, intOb2) {
            $0 * $1
        }
        .subscribe {
            print($0)
        }
}



//: Combine latest has versions with more than 2 arguments.

example("combineLatest 3") {
    let intOb1 = Observable.just(2)
    let intOb2 = Observable.of(0, 1, 2, 3)
    let intOb3 = Observable.of(0, 1, 2, 3, 4)

    _ = Observable.combineLatest(intOb1, intOb2, intOb3) {
            ($0 + $1) * $2
        }
        .subscribe {
            print($0)
        }
}



//: Combinelatest version that allows combining sequences with different types.

example("combineLatest 4") {
    let intOb = Observable.just(2)
    let stringOb = Observable.just("a")
    
    _ = Observable.combineLatest(intOb, stringOb) {
            "\($0) " + $1
        }
        .subscribe {
            print($0)
    }
}


//: `combineLatest` extension method for Array of `ObservableType` conformable types
//: The array must be formed by `Observables` of the same type.

example("combineLatest 5") {
    let intOb1 = Observable.just(2)
    let intOb2 = Observable.of(0, 1, 2, 3)
    let intOb3 = Observable.of(0, 1, 2, 3, 4)
    
    _ = [intOb1, intOb2, intOb3].combineLatest { intArray -> Int in
            Int((intArray[0] + intArray[1]) * intArray[2])
        }
        .subscribe { (event: Event<Int>) -> Void in
            print(event)
        }
}



/*:
### `zip`

combine the emissions of multiple Observables together via a specified function and emit single items for each combination based on the results of this function

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/zip.png)

[More info in reactive.io website](http://reactivex.io/documentation/operators/zip.html)
*/
example("zip 1") {
    let intOb1 = PublishSubject<String>()
    let intOb2 = PublishSubject<Int>()

    _ = Observable.zip(intOb1, intOb2) {
        "\($0) \($1)"
        }
        .subscribe {
            print($0)
        }

    intOb1.on(.Next("A"))

    intOb2.on(.Next(1))

    intOb1.on(.Next("B"))

    intOb1.on(.Next("C"))

    intOb2.on(.Next(2))
}


example("zip 2") {
    let intOb1 = Observable.just(2)

    let intOb2 = Observable.of(0, 1, 2, 3, 4)

    _ = Observable.zip(intOb1, intOb2) {
            $0 * $1
        }
        .subscribe {
            print($0)
        }
}


example("zip 3") {
    let intOb1 = Observable.of(0, 1)
    let intOb2 = Observable.of(0, 1, 2, 3)
    let intOb3 = Observable.of(0, 1, 2, 3, 4)

    _ = Observable.zip(intOb1, intOb2, intOb3) {
            ($0 + $1) * $2
        }
        .subscribe {
            print($0)
        }
}




/*:
### `merge`

combine multiple Observables into one by merging their emissions

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/merge.png)

[More info in reactive.io website]( http://reactivex.io/documentation/operators/merge.html )
*/
example("merge 1") {
    let subject1 = PublishSubject<Int>()
    let subject2 = PublishSubject<Int>()

    _ = Observable.of(subject1, subject2)
        .merge()
        .subscribeNext { int in
            print(int)
        }

    subject1.on(.Next(20))
    subject1.on(.Next(40))
    subject1.on(.Next(60))
    subject2.on(.Next(1))
    subject1.on(.Next(80))
    subject1.on(.Next(100))
    subject2.on(.Next(1))
}


example("merge 2") {
    let subject1 = PublishSubject<Int>()
    let subject2 = PublishSubject<Int>()

    _ = Observable.of(subject1, subject2)
        .merge(maxConcurrent: 2)
        .subscribe {
            print($0)
        }

    subject1.on(.Next(20))
    subject1.on(.Next(40))
    subject1.on(.Next(60))
    subject2.on(.Next(1))
    subject1.on(.Next(80))
    subject1.on(.Next(100))
    subject2.on(.Next(1))
}



/*:
### `switchLatest`

convert an Observable that emits Observables into a single Observable that emits the items emitted by the most-recently-emitted of those Observables

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/switch.png)

[More info in reactive.io website]( http://reactivex.io/documentation/operators/switch.html )
*/
example("switchLatest") {
    let var1 = Variable(0)

    let var2 = Variable(200)

    // var3 is like an Observable<Observable<Int>>
    let var3 = Variable(var1.asObservable())

    let d = var3
        .asObservable()
        .switchLatest()
        .subscribe {
            print($0)
        }

    var1.value = 1
    var1.value = 2
    var1.value = 3
    var1.value = 4

    var3.value = var2.asObservable()

    var2.value = 201

    var1.value = 5
    var1.value = 6
    var1.value = 7
}

//: [Index](Index) - [Next >>](@next)
