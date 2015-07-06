import Cocoa
import RxSwift


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
            print("\(value)")
    }
}


e/*:
### `distinctUntilChanged`

suppress duplicate items emitted by an Observable
[More info in reactive.io website]( http://reactivex.io/documentation/operators/distinct.html )
*/
xample("distinctUntilChanged") {
    let distinctUntilChangedSubscriber = returnElements(1, 2, 3, 1, 1, 4)
        >- distinctUntilChanged
        >- subscribeNext { value in
            print("\(value)")
    }
}


exa/*:
### `take`

Emit only the first n items emitted by an Observable
[More info in reactive.io website]( http://reactivex.io/documentation/operators/take.html )
*/
mple("take") {
    let distinctUntilChangedSubscriber = returnElements(1, 2, 3, 4, 5, 6)
        >- take(3)
        >- subscribeNext { value in
            print("\(value)")
    }
}

