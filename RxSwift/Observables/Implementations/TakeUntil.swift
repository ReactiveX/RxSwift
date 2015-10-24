//
//  TakeUntil.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/7/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class TakeUntilSinkOther<ElementType, Other, O: ObserverType where O.E == ElementType> : ObserverType {
    typealias Parent = TakeUntilSink<ElementType, Other, O>
    typealias E = Other
    
    private let _parent: Parent
    
    private let _singleAssignmentDisposable = SingleAssignmentDisposable()
    
    var disposable: Disposable {
        get {
            abstractMethod()
        }
        set(value) {
            _singleAssignmentDisposable.disposable = value
        }
    }
    
    init(parent: Parent) {
        _parent = parent
#if TRACE_RESOURCES
        OSAtomicIncrement32(&resourceCount)
#endif
    }
    
    func on(event: Event<E>) {
        _parent._lock.performLocked {
            switch event {
            case .Next:
                _parent.observer?.on(.Completed)
                _parent.dispose()
            case .Error(let e):
                _parent.observer?.on(.Error(e))
                _parent.dispose()
            case .Completed:
                _parent._open = true
                _singleAssignmentDisposable.dispose()
            }
        }
    }
    
#if TRACE_RESOURCES
    deinit {
        OSAtomicDecrement32(&resourceCount)
    }
#endif
}

class TakeUntilSink<ElementType, Other, O: ObserverType where O.E == ElementType> : Sink<O>, ObserverType {
    typealias E = ElementType
    typealias Parent = TakeUntil<E, Other>
    
    private let _parent: Parent
 
    private let _lock = NSRecursiveLock()
    
    // state
    private var _open = false
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        _parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<E>) {
        switch event {
        case .Next:
            if _open {
                observer?.on(event)
            }
            else {
                _lock.performLocked {
                    observer?.on(event)
                }
            }
        case .Error:
            _lock.performLocked {
                observer?.on(event)
                dispose()
            }
        case .Completed:
            _lock.performLocked {
                observer?.on(event)
                dispose()
            }
        }
    }
    
    func run() -> Disposable {
        let otherObserver = TakeUntilSinkOther(parent: self)
        let otherSubscription = _parent._other.subscribeSafe(otherObserver)
        otherObserver.disposable = otherSubscription
        let sourceSubscription = _parent._source.subscribeSafe(self)
        
        return CompositeDisposable(sourceSubscription, otherSubscription)
    }
}

class TakeUntil<Element, Other>: Producer<Element> {
    
    private let _source: Observable<Element>
    private let _other: Observable<Other>
    
    init(source: Observable<Element>, other: Observable<Other>) {
        _source = source
        _other = other
    }
    
    override func run<O : ObserverType where O.E == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = TakeUntilSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
}