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
            print("\(box.value)")
        case .Completed:
            print("completed")
        case .Error(let error):
            print("\(error)")
        }
    }
}

exampl/*:
As you can see, no values are ever sent to the subscriber of an empty observable. It just completes and is done.



### `never`

Creates an observable that contains no objects and never completes or errors out.
[More info in reactive.io website]( http://reactivex.io/documentation/operators/empty-never-throw.html )
*/
e("Never observable") {
    let neverObservable: Observable<String> = never()
    
    let neverSubscriber = neverObservable 
        >- subscribe { _ in
            print("This block is never called.")
        }
}


example/*:

### `failWith`

Creates an observable that contains no objects and send only a error out.
[More info in reactive.io website]( http://reactivex.io/documentation/operators/empty-never-throw.html )
*/
("failWith") {
    let error = NSError(domain: "Test", code: -1, userInfo: nil)
    
    let errorObservable: Observable<Int> = failWith(error)
    
    let errorSubscriber = errorObservable 
        >- subscribe { event in
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


example("retu/*:
### `returnElement` / `just`

These two functions behave identically. They send two messages to subscribers. The first message is the value and the second message is `.Complete`.
[More info in reactive.io website]( http://reactivex.io/documentation/operators/just.html )
*/
rnElement/just") {
    let oneObservable = just(32)
    
    let oneObservableSubscriber = oneObservable
        >- subscribe { event in
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


example("returnElem/*:
Here we see that the `.Next` event is sent just once, then the `.Completed` event is sent.



### `returnElements`

Now we are getting to some more interesting ways to create an Observable. This function creates an observable that produces a number of values before completing.
*/
ents") {
    let multipleObservable/* : Observable<Int> */ = returnElements(0, 1, 2, 3, 4, 5, 6, 7, 8, 9)
    
    let multipleObservableSubscriber = multipleObservable
        >- subscribe { event in
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


example("from") {
    let/*:
With the above, you will see that the `.Next` event was sent ten times, once for each element. Then `.Complete` was sent.



### `from`
We can also create an observable from any SequenceType, such as an array
[More info in reactive.io website]( http://reactivex.io/documentation/operators/from.html )
*/
 fromArrayObservable = from([1, 2, 3, 4, 5])
    
    let fromArrayObservableSubscriber = fromArrayObservable
        >- subscribe { event in
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


example("create") {
    
    pr/*:
### `create`

Create an Observable from scratch by means of a function
[More info in reactive.io website]( http://reactivex.io/documentation/operators/create.html )
*/
int("creating")
    let observable: Observable<Int> = create { observer in
        print("emmiting")
        sendNext(observer, 0)
        sendNext(observer, 1)
        sendNext(observer, 2)
        
        return AnonymousDisposable {}
    }
    
    observable
        >- subscribeNext {
            print($0)
        }
    
    observable
        >- subscribeNext {
            print($0)
        }
}


example("defer") {
    
    let defered/*:
### `defer`

Create an Observable from a function which create an observable. But do not create the Observable until the observer subscribes, and create a fresh Observable for each observer
[More info in reactive.io website]( http://reactivex.io/documentation/operators/defer.html )
*/
: Observable<Int> = defer {
        print("creating")
        return create { observer in
            print("emmiting")
            sendNext(observer, 0)
            sendNext(observer, 1)
            sendNext(observer, 2)
            
            return AnonymousDisposable {}
        }
    }
    
    defered
        >- subscribeNext {
            print($0)
        }
    
    defered
        >- subscribeNext {
            print($0)
        }
}


