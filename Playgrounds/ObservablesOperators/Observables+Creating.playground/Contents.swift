import Cocoa
import RxSwift

/*:
# To use playgrounds please open `Rx.xcworkspace`, build `RxSwift-OSX` scheme and then open playgrounds in `Rx.xcworkspace` tree view.
*/

/*:
## Creating observables

Operators that originate new Observables.


### `empty`

Creates an observable that contains no objects. The only message it sends is the `.Completed` message.
[More info in reactive.io website]( http://reactivex.io/documentation/operators/empty-never-throw.html )
*/
example("Empty observable") {
    let emptyObservable: Observable<Int> = empty()
    
    let emptySubscriber = emptyObservable >- subscribe { event in
        switch event {
        case .Next(let box):
            println("\(box.value)")
        case .Completed:
            println("completed")
        case .Error(let error):
            println("\(error)")
        }
    }
}

/*:
As you can see, no values are ever sent to the subscriber of an empty observable. It just completes and is done.



### `never`

Creates an observable that contains no objects and never completes or errors out.
[More info in reactive.io website]( http://reactivex.io/documentation/operators/empty-never-throw.html )
*/
example("Never observable") {
    let neverObservable: Observable<String> = never()
    
    let neverSubscriber = neverObservable 
        >- subscribe { _ in
            println("This block is never called.")
        }
}

/*:

### `failWith`

Creates an observable that contains no objects and send only a error out.
[More info in reactive.io website]( http://reactivex.io/documentation/operators/empty-never-throw.html )
*/

example("failWith") {
    let error = NSError(domain: "Test", code: -1, userInfo: nil)
    
    let errorObservable: Observable<Int> = failWith(error)
    
    let errorSubscriber = errorObservable 
        >- subscribe { event in
            switch event {
            case .Next(let box):
                println("\(box.value)")
            case .Completed:
                println("completed")
            case .Error(let error):
                println("\(error)")
            }
    }
}

/*:
### `returnElement` / `just`

These two functions behave identically. They send two messages to subscribers. The first message is the value and the second message is `.Complete`.
[More info in reactive.io website]( http://reactivex.io/documentation/operators/just.html )
*/

example("returnElement/just") {
    let oneObservable = just(32)
    
    let oneObservableSubscriber = oneObservable
        >- subscribe { event in
            switch event {
            case .Next(let box):
                println("\(box.value)")
            case .Completed:
                println("completed")
            case .Error(let error):
                println("\(error)")
            }
    }
}

/*:
Here we see that the `.Next` event is sent just once, then the `.Completed` event is sent.



### `returnElements`

Now we are getting to some more interesting ways to create an Observable. This function creates an observable that produces a number of values before completing.
*/

example("returnElements") {
    let multipleObservable/* : Observable<Int> */ = returnElements(0, 1, 2, 3, 4, 5, 6, 7, 8, 9)
    
    let multipleObservableSubscriber = multipleObservable
        >- subscribe { event in
            switch event {
            case .Next(let box):
                println("\(box.value)")
            case .Completed:
                println("completed")
            case .Error(let error):
                println("\(error)")
            }
    }
}

/*:
With the above, you will see that the `.Next` event was sent ten times, once for each element. Then `.Complete` was sent.



### `from`
We can also create an observable from any SequenceType, such as an array
[More info in reactive.io website]( http://reactivex.io/documentation/operators/from.html )
*/

example("from") {
    let fromArrayObservable = from([1, 2, 3, 4, 5])
    
    let fromArrayObservableSubscriber = fromArrayObservable
        >- subscribe { event in
            switch event {
            case .Next(let box):
                println("\(box.value)")
            case .Completed:
                println("completed")
            case .Error(let error):
                println("\(error)")
            }
    }
}

/*:
### `create`

Create an Observable from scratch by means of a function
[More info in reactive.io website]( http://reactivex.io/documentation/operators/create.html )
*/

example("create") {
    
    println("creating")
    let observable: Observable<Int> = create { observer in
        println("emmiting")
        sendNext(observer, 0)
        sendNext(observer, 1)
        sendNext(observer, 2)
        
        return AnonymousDisposable {}
    }
    
    observable
        >- subscribeNext {
            println($0)
        }
    
    observable
        >- subscribeNext {
            println($0)
        }
}

/*:
### `defer`

Create an Observable from a function which create an observable. But do not create the Observable until the observer subscribes, and create a fresh Observable for each observer
[More info in reactive.io website]( http://reactivex.io/documentation/operators/defer.html )
*/

example("defer") {
    
    let defered: Observable<Int> = defer {
        println("creating")
        return create { observer in
            println("emmiting")
            sendNext(observer, 0)
            sendNext(observer, 1)
            sendNext(observer, 2)
            
            return AnonymousDisposable {}
        }
    }
    
    defered
        >- subscribeNext {
            println($0)
        }
    
    defered
        >- subscribeNext {
            println($0)
        }
}


