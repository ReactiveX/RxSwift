//: [<< Previous](@previous) - [Index](Index)

import RxSwift

/*:
## Mathematical and Aggregate Operators

Operators that operate on the entire sequence of items emitted by an Observable



### `concat`

Emit the emissions from two or more Observables without interleaving them.
![](concat.png)
[More info in reactive.io website]( http://reactivex.io/documentation/operators/concat.html )
*/
example("concat") {
    let var1 = Variable(0)
    let var2 = Variable(200)

    // var3 is like an Observable<Observable<Int>>
    let var3 = Variable(var1 as Observable<Int>)

    let d = var3
        .concat
        .subscribeNext { (e: Int) -> Void in
            print("\(e)")
        }

    var1.sendNext(1)
    var1.sendNext(2)
    var1.sendNext(3)
    var1.sendNext(4)

    var3.sendNext(var2)

    var2.sendNext(201)

    var1.sendNext(5)
    var1.sendNext(6)
    var1.sendNext(7)
    sendCompleted(var1)

    var2.sendNext(202)
    var2.sendNext(203)
    var2.sendNext(204)
}


/*:


### `reduce` / `aggregate`

Apply a function to each item emitted by an Observable, sequentially, and emit the final value.
This function will perform a function on each element in the sequence until it is completed, then send a message with the aggregate value. It works much like the Swift `reduce` function works on sequences.
![](reduce.png)
[More info in reactive.io website]( http://reactivex.io/documentation/operators/reduce.html )

*/
example("aggregate") {
    let aggregateSubscriber = sequence(0, 1, 2, 3, 4, 5, 6, 7, 8, 9)
        .aggregate(0, +)
        .subscribeNext { value in
            print("\(value)")
        }
}



//: [Index](Index) - [Next >>](@next)
