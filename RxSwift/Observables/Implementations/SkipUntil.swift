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
            return abstractMethod()
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
        // Do we need lock here?
        _parent.lock.performLocked {
            switch event {
            case .Next:
                _parent.__observer = _parent.observer
                _singleAssignmentDisposable.dispose()
            case .Error(let e):
                _parent._observer?.onError(e)
                _parent.dispose()
            case .Completed:
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


class SkipUntilSink<ElementType, Other, O: ObserverType where O.E == ElementType> : Sink<O>, ObserverType {
    typealias E = ElementType
    typealias Parent = SkipUntil<E, Other>
    
    private let _parent: Parent
    let lock = NSRecursiveLock()
    var __observer: O? // Nop observer for start. Need better name
    
    private let _singleAssignmentDisposable = SingleAssignmentDisposable()
    
    var disposable: Disposable {
        get {
            return abstractMethod()
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
        switch event {
        case .Next:
            __observer?.on(event)
        case .Error:
            observer?.on(event)
            dispose()
        case .Completed:
            __observer?.on(event)
            _singleAssignmentDisposable.dispose()
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

// MARK: SkipUntil time

class SkipUntilTimeSink<ElementType, S: SchedulerType, O: ObserverType where O.E == ElementType> : Sink<O>, ObserverType {
    
    typealias E = ElementType
    typealias Parent = SkipUntilTime<E, S>
    
    private let _parent: Parent
    
    // state
    private var _open: Bool = false
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        _parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<E>) {
        switch(event) {
        case let .Next(element):
            if _open {
                observer?.onNext(element)
            }
        case let .Error(error):
            _observer?.onError(error)
            dispose()
        case .Completed:
            _observer?.onComplete()
            dispose()
        }
    }
    
    func run() -> Disposable {
        // Actually it should be abs time here. Or diff from now
        let disposeTimer = _parent._scheduler.scheduleRelative((), dueTime:_parent._startTime) {
                self._tick()
                return NopDisposable.instance
            }
        let disposeSubscription = _parent._source.subscribeSafe(self)
        return BinaryDisposable(disposeTimer, disposeSubscription)
    }
    
    private func _tick() {
        _open = true
    }
}

class SkipUntilTime<Element, S: SchedulerType>: Producer<Element> {
    typealias TimeInterval = S.TimeInterval
    
    private let _source: Observable<Element>
    private let _startTime: TimeInterval
    private let _scheduler: S
    
    init(source: Observable<Element>, startTime: TimeInterval, scheduler: S) {
        _source = source
        _startTime = startTime
        _scheduler = scheduler
    }
    
    override func run<O : ObserverType where O.E == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = SkipUntilTimeSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
}

