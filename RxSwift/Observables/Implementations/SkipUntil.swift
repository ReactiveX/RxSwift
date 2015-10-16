//
//  SkipUntil.swift
//  Rx
//
//  Created by Yury Korolev on 10/3/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class SkipUntilSinkOther<ElementType, Other, O: ObserverType where O.E == ElementType> : ObserverType {
    typealias Parent = SkipUntilSink<ElementType, Other, O>
    typealias E = Other
    
    private let _parent: Parent
    
    private let _singleAssignmentDisposable = SingleAssignmentDisposable()
    
    var disposable: Disposable {
        get {
            abstractMethod()
        }
        set {
            _singleAssignmentDisposable.disposable = newValue
        }
    }

    init(parent: Parent) {
        _parent = parent
        #if TRACE_RESOURCES
            OSAtomicIncrement32(&resourceCount)
        #endif
    }

    func on(event: Event<E>) {
        switch event {
        case .Next:
            _parent._lock.performLocked {
                _parent._forwardElements = true
                _singleAssignmentDisposable.dispose()
            }
        case .Error(let e):
            _parent._lock.performLocked {
                _parent.observer?.onError(e)
                _parent.dispose()
            }
        case .Completed:
            _singleAssignmentDisposable.dispose()
        }
    }
    
    #if TRACE_RESOURCES
    deinit {
        OSAtomicDecrement32(&resourceCount)
    }
    #endif

}


class SkipUntilSink<ElementType, Other, O: ObserverType where O.E == ElementType> : Sink<O>, ObserverType {
    typealias E = ElementType
    typealias Parent = SkipUntil<E, Other>
    
    private let _lock = NSRecursiveLock()
    private let _parent: Parent
    private var _forwardElements = false
    
    private let _singleAssignmentDisposable = SingleAssignmentDisposable()
    
    var disposable: Disposable {
        get {
            abstractMethod()
        }
        set {
            _singleAssignmentDisposable.disposable = newValue
        }
    }
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        _parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<E>) {
        _lock.performLocked {
            switch event {
            case .Next:
                if _forwardElements {
                    observer?.on(event)
                }
            case .Error:
                observer?.on(event)
                dispose()
            case .Completed:
                if _forwardElements {
                    observer?.on(event)
                }
                _singleAssignmentDisposable.dispose()
            }
        }
    }
    
    func run() -> Disposable {
        let sourceSubscription = _parent._source.subscribeSafe(self)
        let otherObserver = SkipUntilSinkOther(parent: self)
        let otherSubscription = _parent._other.subscribeSafe(otherObserver)
        disposable = sourceSubscription
        otherObserver.disposable = otherSubscription
        
        return BinaryDisposable(sourceSubscription, otherSubscription)
    }
}

class SkipUntil<Element, Other>: Producer<Element> {
    
    private let _source: Observable<Element>
    private let _other: Observable<Other>
    
    init(source: Observable<Element>, other: Observable<Other>) {
        _source = source
        _other = other
    }
    
    override func run<O : ObserverType where O.E == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = SkipUntilSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
}
