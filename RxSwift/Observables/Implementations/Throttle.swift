//
//  Throttle.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/22/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class ThrottleSink<O: ObserverType, Scheduler: SchedulerType>
    : Sink<O>
    , ObserverType
    , LockOwnerType
    , SynchronizedOnType {
    typealias Element = O.E
    typealias ParentType = Throttle<Element, Scheduler>
    
    private let _parent: ParentType
    
    let _lock = NSRecursiveLock()
    
    // state
    private var _id = 0 as UInt64
    private var _value: Element? = nil
    
    let cancellable = SerialDisposable()
    
    init(parent: ParentType, observer: O) {
        _parent = parent
        
        super.init(observer: observer)
    }
    
    func run() -> Disposable {
        let subscription = _parent._source.subscribe(self)
        
        return StableCompositeDisposable.create(subscription, cancellable)
    }

    func on(event: Event<Element>) {
        synchronizedOn(event)
    }

    func _synchronized_on(event: Event<Element>) {
        switch event {
        case .Next(let element):
            _id = _id &+ 1
            let currentId = _id
            _value = element

            
            let scheduler = _parent._scheduler
            let dueTime = _parent._dueTime

            let d = SingleAssignmentDisposable()
            self.cancellable.disposable = d
            d.disposable = scheduler.scheduleRelative(currentId, dueTime: dueTime, action: self.propagate)
        case .Error:
            _value = nil
            forwardOn(event)
            dispose()
        case .Completed:
            if let value = _value {
                _value = nil
                forwardOn(.Next(value))
            }
            forwardOn(.Completed)
            dispose()
        }
    }
    
    func propagate(currentId: UInt64) -> Disposable {
        _lock.lock(); defer { _lock.unlock() } // {
            let originalValue = _value

            if let value = originalValue where _id == currentId {
                _value = nil
                forwardOn(.Next(value))
            }
        // }
        return NopDisposable.instance
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
    
    override func run<O: ObserverType where O.E == Element>(observer: O) -> Disposable {
        let sink = ThrottleSink(parent: self, observer: observer)
        sink.disposable = sink.run()
        return sink
    }
    
}