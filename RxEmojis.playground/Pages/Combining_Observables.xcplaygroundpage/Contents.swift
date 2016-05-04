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

    let subscription = Observable.of("🔴","🔵","⚪️","㊗️")
        .startWith("🅰️")
        .startWith("🅱️")
        .startWith("🆎")
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
    let stringObs = PublishSubject<String>()
    let intObs = PublishSubject<Int>()

    _ = Observable.combineLatest(stringObs, intObs) {
        "\($0) \($1)"
        }
        .subscribe {
            print($0)
        }

    stringObs.on(.Next("🅰️"))

    intObs.on(.Next(1))

    stringObs.on(.Next("🅱️"))

    intObs.on(.Next(2))
}


//: To produce output, at least one element has to be received from each sequence in arguements.

example("combineLatest 2") {
    let stringObs = Observable.of("🔴","🔵","⚪️","㊗️")
    let intObs = Observable.just(2)

    _ = Observable.combineLatest(stringObs, intObs) {
            "\($0) \($1)"
        }
        .subscribe {
            print($0)
        }
}



//: Combine latest has versions with more than 2 arguments.

example("combineLatest 3") {
    let intObs = Observable.just(2)
    let stringObs1 = Observable.of("🔴","🔵","⚪️","㊗️")
    let stringObs2 = Observable.of("🅰️","🅱️","🆎")

    _ = Observable.combineLatest(intObs, stringObs1, stringObs2) {
            "\($0) \($1) \($2)"
        }
        .subscribe {
            print($0)
        }
}



//: Combinelatest version that allows combining sequences with different types.

example("combineLatest 4") {
    let intObs = Observable.just(2)
    let stringObs = Observable.just("🔴")
    
    _ = Observable.combineLatest(intObs, stringObs) {
            "\($0) " + $1
        }
        .subscribe {
            print($0)
    }
}


//: `combineLatest` extension method for Array of `ObservableType` conformable types
//: The array must be formed by `Observables` of the same type.

example("combineLatest 5") {
    let stringObs1 = Observable.just("❤️")
    let stringObs2 = Observable.of("🔴","🔵","⚪️","㊗️")
    let stringObs3 = Observable.of("🅰️","🅱️","🆎")
    
    _ = [stringObs1, stringObs2, stringObs3].combineLatest { stringArray -> String in
            stringArray[0] + stringArray[1] + stringArray[2]
        }
        .subscribe { (event: Event<String>) -> Void in
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
    let stringObs = PublishSubject<String>()
    let intObs = PublishSubject<Int>()

    _ = Observable.zip(stringObs, intObs) {
        "\($0) \($1)"
        }
        .subscribe {
            print($0)
        }

    stringObs.on(.Next("🔴"))

    intObs.on(.Next(1))

    stringObs.on(.Next("🔵"))

    stringObs.on(.Next("⚪️"))

    intObs.on(.Next(2))
}


example("zip 2") {
    let intObs = Observable.just(1)
    let stringObs = Observable.of("🔴","🔵","⚪️","㊗️")

    _ = Observable.zip(intObs, stringObs) {
            "\($0) \($1)"
        }
        .subscribe {
            print($0)
        }
}


example("zip 3") {
    let intObs = Observable.of(1,2)
    let stringObs1 = Observable.of("🔴","🔵","⚪️","㊗️")
    let stringObs2 = Observable.of("🍎","🍐","🍊","🍋","🍉","🍓")

    _ = Observable.zip(intObs, stringObs1, stringObs2) {
            "\($0) \($1) \($2)"
        }
        .subscribe {
            print($0)
        }
}




/*:
### `merge`

combine multiple Observables of same type into one by merging their emissions

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/merge.png)

[More info in reactive.io website]( http://reactivex.io/documentation/operators/merge.html )
*/
example("merge 1") {
    let subject1 = PublishSubject<String>()
    let subject2 = PublishSubject<String>()

    _ = Observable.of(subject1, subject2)
        .merge()
        .subscribeNext { string in
            print(string)
        }

    subject1.on(.Next("🍎"))
    subject1.on(.Next("🍐"))
    subject1.on(.Next("🍊"))
    subject2.on(.Next("🔴"))
    subject1.on(.Next("🍋"))
    subject1.on(.Next("🍉"))
    subject2.on(.Next("🔵"))
}


example("merge 2") {
    let subject1 = PublishSubject<String>()
    let subject2 = PublishSubject<String>()

    _ = Observable.of(subject1, subject2)
        .merge(maxConcurrent: 2)
        .subscribe {
            print($0)
        }
    
    subject1.on(.Next("🍎"))
    subject1.on(.Next("🍐"))
    subject1.on(.Next("🍊"))
    subject2.on(.Next("🔴"))
    subject1.on(.Next("🍋"))
    subject1.on(.Next("🍉"))
    subject2.on(.Next("🔵"))
}



/*:
### `switchLatest`

convert an Observable that emits Observables into a single Observable that emits the items emitted by the most-recently-emitted of those Observables

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/switch.png)

[More info in reactive.io website]( http://reactivex.io/documentation/operators/switch.html )
*/
example("switchLatest") {
    let var1 = Variable("⚽️")

    let var2 = Variable("🍎")

    // var3 is an Observable<Observable<String>>
    let var3 = Variable(var1.asObservable())

    let d = var3
        .asObservable()
        .switchLatest()
        .subscribe {
            print($0)
        }

    var1.value = "🏀"
    var1.value = "🏈"
    var1.value = "⚾️"
    var1.value = "🎱"

    var3.value = var2.asObservable()

    var2.value = "🍐"

    var1.value = "🏐"
    var1.value = "🏉"
    
    var2.value = "🍋"
}

//: [Index](Index) - [next >>](@next)
