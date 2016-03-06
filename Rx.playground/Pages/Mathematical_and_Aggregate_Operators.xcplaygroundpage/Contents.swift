/*:
> # IMPORTANT: To use `Rx.playground`, please:

1. Open `Rx.xcworkspace`
2. Build `RxSwift-OSX` scheme
3. And then open `Rx` playground in `Rx.xcworkspace` tree view.
4. Choose `View > Show Debug Area`
*/

//: [<< Previous](@previous) - [Index](Index)

import RxSwift

/*:
## Mathematical and Aggregate Operators

Operators that operate on the entire sequence of items emitted by an Observable

*/

/*:
### `concat`

Emit the emissions from two or more Observables without interleaving them.

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/concat.png)

[More info in reactive.io website]( http://reactivex.io/documentation/operators/concat.html )
*/
example("concat") {
    let var1 = BehaviorSubject(value: 0)
    let var2 = BehaviorSubject(value: 200)
    
    // var3 is like an Observable<Observable<Int>>
    let var3 = BehaviorSubject(value: var1)
    
    let d = var3
        .concat()
        .subscribe {
            print($0)
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

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/reduce.png)

[More info in reactive.io website]( http://reactivex.io/documentation/operators/reduce.html )

*/
example("reduce") {
    _ = Observable.of(0, 1, 2, 3, 4, 5, 6, 7, 8, 9)
        .reduce(0, accumulator: +)
        .subscribe {
            print($0)
        }
}



//: [Index](Index) - [Next >>](@next)
