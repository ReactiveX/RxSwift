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
    let var1 = BehaviorSubject(value: 0)
    let var2 = BehaviorSubject(value: 200)
    
    // var3 is like an Observable<Observable<Int>>
    let var3 = BehaviorSubject(value: var1)
    
    let d = var3
        .concat
        .subscribeNext { (e: Int) -> Void in
            print("\(e)")
        }
    
    var1.on(.Next(1))
    var1.on(.Next(2))
    var1.on(.Next(3))
    var1.on(.Next(4))
    
    var3.on(.Next(var2))
    
    var2.on(.Next(201))
    
    var1.on(.Next(5))
    var1.on(.Next(6))
    var1.on(.Next(7))
    var1.on(.Completed)
    
    var2.on(.Next(202))
    var2.on(.Next(203))
    var2.on(.Next(204))
}


/*:


### `reduce`

Apply a function to each item emitted by an Observable, sequentially, and emit the final value.
This function will perform a function on each element in the sequence until it is completed, then send a message with the aggregate value. It works much like the Swift `reduce` function works on sequences.
[More info in reactive.io website]( http://reactivex.io/documentation/operators/reduce.html )

*/
example("aggregate") {
    let aggregateSubscriber = sequenceOf(0, 1, 2, 3, 4, 5, 6, 7, 8, 9)
        .reduce(0, +)
       