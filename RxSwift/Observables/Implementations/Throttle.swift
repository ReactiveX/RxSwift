//
//  Throttle.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/22/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class ThrottleSink<O: ObserverType, Scheduler: SchedulerType> : Sink<O>, ObserverType {
    typealias Element = O.E
    typealias ParentType = Throttle<Element, Scheduler>
    
    private let _parent: ParentType
    
    private let _lock = NSRecursiveLock()
    
    // state
    private var _id = 0 as UInt64
    private var _value: Element? = nil
    
    let cancellable = SerialDisposable()
    
    init(parent: ParentType, observer: O, cancel: Disposable) {
        _parent = parent
        
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Disposable {
        let subscription = _parent._source.subscribe(self)
        
        return CompositeDisposable(subscription, cancellable)
    }

    func on(event: Event<Element>) {
        switch event {
        case .Next:
            break
        case .Error, .Completed:
            cancellable.dispose()
        }
       
        let latestId = _lock.calculateLocked { () -> UInt64 in
            let observer = self.observer
            
            let oldValue = _value
            
            _id = _id &+ 1
            
            switch event {
            case .Next(let element):
                _value = element
            case .Error:
                _value = nil
                observer?.on(event)
                dispose()
            case .Completed:
                _value = nil
                if let value = oldValue {
                    observer?.on(.Next(value))
                }
                observer?.on(.Completed)
                dispose()
            }
            
            return _id
        }
        
        
        switch event {
        case .Next:
            let d = SingleAssignmentDisposable()
            self.cancellable.disposable = d
            
            let scheduler = _parent._scheduler
            let dueTime = _parent._dueTime
            
            let disposeTimer = scheduler.scheduleRelative(latestId, dueTime: dueTime) { (id) in
                self.propagate()
                return NopDisposable.instance
            }
            
            d.disposable = disposeTimer
        default: break
        }
    }
    
    func propagate() {
        let originalValue: Element? = _lock.calculateLocked {
            let originalValue = _value
            _value = nil
            return originalValue
        }
        
        if let value = originalValue {
            observer?.on(.Next(value))
        }
    }
}

class Throttle<Element, Scheduler: SchedulerType> : Producer<Element> {
    
    private let _source: Observable<Element>
    private let _dueTime: Scheduler.TimeInterval
    private let _scheduler: Scheduler
    
    init(source: Observable<Element>, dueTime: Scheduler.TimeInterval, scheduler: Scheduler) {
        _source = source
        _dueTime = dueTime
        _scheduler = scheduler
    }
    
    override func run<O: ObserverType where O.E == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = ThrottleSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
    
}