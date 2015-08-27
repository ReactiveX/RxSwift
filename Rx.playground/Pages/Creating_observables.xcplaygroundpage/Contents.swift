//: [<< Previous](@previous) - [Index](Index)

import RxSwift
import Foundation
/*:
## Creating observables

Operators that originate new Observables.


### `empty`

Creates an observable that contains no objects. The only message it sends is the `.Completed` message.

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/empty.png)

[More info in reactive.io website]( http://reactivex.io/documentation/operators/empty-never-throw.html )
*/

example("Empty observable") {
    let emptyObservable: Observable<Int> = empty()

    let emptySubscriber = emptyObservable .subscribe { event in
        switch event {
        case .Next(let box):
            print("\(box.value)")
        case .Completed:
            print("completed")
        case .Error(let error):
            print("\(error)")
        }
    }
}

/*:
As you can see, no values are ever sent to the subscriber of an empty observable. It just completes and is done.



### `never`

Creates an observable that contains no objects and never completes or errors out.

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/never.png)

[More info in reactive.io website]( http://reactivex.io/documentation/operators/empty-never-throw.html )
*/
example("Never observable") {
    let neverObservable: Observable<String> = never()

    let neverSubscriber = neverObservable
        .subscribe { _ in
            print("This block is never called.")
    }
}



/*:
### `failWith` a.k.a `throw`

Creates an observable that contains no objects and send only a error out.

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/throw.png)

[More info in reactive.io website]( http://reactivex.io/documentation/operators/empty-never-throw.html )
*/
example("failWith") {
    let error = NSError(domain: "Test", code: -1, userInfo: nil)

    let errorObservable: Observable<Int> = failWith(error)

    let errorSubscriber = errorObservable
        .subscribe { event in
            switch event {
            case .Next(let box):
                print("\(box.value)")
            case .Completed:
                print("completed")
            case .Error(let error):
                print("\(error)")
            }
        }
}


/*:
### `returnElement` / `just`

These two functions behave identically. They send two messages to subscribers. The first message is the value and the second message is `.Complete`.

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/just.png)

[More info in reactive.io website]( http://reactivex.io/documentation/operators/just.html )
*/
example("returnElement/just") {
    let oneObservable = just(32)

    let oneObservableSubscriber = oneObservable
        .subscribe { event in
            switch event {
            case .Next(let box):
                print("\(box.value)")
            case .Completed:
                print("completed")
            case .Error(let error):
                print("\(error)")
            }
    }
}


/*:
Here we see that the `.Next` event is sent just once, then the `.Completed` event is sent.



### `sequenceOf`

Now we are getting to some more interesting ways to create an Observable. This function creates an observable that produces a number of values before completing.
*/
example("sequenceOf") {
    let multipleObservable/* : Observable<Int> */ = sequenceOf(0, 1, 2, 3, 4, 5, 6, 7, 8, 9)

    let multipleObservableSubscriber = multipleObservable
        .subscribe { event in
            switch event {
            case .Next(let box):
                print("\(box.value)")
            case .Completed:
                print("completed")
            case .Error(let error):
                print("\(error)")
            }
        }
}


/*:
With the above, you will see that the `.Next` event was sent ten times, once for each element. Then `.Complete` was sent.



### `from`
We can also create an observable from any SequenceType, such as an array.

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/from.png)

[More info in reactive.io website]( http://reactivex.io/documentation/operators/from.html )
*/
example("from") {
    let fromArrayObservable = from([1, 2, 3, 4, 5])

    let fromArrayObservableSubscriber = fromArrayObservable
        .subscribe { event in
            switch event {
            case .Next(let box):
                print("\(box.value)")
            case .Completed:
                print("completed")
            case .Error(let error):
                print("\(error)")
            }
        }
}



/*:
### `create`

Create an Observable from scratch by means of a function

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/create.png)

[More info in reactive.io website]( http://reactivex.io/documentation/operators/create.html )
*/
example("create") {
    
    print("creating")
    let observable: Observable<Int> = create { observer in
        print("emmiting")
        sendNext(observer, 0)
        sendNext(observer, 1)
        sendNext(observer, 2)

        return AnonymousDisposable {}
    }

    observable
        .subscribeNext {
            print($0)
        }

    observable
        .subscribeNext {
            print($0)
        }
}

/*:
### `deferred`

Create an Observable from a function which create an observable. But do not create the Observable until the observer subscribes, and create a fresh Observable for each observer

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/defer.png)

[More info in reactive.io website]( http://reactivex.io/documentation/operators/defer.html )
*/
example("deferred") {
    let deferredSequence: Observable<Int> = deferred {
        print("creating")
        return create { observer in
            print("emmiting")
            sendNext(observer, 0)
            sendNext(observer, 1)
            sendNext(observer, 2)

            return AnonymousDisposable {}
        }
    }

    deferredSequence
        .subscribeNext {
            print($0)
        }

    deferredSequence
        .subscribeNext {
            print($0)
        }
}


//: [Index](Index) - [Next >>](@next)
