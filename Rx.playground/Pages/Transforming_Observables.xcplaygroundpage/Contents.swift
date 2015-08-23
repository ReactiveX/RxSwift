//: [<< Previous](@previous) - [Index](Index)

import RxSwift

/*:
## Transforming Observables

Operators that transform items that are emitted by an Observable.


### `map` / `select`

Transform the items emitted by an Observable by applying a function to each item

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/map.png)

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
        .map { char in
            char.hashValue
        }
        .subscribeNext { int in
            print(int)
        }
}


/*:
### `flatMap`

Transform the items emitted by an Observable into Observables, then flatten the emissions from those into a single Observable

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/flatmap.png)

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
        .flatMap { int in
            observable2
        }
        .subscribeNext {
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
        .scan(0) { acum, elem in
            acum + elem
        }
        .subscribeNext {
            print($0)
    }
}


//: [Index](Index) - [Next >>](@next)
