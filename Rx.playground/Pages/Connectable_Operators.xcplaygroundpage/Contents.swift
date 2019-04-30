/*:
 > # IMPORTANT: To use **Rx.playground**:
 1. Open **Rx.xcworkspace**.
 1. Build the **RxExample-macOS** scheme (**Product** → **Build**).
 1. Open **Rx** playground in the **Project navigator** (under RxExample project).
 1. Show the Debug Area (**View** → **Debug Area** → **Show Debug Area**).
 ----
 [Previous](@previous) - [Table of Contents](Table_of_Contents)
 */
import RxSwift

playgroundShouldContinueIndefinitely()
/*:
# Connectable Operators
 Connectable `Observable` sequences resembles ordinary `Observable` sequences, except that they not begin emitting elements when subscribed to, but instead, only when their `connect()` method is called. In this way, you can wait for all intended subscribers to subscribe to a connectable `Observable` sequence before it begins emitting elements.
 > Within each example on this page is a commented-out method. Uncomment that method to run the example, and then comment it out again to stop running the example.
 #
 Before learning about connectable operators, let's take a look at an example of a non-connectable operator:
*/
func sampleWithoutConnectableOperators() {
    printExampleHeader(#function)
    
    let interval = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
    
    _ = interval
        .subscribe(onNext: { print("Subscription: 1, Event: \($0)") })
    
    delay(5) {
        _ = interval
            .subscribe(onNext: { print("Subscription: 2, Event: \($0)") })
    }
}

//sampleWithoutConnectableOperators() // ⚠️ Uncomment to run this example; comment to stop running
/*:
 > `interval` creates an `Observable` sequence that emits elements after each `period`, on the specified scheduler. [More info](http://reactivex.io/documentation/operators/interval.html)
 ![](http://reactivex.io/documentation/operators/images/interval.c.png)
 ----
 ## `publish`
 Converts the source `Observable` sequence into a connectable sequence. [More info](http://reactivex.io/documentation/operators/publish.html)
 ![](http://reactivex.io/documentation/operators/images/publishConnect.c.png)
 */
func sampleWithPublish() {
    printExampleHeader(#function)
    
    let intSequence = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
        .publish()
    
    _ = intSequence
        .subscribe(onNext: { print("Subscription 1:, Event: \($0)") })
    
    delay(2) { _ = intSequence.connect() }
    
    delay(4) {
        _ = intSequence
            .subscribe(onNext: { print("Subscription 2:, Event: \($0)") })
    }
    
    delay(6) {
        _ = intSequence
            .subscribe(onNext: { print("Subscription 3:, Event: \($0)") })
    }
}

//sampleWithPublish() // ⚠️ Uncomment to run this example; comment to stop running

//: > Schedulers are an abstraction of mechanisms for performing work, such as on specific threads or dispatch queues. [More info](https://github.com/ReactiveX/RxSwift/blob/master/Documentation/Schedulers.md)

/*:
 ----
 ## `replay`
 Converts the source `Observable` sequence into a connectable sequence, and will replay `bufferSize` number of previous emissions to each new subscriber. [More info](http://reactivex.io/documentation/operators/replay.html)
 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/replay.png)
 */
func sampleWithReplayBuffer() {
    printExampleHeader(#function)
    
    let intSequence = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
        .replay(5)
    
    _ = intSequence
        .subscribe(onNext: { print("Subscription 1:, Event: \($0)") })
    
    delay(2) { _ = intSequence.connect() }
    
    delay(4) {
        _ = intSequence
            .subscribe(onNext: { print("Subscription 2:, Event: \($0)") })
    }
    
    delay(8) {
        _ = intSequence
            .subscribe(onNext: { print("Subscription 3:, Event: \($0)") })
    }
}

// sampleWithReplayBuffer() // ⚠️ Uncomment to run this example; comment to stop running

/*:
 ----
 ## `multicast`
 Converts the source `Observable` sequence into a connectable sequence, and broadcasts its emissions via the specified `subject`.
 */
func sampleWithMulticast() {
    printExampleHeader(#function)
    
    let subject = PublishSubject<Int>()
    
    _ = subject
        .subscribe(onNext: { print("Subject: \($0)") })
    
    let intSequence = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
        .multicast(subject)
    
    _ = intSequence
        .subscribe(onNext: { print("\tSubscription 1:, Event: \($0)") })
    
    delay(2) { _ = intSequence.connect() }
    
    delay(4) {
        _ = intSequence
            .subscribe(onNext: { print("\tSubscription 2:, Event: \($0)") })
    }
    
    delay(6) {
        _ = intSequence
            .subscribe(onNext: { print("\tSubscription 3:, Event: \($0)") })
    }
}

//sampleWithMulticast() // ⚠️ Uncomment to run this example; comment to stop running

//: [Next](@next) - [Table of Contents](Table_of_Contents)
