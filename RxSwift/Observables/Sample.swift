//
//  Sample.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 5/1/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

public extension ObservableType {
    /**
     Samples the source observable sequence using a sampler observable sequence producing sampling ticks.

     Upon each sampling tick, the latest element (if any) in the source sequence during the last sampling interval is sent to the resulting sequence.

     **In case there were no new elements between sampler ticks, you may provide a default value to be emitted, instead
       to the resulting sequence otherwise no element is sent.**

     - seealso: [sample operator on reactivex.io](http://reactivex.io/documentation/operators/sample.html)

     - parameter sampler: Sampling tick sequence.
     - parameter defaultValue: a value to return if there are no new elements between sampler ticks
     - returns: Sampled observable sequence.
     */
    func sample(_ sampler: some ObservableType, defaultValue: Element? = nil)
        -> Observable<Element>
    {
        Sample(source: asObservable(), sampler: sampler.asObservable(), defaultValue: defaultValue)
    }
}

private final class SamplerSink<Observer: ObserverType, SampleType>:
    ObserverType,
    LockOwnerType,
    SynchronizedOnType
{
    typealias Element = SampleType

    typealias Parent = SampleSequenceSink<Observer, SampleType>

    private let parent: Parent

    var lock: RecursiveLock {
        parent.lock
    }

    init(parent: Parent) {
        self.parent = parent
    }

    func on(_ event: Event<Element>) {
        synchronizedOn(event)
    }

    func synchronized_on(_ event: Event<Element>) {
        switch event {
        case .next, .completed:
            if let element = parent.element ?? parent.defaultValue {
                parent.element = nil
                parent.forwardOn(.next(element))
            }

            if parent.atEnd {
                parent.forwardOn(.completed)
                parent.dispose()
            }
        case let .error(e):
            parent.forwardOn(.error(e))
            parent.dispose()
        }
    }
}

private final class SampleSequenceSink<Observer: ObserverType, SampleType>:
    Sink<Observer>,
    ObserverType,
    LockOwnerType,
    SynchronizedOnType
{
    typealias Element = Observer.Element
    typealias Parent = Sample<Element, SampleType>

    fileprivate let parent: Parent
    fileprivate let defaultValue: Element?

    let lock = RecursiveLock()

    // state
    fileprivate var element = nil as Element?
    fileprivate var atEnd = false

    private let sourceSubscription = SingleAssignmentDisposable()

    init(parent: Parent, observer: Observer, cancel: Cancelable, defaultValue: Element? = nil) {
        self.parent = parent
        self.defaultValue = defaultValue
        super.init(observer: observer, cancel: cancel)
    }

    func run() -> Disposable {
        sourceSubscription.setDisposable(parent.source.subscribe(self))
        let samplerSubscription = parent.sampler.subscribe(SamplerSink(parent: self))

        return Disposables.create(sourceSubscription, samplerSubscription)
    }

    func on(_ event: Event<Element>) {
        synchronizedOn(event)
    }

    func synchronized_on(_ event: Event<Element>) {
        switch event {
        case let .next(element):
            self.element = element
        case .error:
            forwardOn(event)
            dispose()
        case .completed:
            atEnd = true
            sourceSubscription.dispose()
        }
    }
}

private final class Sample<Element, SampleType>: Producer<Element> {
    fileprivate let source: Observable<Element>
    fileprivate let sampler: Observable<SampleType>
    fileprivate let defaultValue: Element?

    init(source: Observable<Element>, sampler: Observable<SampleType>, defaultValue: Element? = nil) {
        self.source = source
        self.sampler = sampler
        self.defaultValue = defaultValue
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element {
        let sink = SampleSequenceSink(parent: self, observer: observer, cancel: cancel, defaultValue: defaultValue)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}
