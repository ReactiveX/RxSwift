//: [<< Previous](@previous) - [Index](Index)

import RxSwift

func writeSequenceToConsole(name: String, sequence: Observable<String>) {
    sequence
        .subscribeNext {
            print("Subscription: \(name), value: \($0)")
        }
}


/*:

## PublishSubject

PublishSubject can begin emitting items immediately upon creation, but there is a risk that one or more items may be lost between the time the Subject is created and the observer subscribes to it.

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/publishsubject.png)

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/publishsubject_error.png)

*/
example("PublishSubject") {
    let subject = PublishSubject<String>()
    writeSequenceToConsole("1", sequence: subject)
    sendNext(subject, "a")
    sendNext(subject, "b")
    writeSequenceToConsole("2", sequence: subject)
    sendNext(subject, "c")
    sendNext(subject, "d")
}


/*:

## ReplaySubject

ReplaySubject emits to any observer all of the items, in the buffer, that were emitted by the source
![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/replaysubject.png)
*/
example("ReplaySubject") {
    let subject = ReplaySubject<String>.create(bufferSize: 1)
    writeSequenceToConsole("1", sequence: subject)
    sendNext(subject, "a")
    sendNext(subject, "b")
    writeSequenceToConsole("2", sequence: subject)
    sendNext(subject, "c")
    sendNext(subject, "d")
}


/*:

## BehaviorSubject a.k.a. Variable

When an observer subscribes to a `BehaviorSubject`, it begins by emitting the item most recently emitted by the source Observable (or a seed/default value if none has yet been emitted) and then continues to emit any other items emitted later by the source Observable(s).

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/behaviorsubject.png)

![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/behaviorsubject_error.png)
*/
example("BehaviorSubject") {
    let subject = BehaviorSubject(value: "z")
    writeSequenceToConsole("1", sequence: subject)
    sendNext(subject, "a")
    sendNext(subject, "b")
    writeSequenceToConsole("2", sequence: subject)
    sendNext(subject, "c")
    sendNext(subject, "d")
}


//: [Index](Index) - [Next >>](@next)
