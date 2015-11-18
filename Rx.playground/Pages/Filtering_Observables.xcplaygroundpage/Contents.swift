//: [<< Previous](@previous) - [Index](Index)

import RxSwift

/*:
## Filtering Observables

Operators that selectively emit items from a source Observable.
*/

/*:
### `filter`

Emit only those items from an Observable that pass a predicate test

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/filter.png)

[More info in reactive.io website]( http://reactivex.io/documentation/operators/filter.html )
*/

example("filter") {
    let subscription = sequenceOf(0, 1, 2, 3, 4, 5, 6, 7, 8, 9)
        .filter {
            $0 % 2 == 0
        }
        .subscribe {
            print($0)
        }
}


/*:
### `distinctUntilChanged`

Suppress duplicate items emitted by an Observable

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/distinct.png)

[More info in reactive.io website]( http://reactivex.io/documentation/operators/distinct.html )
*/
example("distinctUntilChanged") {
    let subscription = sequenceOf(1, 2, 3, 1, 1, 4)
        .distinctUntilChanged()
        .subscribe {
            print($0)
        }
    
}



/*:
### `elementAt`

Emit only item n emitted by an Observable

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/elementat.png)

[More info in reactive.io website]( http://reactivex.io/documentation/operators/elementat.html )
*/

example("elementAt") {
    let subscription = sequenceOf(1, 2, 3, 4, 5, 6)
        .elementAt(0)
        .subscribe {
            print($0)
    }
}



/*:
### `elementAt`

Emit only item n emitted by an Observable

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/elementat.png)

[More info in reactive.io website]( http://reactivex.io/documentation/operators/elementat.html )
*/

example("elementAt") {
    let subscription = sequenceOf(1, 2, 3, 4, 5, 6)
        .elementAt(0)
        .subscribe {
            print($0)
    }
}


/*:
### `single` (a.k.a first)

Emit only the first item (or the first item that meets some condition) emitted by an Observable

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/first.png)

[More info in reactive.io website]( http://reactivex.io/documentation/operators/first.html )
*/
example("single") {
    let subscription = sequenceOf(1, 2, 3, 4, 5, 6)
        .single()
        .subscribe {
            print($0)
        }
}

example("single with predicate") {
    let subscription = sequenceOf(1, 2, 3, 4, 5, 6)
        .single {
            $0 > 2
        }
        .subscribe {
            print($0)
        }
}


/*:
### `takeLast`

Emit only the final n items emitted by an Observable

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/takelast.png)

[More info in reactive.io website]( http://reactivex.io/documentation/operators/takelast.html )
*/
example("takeLast") {
    let subscription = sequenceOf(1, 2, 3, 4, 5, 6)
        .takeLast(2)
        .subscribe {
            print($0)
    }
}


/*:
### `skip`

Suppress the first n items emitted by an Observable

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/skip.png)

[More info in reactive.io website]( http://reactivex.io/documentation/operators/skip.html )
*/
example("skip") {
    let subscription = sequenceOf(1, 2, 3, 4, 5, 6)
        .skip(2)
        .subscribe {
            print($0)
    }
}


example("skipWhileWithIndex") {
    let subscription = sequenceOf("🔴","🔴","🔴","🔵","🔵","🔵")
        .skipWhileWithIndex { str, idx -> Bool in
            return idx < 3
        }
        .subscribe {
            print($0)
    }
}


//: [Index](Index) - [Next >>](@next)
