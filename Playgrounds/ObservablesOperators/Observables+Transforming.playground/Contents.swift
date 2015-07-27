import Cocoa
import RxSwift

/*:
# To use playgrounds please open `Rx.xcworkspace`, build `RxSwift-OSX` scheme and then open playgrounds in `Rx.xcworkspace` tree view.
*/

/*:
## Transforming Observables

Operators that transform items that are emitted by an Observable.


### `map` / `select`

Transform the items emitted by an Observable by applying a function to each item
[More info in reactive.io website]( http://reactivex.io/documentation/operators/map.html )
*/

example("map") {
    
    let observable1: Observable<Character> = create { observer in
        sendNext(observer, Character("A"))
        sendNext(observer, Character("B"))
        sendNext(observer, Character("C"))
        
        return AnonymousDisposable {}
    }
    
    observable1
        >- map { char in
            char.hashValue
        }
        >- subscribeNext { int in
            println(int)
    }
}

/*:
### `flatMap`

Transform the items emitted by an Observable into Observables, then flatten the emissions from those into a single Observable
[More info in reactive.io website]( http://reactivex.io/documentation/operators/flatmap.html )
*/

example("flatMap") {
    
    let observable1: Observable<Int> = create { observer in
        sendNext(observer, 1)
        sendNext(observer, 2)
        sendNext(observer, 3)
        
        return AnonymousDisposable {}
    }
    
    let observable2: Observable<String> = create { observer in
        sendNext(observer, "A")
        sendNext(observer, "B")
        sendNext(observer, "C")
        sendNext(observer, "D")
        sendNext(observer, "F")
        sendNext(observer, "--")
        
        return AnonymousDisposable {}
    }
    
    observable1
        >- flatMap { int in
            observable2
        }
        >- subscribeNext {
            println($0)
    }
}

/*:
### `scan`

Apply a function to each item emitted by an Observable, sequentially, and emit each successive value
[More info in reactive.io website]( http://reactivex.io/documentation/operators/scan.html )
*/

example("scan") {
    
    let observable: Observable<Int> = create { observer in
        sendNext(observer, 0)
        sendNext(observer, 1)
        sendNext(observer, 2)
        sendNext(observer, 3)
        sendNext(observer, 4)
        sendNext(observer, 5)
        
        return AnonymousDisposable {}
    }
    
    observable
        >- scan(0) { acum, elem in
            acum + elem
        }
        >- subscribeNext {
            println($0)
    }
}
