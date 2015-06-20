//: Playground - noun: a place where people can play

import Cocoa
import RxSwift

/*:

# Creating observables

Besides creation operators seen in the introduction, there are several more.

## asObservable

*/




/*:
## create

Create an Observable from scratch by means of a function
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
## defer

Create an Observable from a function which create an observable. But do not create the Observable until the observer subscribes, and create a fresh Observable for each observer
*/

example("defer") {
    
    let defered: Observable<Int> = defer({
        println("creating")
        return create { observer in
            println("emmiting")
            sendNext(observer, 0)
            sendNext(observer, 1)
            sendNext(observer, 2)
            
            return AnonymousDisposable {}
        }
    })
    
    defered
        >- subscribeNext {
            println($0)
    }
    
    defered
        >- subscribeNext {
            println($0)
    }
}

