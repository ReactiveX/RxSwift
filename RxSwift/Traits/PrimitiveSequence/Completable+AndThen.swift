//
//  Completable+AndThen.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 7/2/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

public extension PrimitiveSequenceType where Trait == CompletableTrait, Element == Never {
    /**
     Concatenates the second observable sequence to `self` upon successful termination of `self`.

     - seealso: [concat operator on reactivex.io](http://reactivex.io/documentation/operators/concat.html)

     - parameter second: Second observable sequence.
     - returns: An observable sequence that contains the elements of `self`, followed by those of the second sequence.
     */
    func andThen<Element>(_ second: Single<Element>) -> Single<Element> {
        let completable = primitiveSequence.asObservable()
        return Single(raw: ConcatCompletable(completable: completable, second: second.asObservable()))
    }

    /**
     Concatenates the second observable sequence to `self` upon successful termination of `self`.

     - seealso: [concat operator on reactivex.io](http://reactivex.io/documentation/operators/concat.html)

     - parameter second: Second observable sequence.
     - returns: An observable sequence that contains the elements of `self`, followed by those of the second sequence.
     */
    func andThen<Element>(_ second: Maybe<Element>) -> Maybe<Element> {
        let completable = primitiveSequence.asObservable()
        return Maybe(raw: ConcatCompletable(completable: completable, second: second.asObservable()))
    }

    /**
     Concatenates the second observable sequence to `self` upon successful termination of `self`.

     - seealso: [concat operator on reactivex.io](http://reactivex.io/documentation/operators/concat.html)

     - parameter second: Second observable sequence.
     - returns: An observable sequence that contains the elements of `self`, followed by those of the second sequence.
     */
    func andThen(_ second: Completable) -> Completable {
        let completable = primitiveSequence.asObservable()
        return Completable(raw: ConcatCompletable(completable: completable, second: second.asObservable()))
    }

    /**
     Concatenates the second observable sequence to `self` upon successful termination of `self`.

     - seealso: [concat operator on reactivex.io](http://reactivex.io/documentation/operators/concat.html)

     - parameter second: Second observable sequence.
     - returns: An observable sequence that contains the elements of `self`, followed by those of the second sequence.
     */
    func andThen<Element>(_ second: Observable<Element>) -> Observable<Element> {
        let completable = primitiveSequence.asObservable()
        return ConcatCompletable(completable: completable, second: second.asObservable())
    }
}

private final class ConcatCompletable<Element>: Producer<Element> {
    fileprivate let completable: Observable<Never>
    fileprivate let second: Observable<Element>

    init(completable: Observable<Never>, second: Observable<Element>) {
        self.completable = completable
        self.second = second
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element {
        let sink = ConcatCompletableSink(second: second, observer: observer, cancel: cancel)
        let subscription = sink.run(completable: completable)
        return (sink: sink, subscription: subscription)
    }
}

private final class ConcatCompletableSink<Observer: ObserverType>:
    Sink<Observer>,
    ObserverType
{
    typealias Element = Never
    typealias Parent = ConcatCompletable<Observer.Element>

    private let second: Observable<Observer.Element>
    private let subscription = SerialDisposable()

    init(second: Observable<Observer.Element>, observer: Observer, cancel: Cancelable) {
        self.second = second
        super.init(observer: observer, cancel: cancel)
    }

    func on(_ event: Event<Element>) {
        switch event {
        case let .error(error):
            forwardOn(.error(error))
            dispose()
        case .next:
            break
        case .completed:
            let otherSink = ConcatCompletableSinkOther(parent: self)
            subscription.disposable = second.subscribe(otherSink)
        }
    }

    func run(completable: Observable<Never>) -> Disposable {
        let subscription = SingleAssignmentDisposable()
        self.subscription.disposable = subscription
        subscription.setDisposable(completable.subscribe(self))
        return self.subscription
    }
}

private final class ConcatCompletableSinkOther<Observer: ObserverType>:
    ObserverType
{
    typealias Element = Observer.Element

    typealias Parent = ConcatCompletableSink<Observer>

    private let parent: Parent

    init(parent: Parent) {
        self.parent = parent
    }

    func on(_ event: Event<Observer.Element>) {
        parent.forwardOn(event)
        if event.isStopEvent {
            parent.dispose()
        }
    }
}
