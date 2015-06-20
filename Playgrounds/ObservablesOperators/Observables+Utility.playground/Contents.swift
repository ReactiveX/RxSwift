
import Cocoa
import RxSwift



/*:
### `subscribe`
Create an Disposable which listen events from source Observable, the given closure take the Even and is responsible for the actions to perform when the it is produced 
[More info in reactive.io website](http://reactivex.io/documentation/operators/subscribe.html)
*/

example("subscribe") {
    let intOb1 = Subject<Int>()
    
    intOb1
        >- subscribe { event in
            println(event)
    }
    
    sendNext(intOb1, 1)
    sendCompleted(intOb1)
}


/*:
There are several variants of the `subscribe` operator. They works over one posible event type:

###subscribeNext
Create an Disposable which listen only Next event from source Observable, the given closure take the Even's value and is responsible for the actions to perform only when the Next even is produced 
*/
example("subscribeNext") {
    let intOb1 = Subject<Int>()
    
    intOb1
        >- subscribeNext { int in
            println(int)
    }
    
    sendNext(intOb1, 1)
    sendCompleted(intOb1)
}


/*:
###subscribeNext
Create an Disposable which listen only Completed event from source Observable, the given closure take the Even's value and is responsible for the actions to perform only when the Completed even is produced 
*/
example("subscribeCompleted") {
    let intOb1 = Subject<Int>()
    
    intOb1
        >- subscribeCompleted {
            println("It's completed")
    }
    
    sendNext(intOb1, 1)
    sendCompleted(intOb1)
}


/*:
###subscribeError
Create an Disposable which listen only Error event from source Observable, the given closure take the Even's value and is responsible for the actions to perform only when the Error even is produced 
*/
example("subscribeError") {
    let intOb1 = Subject<Int>()
    
    intOb1
        >- subscribeError { error in
            println(error)
    }
    
    sendNext(intOb1, 1)
    sendError(intOb1, NSError(domain: "Examples", code: -1, userInfo: nil))
}


/*:

### `do`
Returns the same source Observable but the given closure responsible for the actions to perform when the even is produced. The gived closure obtain the event produced by the source observable
[More info in reactive.io website](http://reactivex.io/documentation/operators/do.html)
*/

example("do") {
    let intOb1 = Subject<Int>()
    
    let intOb2 = intOb1
        >- `do` { event in
            println("first \(event)")
    }
    
    intOb2
        >- subscribeNext { int in
            println("second \(int)")
    }
    
    sendNext(intOb1, 1)
    
}

/*:
### `doOnNext`
It is a variant of the `do` operator. Returns the same source Observable but the given closure responsible for the actions to perform when the Next even is produced. The gived closure obtain the value of the Next event produced by the source observable
*/

example("doOnNext") {
    let intOb1 = Subject<Int>()
    
    let intOb2 = intOb1
        >- doOnNext { int in
            println("first \(int)")
    }
    
    intOb2
        >- subscribeNext { int in
            println("second \(int)")
    }
    
    sendNext(intOb1, 1)
    
}


/*:
### `observeSingleOn`
Specify the Scheduler on which an observer will observe this Observable
[More info in reactive.io website](http://reactivex.io/documentation/operators/observeon.html)
*/

//TODO: Do not work in playgrounds
example("observeSingleOn") {
    let intOb1 = Subject<Int>()
    
    intOb1
        >- observeSingleOn(MainScheduler.sharedInstance)
        >- subscribeNext { int in
            println(int)
    }
    
    sendNext(intOb1, 1)
}

