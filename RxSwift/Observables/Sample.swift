//
//  Sample.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 5/1/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension ObservableType {

    /**
     Samples the source observable sequence using a sampler observable sequence producing sampling ticks.

     Upon each sampling tick, the latest element (if any) in the source sequence during the last sampling interval is sent to the resulting sequence.

     **In case there were no new elements between sampler ticks, no element is sent to the resulting sequence.**

     - seealso: [sample operator on reactivex.io](http://reactivex.io/documentation/operators/sample.html)

     - parameter sampler: Sampling tick sequence.
     - returns: Sampled observable sequence.
     */
    public func sample<Source: ObservableType>(_ sampler: Source)
        -> Observable<Element> {
            return Sample(source: self.asObservable(), sampler: sampler.asObservable())
    }
}

final private class SamplerSink<Observer: ObserverType, SampleType>
    : ObserverType
    , LockOwnerType
    , SynchronizedOnType {
    typealias Element = SampleType
    
    typealias Parent = SampleSequenceSink<Observer, SampleType>
    
    private let parent: Parent

    var lock: RecursiveLock {
        self.parent.lock
    }
    
    init(parent: Parent) {
        self.parent = parent
    }
    
    func on(_ event: Event<Element>) {
        self.synchronizedOn(event)
    }

    func synchronized_on(_ event: Event<Element>) {
        switch event {
        case .next, .completed:
            if let element = parent.element {
                self.parent.element = nil
                self.parent.forwardOn(.next(element))
            }

            if self.parent.atEnd {
                self.parent.forwardOn(.completed)
                self.parent.dispose()
            }
        case .error(let e):
            self.parent.forwardOn(.error(e))
            self.parent.dispose()
        }
    }
}

final private class SampleSequenceSink<Observer: ObserverType, SampleType>
    : Sink<Observer>
    , ObserverType
    , LockOwnerType
    , SynchronizedOnType {
    typealias Element = Observer.Element 
    typealias Parent = Sample<Element, SampleType>
    
    private let parent: Parent

    let lock = RecursiveLock()
    
    // state
    fileprivate var element = nil as Element?
    fileprivate var atEnd = false
    
    private let sourceSubscription = SingleAssignmentDisposable()
    
    init(parent: Parent, observer: Observer, cancel: Cancelable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Disposable {
        self.sourceSubscription.setDisposable(self.parent.source.subscribe(self))
        let samplerSubscription = self.parent.sampler.subscribe(SamplerSink(parent: self))
        
        return Disposables.create(sourceSubscription, samplerSubscription)
    }
    
    func on(_ event: Event<Element>) {
        self.synchronizedOn(event)
    }

    func synchronized_on(_ event: Event<Element>) {
        switch event {
        case .next(let element):
            self.element = element
        case .error:
            self.forwardOn(event)
            self.dispose()
        case .completed:
            self.atEnd = true
            self.sourceSubscription.dispose()
        }
    }
    
}

final private class Sample<Element, SampleType>: Producer<Element> {
    fileprivate let source: Observable<Element>
    fileprivate let sampler: Observable<SampleType>

    init(source: Observable<Element>, sampler: Observable<SampleType>) {
        self.source = source
        self.sampler = sampler
    }
    
    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element {
        let sink = SampleSequenceSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}
