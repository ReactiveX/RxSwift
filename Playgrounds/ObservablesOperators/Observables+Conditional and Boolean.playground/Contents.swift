//: Playground - noun: a place where people can play

import Cocoa
import RxSwift

/*:
## takeUntil
Discard any items emitted by an Observable after a second Observable emits an item or terminates
*/

example("takeUntil") {
    
    let observable1 = Subject<Int>()
    let observable2 = Subject<Int>()
    
    observable1
        >- takeUntil(observable2)
        >- subscribeNext { int in
            println(int)
    }
    
    sendNext(observable1, 1)
    sendNext(observable1, 2)
    sendNext(observable1, 3)
    sendNext(observable1, 4)
    
    sendNext(observable2, 1)
    
    sendNext(observable1, 5)
    
}


/*:
## takeUntil
Mirror items emitted by an Observable until a specified condition becomes false

*/

example("takeWhile") {
    
    let observable1 = Subject<Int>()
    
    observable1
        >- takeWhile { int in
            int < 4
        }
        >- subscribeNext { int in
            println(int)
    }
    
    sendNext(observable1, 1)
    sendNext(observable1, 2)
    sendNext(observable1, 3)
    sendNext(observable1, 4)
    sendNext(observable1, 5)
    
}

