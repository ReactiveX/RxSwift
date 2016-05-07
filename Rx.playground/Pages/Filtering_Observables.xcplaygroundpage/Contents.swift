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
    let subscription = Observable.of("🐶","🐱","🐭","🐹","🐰","🐸","🐱","🐼","🐨","🐱","🐸","🐱","🐷","🐽","🐸","🐱","🐵")
        .filter {
            $0 == "🐱"
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
    let subscription = Observable.of("🐶","🐱","🐱","🐱","🐱","🐱","🐱","🐱","🐱","🐱","🐱","🐷","🐵")
        .distinctUntilChanged()
        .subscribe {
            print($0)
        }
}



/*:
 ### `elementAt`
 
 Emit only item n of all elemets emitted by an Observable
 
 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/elementat.png)
 
 [More info in reactive.io website]( http://reactivex.io/documentation/operators/elementat.html )
 */

example("elementAt") {
    let subscription = Observable.of("🔴","🔵","⚪️","㊗️")
        .elementAt(2)
        .subscribe {
            print($0)
        }
}



/*:
### `take`

Emit only the first n items emitted by an Observable

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/take.png)

[More info in reactive.io website]( http://reactivex.io/documentation/operators/take.html )
*/
example("take") {
    let subscription = Observable.of("🐶","🐱","🐭","🐹")
        .take(3)
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
    let subscription = Observable.of("🐶","🐱","🐭","🐹")
        .single()
        .subscribe {
            print($0)
        }
}

example("single with predicate") {
    let subscription = Observable.of("🐶","🐱","🐭","🐹")
        .single {
            $0 == "🔵"
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
    let subscription = Observable.of("🐶","🐱","🐭","🐹")
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
    let subscription = Observable.of("🐶","🐱","🐭","🐹")
        .skip(2)
        .subscribe {
            print($0)
        }
}


example("skipWhileWithIndex") {
    let subscription = Observable.of("🐱","🐱","🐱","🐷","🐷","🐷")
        .skipWhileWithIndex { str, idx -> Bool in
            return idx < 2
        }
        .subscribe {
            print($0)
        }
}






//: [Index](Index) - [Next >>](@next)
