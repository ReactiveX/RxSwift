//
//  SkipUntil.swift
//  RxSwift
//
//  Created by Yury Korolev on 10/3/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

public extension ObservableType {
    /**
     Returns the elements from the source observable sequence that are emitted after the other observable sequence produces an element.

     - seealso: [skipUntil operator on reactivex.io](http://reactivex.io/documentation/operators/skipuntil.html)

     - parameter other: Observable sequence that starts propagation of elements of the source sequence.
     - returns: An observable sequence containing the elements of the source sequence that are emitted after the other sequence emits an item.
     */
    func skip(until other: some ObservableType)
        -> Observable<Element>
    {
        SkipUntil(source: asObservable(), other: other.asObservable())
    }

    /**
     Returns the elements from the source observable sequence that are emitted after the other observable sequence produces an element.

     - seealso: [skipUntil operator on reactivex.io](http://reactivex.io/documentation/operators/skipuntil.html)

     - parameter other: Observable sequence that starts propagation of elements of the source sequence.
     - returns: An observable sequence containing the elements of the source sequence that are emitted after the other sequence emits an item.
     */
    @available(*, deprecated, renamed: "skip(until:)")
    func skipUntil(_ other: some ObservableType)
        -> Observable<Element>
    {
        skip(until: other)
    }
}

private final class SkipUntilSinkOther<Other, Observer: ObserverType>:
    ObserverType,
    LockOwnerType,
    SynchronizedOnType
{
    typealias Parent = SkipUntilSink<Other, Observer>
    typealias Element = Other

    private let parent: Parent

    var lock: RecursiveLock {
        parent.lock
    }

    let subscription = SingleAssignmentDisposable()

    init(parent: Parent) {
        self.parent = parent
        #if TRACE_RESOURCES
        _ = Resources.incrementTotal()
        #endif
    }

    func on(_ event: Event<Element>) {
        synchronizedOn(event)
    }

    func synchronized_on(_ event: Event<Element>) {
        switch event {
        case .next:
            parent.forwardElements = true
            subscription.dispose()
        case let .error(e):
            parent.forwardOn(.error(e))
            parent.dispose()
        case .completed:
            subscription.dispose()
        }
    }

    #if TRACE_RESOURCES
    deinit {
        _ = Resources.decrementTotal()
    }
    #endif
}

private final class SkipUntilSink<Other, Observer: ObserverType>:
    Sink<Observer>,
    ObserverType,
    LockOwnerType,
    SynchronizedOnType
{
    typealias Element = Observer.Element
    typealias Parent = SkipUntil<Element, Other>

    let lock = RecursiveLock()
    private let parent: Parent
    fileprivate var forwardElements = false

    private let sourceSubscription = SingleAssignmentDisposable()

    init(parent: Parent, observer: Observer, cancel: Cancelable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }

    func on(_ event: Event<Element>) {
        synchronizedOn(event)
    }

    func synchronized_on(_ event: Event<Element>) {
        switch event {
        case .next:
            if forwardElements {
                forwardOn(event)
            }
        case .error:
            forwardOn(event)
            dispose()
        case .completed:
            if forwardElements {
                forwardOn(event)
            }
            dispose()
        }
    }

    func run() -> Disposable {
        let sourceSubscription = parent.source.subscribe(self)
        let otherObserver = SkipUntilSinkOther(parent: self)
        let otherSubscription = parent.other.subscribe(otherObserver)
        self.sourceSubscription.setDisposable(sourceSubscription)
        otherObserver.subscription.setDisposable(otherSubscription)

        return Disposables.create(sourceSubscription, otherObserver.subscription)
    }
}

private final class SkipUntil<Element, Other>: Producer<Element> {
    fileprivate let source: Observable<Element>
    fileprivate let other: Observable<Other>

    init(source: Observable<Element>, other: Observable<Other>) {
        self.source = source
        self.other = other
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element {
        let sink = SkipUntilSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}
