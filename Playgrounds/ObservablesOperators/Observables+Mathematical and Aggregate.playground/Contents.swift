//: Playground - noun: a place where people can play

import Cocoa
import RxSwift

/*:
## concat
Emit the emissions from two or more Observables without interleaving them
*/

example("concat") {
    let var1 = Variable(0)
    let var2 = Variable(200)
    
    // var3 is like an Observable<Observable<Int>>
    let var3 = Variable(var1 as Observable<Int>)
    
    let d = var3
        >- concat
        >- subscribeNext { (e: Int) -> Void in
            println("\(e)")
    }
    
    var1.next(1)
    var1.next(2)
    var1.next(3)
    var1.next(4)
    
    var3.next(var2)
    
    var2.next(201)
    
    var1.next(5)
    var1.next(6)
    var1.next(7)
    sendCompleted(var1)
    
    var2.next(202)
    var2.next(203)
    var2.next(204)
}
