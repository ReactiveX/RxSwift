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
    subject.on(.Next("🐶"))
    subject.on(.Next("🐱"))
    writeSequenceToConsole("2", sequence: subject).addDisposableTo(disposeBag)
    subject.on(.Next("🅰️"))
    subject.on(.Next("🅱️"))
}


/*:

## ReplaySubject

`ReplaySubject` emits to any observer all of the items that were emitted by the source Observable(s), regardless of when the observer subscribes.
 When a new observer subscribes to a `ReplaySubject` it will receive only the past sent items that are currently
 held in the buffer and then any new items that come later.
 In the example below the buffer size is `1` so new observers will be able to see at most `1` item
 from the past. i.e `Subscription: 2` will see the item `"b"` that was sent just before it subscribed but not `"a"` since the buffer size is less than `2`.

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/replaysubject.png)
*/
example("ReplaySubject") {
    let disposeBag = DisposeBag()
    let subject = ReplaySubject<String>.createUnbounded()

    writeSequenceToConsole("1", sequence: subject).addDisposableTo(disposeBag)
    subject.on(.Next("🐶"))
    subject.on(.Next("🐱"))
    writeSequenceToConsole("2", sequence: subject).addDisposableTo(disposeBag)
    subject.on(.Next("🅰️"))
    subject.on(.Next("🅱️"))
}


/*:

## BehaviorSubject

When an observer subscribes to a `BehaviorSubject`, it begins by emitting the item most recently emitted by the source Observable (or a seed/default value if none has yet been emitted) and then continues to emit any other items emitted later by the source Observable(s).

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/behaviorsubject.png)

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/behaviorsubject_error.png)
*/
example("BehaviorSubject") {
    let disposeBag = DisposeBag()

    let subject = BehaviorSubject(value: "🔴")
    writeSequenceToConsole("1", sequence: subject).addDisposableTo(disposeBag)
    subject.on(.Next("🐶"))
    subject.on(.Next("🐱"))
    writeSequenceToConsole("2", sequence: subject).addDisposableTo(disposeBag)
    subject.on(.Next("🅰️"))
    subject.on(.Next("🅱️"))
    subject.on(.Completed)
}

/*:

## Variable

`Variable` wraps `BehaviorSubject`. The Advantage of using variable over `BehaviorSubject` is that `Variable` can never explicitly complete or error out, whereas `BehaviorSubject` can emit `Error` or `Completed` messages. `Variable` will also automatically complete if deallocated.

*/
example("Variable") {
    let disposeBag = DisposeBag()
    let variable = Variable("🔴")
    writeSequenceToConsole("1", sequence: variable.asObservable()).addDisposableTo(disposeBag)
    variable.value = "🐶"
    variable.value = "🐱"
    writeSequenceToConsole("2", sequence: variable.asObservable()).addDisposableTo(disposeBag)
    variable.value = "🅰️"
    variable.value = "🅱️"
}

//: [Index](Index) - [Next >>](@next)
