//
//  Throttle.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/22/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Throttle_<O: ObserverType, SchedulerType: Scheduler> : Sink<O>, ObserverType {
    typealias Element = O.Element
    typealias ParentType = Throttle<Element, SchedulerType>
    
    typealias ThrottleState = (
        value: RxMutableBox<Element?>,
        cancellable: SerialDisposable,
        id: UInt64
    )
    
    let parent: ParentType
    
    var lock = NSRecursiveLock()
    var throttleState: ThrottleState = (
        value: RxMutableBox(nil),
        cancellable: SerialDisposable(),
        id: 0
    )
    
    init(parent: ParentType, observer: O, cancel: Disposable) {
        self.parent = parent
        
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Disposable {
        let cancellable = self.throttleState.cancellable
        let subscription = parent.source.subscribeSafe(self)
        
        return CompositeDisposable(subscription, cancellable)
    }

    func on(event: Event<Element>) {
        switch event {
        case .Next:
            break
        case .Error: fallthrough
        case .Completed:
            throttleState.cancellable.dispose()
            break
        }
       
        var latestId = self.lock.calculateLocked { () -> UInt64 in
            let observer = self.observer
            
            var oldValue = self.throttleState.value.value
            
            self.throttleState.id = self.throttleState.id &+ 1
            
            switch event {
            case .Next(let boxedValue):
                self.throttleState.value.value = boxedValue.value
            case .Error(let error):
                self.throttleState.value.value = nil
                trySend(observer, event)
                self.dispose()
            case .Completed:
                self.throttleState.value.value = nil
                if let value = oldValue {
                    trySendNext(observer, value)
                }
                trySendCompleted(observer)
                self.dispose()
            }
            
            return self.throttleState.id
        }
        
        
        switch event {
        case .Next(let boxedValue):
            let d = SingleAssignmentDisposable()
            self.throttleState.cancellable.disposable = d
            
            let scheduler = self.parent.scheduler
            let dueTime = self.parent.dueTime
            
            let _  = scheduler.scheduleRelative(latestId, dueTime: dueTime) { (id) in
                self.propagate()
                return NopDisposableResult
            }.map { disposeTimer -> Disposable in
                d.disposable = disposeTimer
                return disposeTimer
            }.recoverWith { e -> RxResult<Disposable> in
                self.lock.performLocked {
                    trySendError(observer, e)
                    self.dispose()
                }
                return NopDisposableResult
            }
        default: break
        }
    }
    
    func propagate() {
        var originalValue: Element? = self.lock.calculateLocked {
            var originalValue = self.throttleState.value.value
            self.throttleState.value.value = nil
            return originalValue
        }
        
        if let value = originalValue {
            trySendNext(observer, value)
        }
    }
}

class Throttle<Element, SchedulerType: Scheduler> : Producer<Element> {
    
    let source: Observable<Element>
    let dueTime: SchedulerType.TimeInterval
    let scheduler: SchedulerType
    
    init(source: Observable<Element>, dueTime: SchedulerType.TimeInterval, scheduler: SchedulerType) {
        self.source = source
        self.dueTime = dueTime
        self.scheduler = scheduler
    }
    
    override func run<O: ObserverType where O.Element == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = Throttle_(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
    
}