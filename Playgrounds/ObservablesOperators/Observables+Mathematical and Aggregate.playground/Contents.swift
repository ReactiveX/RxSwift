import Cocoa
import RxSwift

/*:
# To use playgrounds please open `Rx.xcworkspace`, build `RxSwift-OSX` scheme and then open playgrounds in `Rx.xcworkspace` tree view.
*/
/*:
## Mathematical and Aggregate Operators

Operators that operate on the entire sequence of items emitted by an Observable



### `concat`

Emit the emissions from two or more Observables without interleaving them.
[More info in reactive.io website]( http://reactivex.io/documentation/operators/concat.html )
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

/*:


### `reduce` / `aggregate`

Apply a function to each item emitted by an Observable, sequentially, and emit the final value.
This function will perform a function on each element in the sequence until it is completed, then send a message with the aggregate value. It works much like the Swift `reduce` function works on sequences.
[More info in reactive.io website]( http://reactivex.io/documentation/operators/reduce.html )

*/

example("aggregate") {
    let aggregateSubscriber = returnElements(0, 1, 2, 3, 4, 5, 6, 7, 8, 9)
        >- aggregate(0, +)
        >- subscribeNext { value in
            println("\(value)")
    }
}
