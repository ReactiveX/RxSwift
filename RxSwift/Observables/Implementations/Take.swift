//
//  Take.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/12/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// count version

class TakeCountSink<ElementType, O: ObserverType where O.E == ElementType> : Sink<O>, ObserverType {
    typealias Parent = TakeCount<ElementType>
    typealias E = ElementType
    
    private let _parent: Parent
    
    private var _remaining: Int
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        _parent = parent
        _remaining = parent._count
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<E>) {
        switch event {
        case .Next(let value):
            
            if _remaining > 0 {
                _remaining--
                
                observer?.on(.Next(value))
            
                if _remaining == 0 {
                    observer?.on(.Completed)
                    dispose()
                }
            }
        case .Error:
            observer?.on(event)
            dispose()
        case .Completed:
            observer?.on(event)
            dispose()
        }
    }
    
}

class TakeCount<Element>: Producer<Element> {
    private let _source: Observable<Element>
    private let _count: Int
    
    init(source: Observable<Element>, count: Int) {
        _source = source
        _count = count
    }
    
    override func run<O : ObserverType where O.E == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = TakeCountSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return _source.subscribeSafe(sink)
    }
}

// time version

class TakeTimeSink<ElementType, S: SchedulerType, O: ObserverType where O.E == ElementType> : Sink<O>, ObserverType {
    typealias Parent = TakeTime<ElementType, S>
    typealias E = ElementType

    private let _parent: Parent
    
    private let _lock = NSRecursiveLock()
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        _parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<E>) {
        _lock.performLocked {
            switch event {
            case .Next(let value):
                observer?.on(.Next(value))
            case .Error:
                observer?.on(event)
                dispose()
            case .Completed:
                observer?.on(event)
                dispose()
            }
        }
    }
    
    func tick() {
        _lock.performLocked {
            observer?.on(.Completed)
            dispose()
        }
    }
    
    func run() -> Disposable {
        let disposeTimer = _parent._scheduler.scheduleRelative((), dueTime: _parent._duration) {
            self.tick()
            return NopDisposable.instance
        }
        
        let disposeSubscription = _parent._source.subscribeSafe(self)
        
        return BinaryDisposable(disposeTimer, disposeSubscription)
    }
}

class TakeTime<Element, S: SchedulerType>: Producer<Element> {
    typealias TimeInterval = S.TimeInterval
    
    private let _source: Observable<Element>
    private let _duration: TimeInterval
    private let _scheduler: S
    
    init(source: Observable<Element>, duration: TimeInterval, scheduler: S) {
        _source = source
        _scheduler = scheduler
        _duration = duration
    }
    
    override func run<O : ObserverType where O.E == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = TakeTimeSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
}