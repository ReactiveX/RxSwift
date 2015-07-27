import Cocoa
import RxSwift

/*:
# To use playgrounds please open `Rx.xcworkspace`, build `RxSwift-OSX` scheme and then open playgrounds in `Rx.xcworkspace` tree view.
*/
/*:
## Filtering Observables

Operators that selectively emit items from a source Observable.



### `where` / `filter`

emit only those items from an Observable that pass a predicate test
[More info in reactive.io website]( http://reactivex.io/documentation/operators/filter.html )
*/

example("filter") {
    let onlyEvensSubscriber = returnElements(0, 1, 2, 3, 4, 5, 6, 7, 8, 9)
        >- filter {
            $0 % 2 == 0
        }
        >- subscribeNext { value in
            println("\(value)")
    }
}

/*:
### `distinctUntilChanged`

suppress duplicate items emitted by an Observable
[More info in reactive.io website]( http://reactivex.io/documentation/operators/distinct.html )
*/

example("distinctUntilChanged") {
    let distinctUntilChangedSubscriber = returnElements(1, 2, 3, 1, 1, 4)
        >- distinctUntilChanged
        >- subscribeNext { value in
            println("\(value)")
    }
}

/*:
### `take`

Emit only the first n items emitted by an Observable
[More info in reactive.io website]( http://reactivex.io/documentation/operators/take.html )
*/

example("take") {
    let distinctUntilChangedSubscriber = returnElements(1, 2, 3, 4, 5, 6)
        >- take(3)
        >- subscribeNext { value in
            println("\(value)")
    }
}

