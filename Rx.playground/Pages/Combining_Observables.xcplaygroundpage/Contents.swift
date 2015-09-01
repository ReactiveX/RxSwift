//: [<< Previous](@previous) - [Index](Index)

import RxSwift

/*:
## Combination operators

Operators that work with multiple source Observables to create a single Observable.


### `startWith`

Return an observeble which emits a specified item before emitting the items from the source Observable.

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/startwith.png)

[More info in reactive.io website]( http://reactivex.io/documentation/operators/startwith.html )
*/
example("startWith") {

    let aggregateSubscriber = sequenceOf(4, 5, 6, 7, 8, 9)
        .startWith(3)
        .startWith(2)
        .startWith(1)
        .startWith(0)
        .subscribeNext { int in
            print(int)
        }

}


/*:
### `combineLatest`

Takes several source Obserbables and a closure as parameters, returns an Observable which emits the latest items of each source Obsevable,  procesed through the closure.
Once each source Observables have each emitted an item, `combineLatest` emits an item every time either source Observable emits an item.

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/combinelatest.png)

[More info in reactive.io website]( http://reactivex.io/documentation/operators/combinelatest.html )

The next example shows how
*/
example("combineLatest 1st") {
    let intOb1 = PublishSubject<String>()
    let intOb2 = PublishSubject<Int>()

    combineLatest(intOb1, intOb2) {
        "\($0) \($1)"
        }
        .subscribeNext {
            print($0)
        }

    print("send A to first channel")
    intOb1.on(.Next("A"))
    print("note that nothing outputs")

    print("\nsend 1 to second channel")
    intOb2.on(.Next(1))
    print("now that there is something in both channels, there is output")

    print("\nsend B to first channel")
    intOb1.on(.Next("B"))
    print("now that both channels are full, whenever either channel emits a value, the combined channel also emits a value")

    print("\nsend 2 to second channel")
    intOb2.on(.Next(2))
    print("note that the combined channel emits a value whenever either sub-channel emits a value, even if the value is the same")
}


//: This example show once in each channel there are output for each new channel output the resulting observable also produces an output

example("combineLatest 2nd") {
    let intOb1 = just(2)
    let intOb2 = sequenceOf(0, 1, 2, 3, 4)

    combineLatest(intOb1, intOb2) {
            $0 * $1
        }
        .subscribeNext { (x: Int) in
            print(x)
        }
}


/*:
Rx has a group of `combineLatest` functions.
The next sample demonstrates `combineLatest` with three arguments.
*/
example("combineLatest 3rd") {
    let intOb1 = just(2)
    let intOb2 = sequenceOf(0, 1, 2, 3)
    let intOb3 = sequenceOf(0, 1, 2, 3, 4)

    combineLatest(intOb1, intOb2, intOb3) {
        ($0 + $1) * $2
        }
        .subscribeNext { (x: Int) in
            print(x)
        }
}



/*:
### `zip`

Takes several source Observables and a closure as parameters, returns an Observable  which emit the items of the second Obsevable procesed, through the closure, with the last item of first Observable
The Observable returned by `zip` emits an item only when all of the imputs Observables have emited an item

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/zip.png)

[More info in reactive.io website](http://reactivex.io/documentation/operators/zip.html)
*/
example("zip 1st") {
    let intOb1 = PublishSubject<String>()
    let intOb2 = PublishSubject<Int>()

    zip(intOb1, intOb2) {
        "\($0) \($1)"
        }
        .subscribeNext { (x: String) in
            print(x)
        }

    print("send A to first channel")
    sendNext(intOb1, "A")
    print("note that nothing outputs")

    print("\nsend 1 to second channel")
    sendNext(intOb2, 1)
    print("now that both source channels have output, there is output")

    print("\nsend B to first channel")
    sendNext(intOb1, "B")
    print("note that nothing outputs, since channel 1 has two outputs but channel 2 only has one")

    print("\nsend C to first channel")
    sendNext(intOb1, "C")
    print("note that nothing outputs, it is the same as in the previous step, since channel 1 has three outputs but channel 2 only has one")

    print("\nsend 2 to second channel")
    sendNext(intOb2, 2)
    print("note that the combined channel emits a value with the second output of each channel")
}


//: This example show once in each channel there are output for each new channel output the resulting observable also produces an output
example("zip 2nd") {
    let intOb1 = just(2)

    let intOb2 = sequenceOf(0, 1, 2, 3, 4)

    zip(intOb1, intOb2) {
            $0 * $1
        }
        .subscribeNext { (x: Int) in
            print(x)
        }
}


/*:
Demostrates simple usage of `zip` operator.
*/
example("zip 3rd") {
    let intOb1 = sequenceOf(0, 1)
    let intOb2 = sequenceOf(0, 1, 2, 3)
    let intOb3 = sequenceOf(0, 1, 2, 3, 4)

    zip(intOb1, intOb2, intOb3) {
        ($0 + $1) * $2
        }
        .subscribeNext { (x: Int) in
            print(x)
        }
}




/*:
### `merge`

Combine multiple Observables, of the same type, into one by merging their emissions

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/merge.png)

[More info in reactive.io website]( http://reactivex.io/documentation/operators/merge.html )
*/
example("merge 1st") {
    let subject1 = PublishSubject<Int>()
    let subject2 = PublishSubject<Int>()
    
    sequenceOf(subject1, subject2)
        .merge()
        .subscribeNext { int in
            print(int)
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
    
    sequenceOf(subject1, subject2) 
        .merge(maxConcurrent: 2)
        .subscribeNext { int in
            print(int)
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

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/switch.png)

[More info in reactive.io website]( http://reactivex.io/documentation/operators/switch.html )
*/
example("switchLatest") {
    let var1 = Variable(0)

    let var2 = Variable(200)

    // var3 is like an Observable<Observable<Int>>
    let var3 = Variable(var1)
    
    let d = var3
        .switchLatest()
        .subscribeNext { (e: Int) -> Void in
            print("\(e)")
        }

    var1.sendNext(1)
    var1.sendNext(2)
    var1.sendNext(3)
    var1.sendNext(4)

    var3.sendNext(var2)

    var2.sendNext(201)
    
    print("var1 isn't observed anymore")
    var1.sendNext(5)
    var1.sendNext(6)
    var1.sendNext(7)
}

//: [Index](Index) - [Next >>](@next)
