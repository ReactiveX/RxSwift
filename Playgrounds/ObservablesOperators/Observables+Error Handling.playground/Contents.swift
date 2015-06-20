//: Playground - noun: a place where people can play

import Cocoa
import RxSwift

/*:
## catch

Recover from an onError notification by continuing the sequence without error
*/

example("catch") {
    
    let observable1 = Subject<Int>()
    let observable2 = Subject<Int>()
    
    observable1
        >- catch({ error in
            return observable2
        })
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
    
    
    sendNext(observable1, 1)
    sendNext(observable1, 2)
    sendNext(observable1, 3)
    sendNext(observable1, 4)
    sendError(observable1, NSError(domain: "Test", code: 0, userInfo: nil))
    
    sendNext(observable2, 5)
    sendNext(observable2, 6)
    sendNext(observable2, 7)
    sendNext(observable2, 8)
    sendCompleted(observable2)
    
    
}
