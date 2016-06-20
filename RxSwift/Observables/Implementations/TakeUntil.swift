//
//  TakeUntil.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/7/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class TakeUntilSinkOther<ElementType, Other, O: ObserverType where O.E == ElementType>
    : ObserverType
    , LockOwnerType
    , SynchronizedOnType {
    typealias Parent = TakeUntilSink<ElementType, Other, O>
    typealias E = Other
    
    private let _parent: Parent

    var _lock: RecursiveLock {
        return _parent._lock
    }
    
    private let _subscription = SingleAssignmentDisposable()
    
    init(parent: Parent) {
        _parent = parent
#if TRACE_RESOURCES
        _ = AtomicIncrement(&resourceCount)
#endif
    }
    
    func on(event: Event<E>) {
        synchronizedOn(event: event)
    }

    func _synchronized_on(event: Event<E>) {
        switch event {
        case .Next:
            _parent.forwardOn(event: .Completed)
            _parent.dispose()
        case .Error(let e):
            _parent.forwardOn(event: .Error(e))
            _parent.dispose()
        case .Completed:
            _parent._open = true
            _subscription.dispose()
        }
    }
    
#if TRACE_RESOURCES
    deinit {
        _ = AtomicDecrement(&resourceCount)
    }
#endif
}

class TakeUntilSink<ElementType, Other, O: ObserverType where O.E == ElementType>
    : Sink<O>
    , LockOwnerType
    , ObserverType
    , SynchronizedOnType {
    typealias E = ElementType
    typealias Parent = TakeUntil<E, Other>
    
    private let _parent: Parent
 
    let _lock = RecursiveLock()
    
    // state
    private var _open = false
    
    init(parent: Parent, observer: O) {
        _parent = parent
        super.init(observer: observer)
    }
    
    func on(event: Event<E>) {
        synchronizedOn(event: event)
    }

    func _synchronized_on(event: Event<E>) {
        switch event {
        case .Next:
            forwardOn(event: event)
        case .Error:
            forwardOn(event: event)
            dispose()
        case .Completed:
            forwardOn(event: event)
            dispose()
        }
    }
    
    func run() -> Disposable {
        let otherObserver = TakeUntilSinkOther(parent: self)
        let otherSubscription = _parent._other.subscribe(observer: otherObserver)
        otherObserver._subscription.disposable = otherSubscription
        let sourceSubscription = _parent._source.subscribe(observer: self)
        
        return StableCompositeDisposable.create(sourceSubscription, otherObserver._subscription)
    }
}

class TakeUntil<Element, Other>: Producer<Element> {
    
    private let _source: Observable<Element>
    private let _other: Observable<Other>
    
    init(source: Observable<Element>, other: Observable<Other>) {
        _source = source
        _other = other
    }
    
    override func run<O : ObserverType where O.E == Element>(observer: O) -> Disposable {
        let sink = TakeUntilSink(parent: self, observer: observer)
        sink.disposable = sink.run()
        return sink
    }
}
