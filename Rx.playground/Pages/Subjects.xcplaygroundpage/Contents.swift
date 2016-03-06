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

A Subject is a sort of bridge or proxy that is available in some implementations of ReactiveX that acts both as an observer and as an Observable. Because it is an observer, it can subscribe to one or more Observables, and because it is an Observable, it can pass through the items it observes by reemitting them, and it can also emit new items.
*/

func writeSequenceToConsole<O: ObservableType>(name: String, sequence: O) -> Disposable {
    return sequence
        .subscribe { e in
            print("Subscription: \(name), event: \(e)")
        }
}


/*:

## PublishSubject

`PublishSubject` emits to an observer only those items that are emitted by the source Observable(s) subsequent to the time of the subscription.

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/publishsubject.png)

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/publishsubject_error.png)

*/
example("PublishSubject") {
    let disposeBag = DisposeBag()

    let subject = PublishSubject<String>()
    writeSequenceToConsole("1", sequence: subject).addDisposableTo(disposeBag)
    subject.on(.Next("a"))
    subject.on(.Next("b"))
    writeSequenceToConsole("2", sequence: subject).addDisposableTo(disposeBag)
    subject.on(.Next("c"))
    subject.on(.Next("d"))
}


/*:

## ReplaySubject

`ReplaySubject` emits to any observer all of the items that were emitted by the source Observable(s), regardless of when the observer subscribes.

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/replaysubject.png)
*/
example("ReplaySubject") {
    let disposeBag = DisposeBag()
    let subject = ReplaySubject<String>.create(bufferSize: 1)

    writeSequenceToConsole("1", sequence: subject).addDisposableTo(disposeBag)
    subject.on(.Next("a"))
    subject.on(.Next("b"))
    writeSequenceToConsole("2", sequence: subject).addDisposableTo(disposeBag)
    subject.on(.Next("c"))
    subject.on(.Next("d"))
}


/*:

## BehaviorSubject

When an observer subscribes to a `BehaviorSubject`, it begins by emitting the item most recently emitted by the source Observable (or a seed/default value if none has yet been emitted) and then continues to emit any other items emitted later by the source Observable(s).

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/behaviorsubject.png)

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/behaviorsubject_error.png)
*/
example("BehaviorSubject") {
    let disposeBag = DisposeBag()

    let subject = BehaviorSubject(value: "z")
    writeSequenceToConsole("1", sequence: subject).addDisposableTo(disposeBag)
    subject.on(.Next("a"))
    subject.on(.Next("b"))
    writeSequenceToConsole("2", sequence: subject).addDisposableTo(disposeBag)
    subject.on(.Next("c"))
    subject.on(.Next("d"))
    subject.on(.Completed)
}

/*:

## Variable

`Variable` wraps `BehaviorSubject`. Advantage of using variable over `BehaviorSubject` is that variable can never explicitly complete or error out, and `BehaviorSubject` can in case `Error` or `Completed` message is send to it. `Variable` will also automatically complete in case it's being deallocated.

*/
example("Variable") {
    let disposeBag = DisposeBag()
    let variable = Variable("z")
    writeSequenceToConsole("1", sequence: variable.asObservable()).addDisposableTo(disposeBag)
    variable.value = "a"
    variable.value = "b"
    writeSequenceToConsole("2", sequence: variable.asObservable()).addDisposableTo(disposeBag)
    variable.value = "c"
    variable.value = "d"
}

//: [Index](Index) - [Next >>](@next)
