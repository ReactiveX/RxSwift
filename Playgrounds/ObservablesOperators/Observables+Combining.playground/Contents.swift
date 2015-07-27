import Cocoa
import RxSwift

/*:
# To use playgrounds please open `Rx.xcworkspace`, build `RxSwift-OSX` scheme and then open playgrounds in `Rx.xcworkspace` tree view.
*/
/*:
## Combination operators

Operators that work with multiple source Observables to create a single Observable.



### `startWith`

Return an observeble which emits a specified item before emitting the items from the source Observable.
[More info in reactive.io website]( http://reactivex.io/documentation/operators/startwith.html )
*/

example("startWith") {
    
    let aggregateSubscriber = from([4, 5, 6, 7, 8, 9])
        >- startWith(3)
        >- startWith(2)
        >- startWith(1)
        >- startWith(0)
        >- subscribeNext { int in
            println(int)
    }
    
}

/*:
### `combineLatest`

Takes several source Obserbables and a closure as parameters, returns an Observable which emits the latest items of each source Obsevable,  procesed through the closure.
Once each source Observables have each emitted an item, `combineLatest` emits an item every time either source Observable emits an item.
[More info in reactive.io website]( http://reactivex.io/documentation/operators/combinelatest.html )

The next example shows how 
*/

example("combineLatest 1st") {
    let intOb1 = PublishSubject<String>()
    let intOb2 = PublishSubject<Int>()
    
    combineLatest(intOb1, intOb2) {
        "\($0) \($1)"
        }
        >- subscribeNext {
            println($0)
    }
    
    println("send A to first channel")
    sendNext(intOb1, "A")
    println("note that nothing outputs")
    
    println("\nsend 1 to second channel")
    sendNext(intOb2, 1)
    println("now that there is something in both channels, there is output")
    
    println("\nsend B to first channel")
    sendNext(intOb1, "B")
    println("now that both channels are full, whenever either channel emits a value, the combined channel also emits a value")
    
    println("\nsend 2 to second channel")
    sendNext(intOb2, 2)
    println("note that the combined channel emits a value whenever either sub-channel emits a value, even if the value is the same")
    
    
}

//: This example show once in each channel there are output for each new channel output the resulting observable also produces an output

example("combineLatest 2nd") {
    let intOb1 = just(2)
    let intOb2 = from([0, 1, 2, 3, 4])
    
    combineLatest(intOb1, intOb2) {
        $0 * $1
        }
        >- subscribeNext {
            println($0)
    }
}

/*:
There are a serie of functions `combineLatest`, they take from two to ten sources Obserbables and the closure
The next sample shows combineLatest called with three sorce Observables
*/

example("combineLatest 3rd") {
    let intOb1 = just(2)
    let intOb2 = from([0, 1, 2, 3])
    let intOb3 = from([0, 1, 2, 3, 4])
    
    combineLatest(intOb1, intOb2, intOb3) {
        ($0 + $1) * $2
        }
        >- subscribeNext {
            println($0)
    }
}

/*:
### `zip`

Takes several source Observables and a closure as parameters, returns an Observable  which emit the items of the second Obsevable procesed, through the closure, with the last item of first Observable
The Observable returned by `zip` emits an item only when all of the imputs Observables have emited an item
[More info in reactive.io website](http://reactivex.io/documentation/operators/zip.html)
*/

example("zip 1st") {
    let intOb1 = PublishSubject<String>()
    let intOb2 = PublishSubject<Int>()
    
    zip(intOb1, intOb2) {
        "\($0) \($1)"
        }
        >- subscribeNext {
            println($0)
    }
    
    println("send A to first channel")
    sendNext(intOb1, "A")
    println("note that nothing outputs")
    
    println("\nsend 1 to second channel")
    sendNext(intOb2, 1)
    println("now that both source channels have output, there is output")
    
    println("\nsend B to first channel")
    sendNext(intOb1, "B")
    println("note that nothing outputs, since channel 1 has two outputs but channel 2 only has one")
    
    println("\nsend C to first channel")
    sendNext(intOb1, "C")
    println("note that nothing outputs, it is the same as in the previous step, since channel 1 has three outputs but channel 2 only has one")
    
    println("\nsend 2 to second channel")
    sendNext(intOb2, 2)
    println("note that the combined channel emits a value with the second output of each channel")
    
    
}


//: This example show once in each channel there are output for each new channel output the resulting observable also produces an output

example("zip 2nd") {
    let intOb1 = just(2)
    let intOb2 = from([0, 1, 2, 3, 4])
    
    zip(intOb1, intOb2) {
        $0 * $1
        }
        >- subscribeNext {
            println($0)
    }
}

/*:
There are a serie of functions `zip`, they take from two to ten sources Obserbables and the closure
The next sample shows zip called with three sorce Observables
*/

example("zip 3rd") {
    let intOb1 = from([0, 1])
    let intOb2 = from([0, 1, 2, 3])
    let intOb3 = from([0, 1, 2, 3, 4])
    
    zip(intOb1, intOb2, intOb3) {
        ($0 + $1) * $2
        }
        >- subscribeNext {
            println($0)
    }
}



/*:
### `merge`

Combine multiple Observables, of the same type, into one by merging their emissions
[More info in reactive.io website]( http://reactivex.io/documentation/operators/merge.html )
*/

example("merge 1st") {
    let subject1 = PublishSubject<Int>()
    let subject2 = PublishSubject<Int>()
    
    merge(returnElements(subject1, subject2))
        >- subscribeNext { int in
            println(int)
    }
    
    sendNext(subject1, 20)
    sendNext(subject1, 40)
    sendNext(subject1, 60)
    sendNext(subject2, 1)
    sendNext(subject1, 80)
    sendNext(subject1, 100)
    sendNext(subject2, 1)
}


example("merge 2nd") {
    let subject1 = PublishSubject<Int>()
    let subject2 = PublishSubject<Int>()
    
    returnElements(subject1, subject2) 
        >- merge(maxConcurrent: 2)
        >- subscribeNext { int in
            println(int)
    }
    
    sendNext(subject1, 20)
    sendNext(subject1, 40)
    sendNext(subject1, 60)
    sendNext(subject2, 1)
    sendNext(subject1, 80)
    sendNext(subject1, 100)
    sendNext(subject2, 1)
}


/*:
### `switchLatest`

Convert an Observable that emits Observables into a single Observable that emits the items emitted by the most-recently-emitted of those Observables.
[More info in reactive.io website]( http://reactivex.io/documentation/operators/switch.html )
*/


example("switchLatest") {
    let var1 = Variable(0)
    let var2 = Variable(200)
    
    // var3 is like an Observable<Observable<Int>>
    let var3 = Variable(var1 as Observable<Int>)
    
    let d = var3
        >- switchLatest
        >- subscribeNext { (e: Int) -> Void in
            println("\(e)")
    }
    
    var1.next(1)
    var1.next(2)
    var1.next(3)
    var1.next(4)
    
    var3.next(var2)
    
    var2.next(201)
    
    println("Note which no listen to var1")
    var1.next(5)
    var1.next(6)
    var1.next(7)
    sendCompleted(var1)
    
    var2.next(202)
    var2.next(203)
    var2.next(204)
}

