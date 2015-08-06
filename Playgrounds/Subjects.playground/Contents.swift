import Cocoa
import RxSwift

/*:

To use playgrounds please open Rx.xcworkspace, build RxSwift-OSX scheme and then open playgrounds in Rx.xcworkspace tree view.

*/

func writeSequenceToConsole(name: String, sequence: Observable<String>) {
    sequence
        >- subscribeNext {
            println("Subscription: \(name), value: \($0)")
        }
}


/*:

## PublishSubject

PublishSubject can begin emitting items immediately upon creation, but there is a risk that one or more items may be lost between the time the Subject is created and the observer subscribes to it.

*/
example("PublishSubject") {
    let subject = PublishSubject<String>()
    writeSequenceToConsole("1", subject)
    sendNext(subject, "a")
    sendNext(subject, "b")
    writeSequenceToConsole("2", subject)
    sendNext(subject, "c")
    sendNext(subject, "d")
}


/*:

## ReplaySubject

ReplaySubject emits to any observer all of the items, in the buffer, that were emitted by the source 

*/
example("ReplaySubject") {
    let subject = ReplaySubject<String>(bufferSize: 1)
    writeSequenceToConsole("1", subject)
    sendNext(subject, "a")
    sendNext(subject, "b")
    writeSequenceToConsole("2", subject)
    sendNext(subject, "c")
    sendNext(subject, "d")
}


/*:

## BehaviorSubject a.k.a. Variable

BehaviorSubject is similar to ReplaySubject except it only remembers the last item. This means that all subscribers will receive a value immediately (unless it is already completed).
*/
example("BehaviorSubject") {
    let subject = BehaviorSubject(value: "z")
    writeSequenceToConsole("1", subject)
    sendNext(subject, "a")
    sendNext(subject, "b")
    writeSequenceToConsole("2", subject)
    sendNext(subject, "c")
    sendNext(subject, "d")
}
