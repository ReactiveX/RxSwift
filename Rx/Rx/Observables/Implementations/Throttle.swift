//
//  Throttle.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/22/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Throttle_<Element, SchedulerType: Scheduler> : Sink<Element>, ObserverClassType {
    typealias ParentType = Throttle<Element, SchedulerType>
    typealias ThrottleState = (
        value: Element?,
        cancellable: SerialDisposable,
        id: UInt64
    )
    
    let parent: ParentType
    
    var lock = Lock()
    var throttleState: ThrottleState = (
        value: nil,
        cancellable: SerialDisposable(),
        id: 0
    )
    
    init(parent: ParentType, observer: ObserverOf<Element>, cancel: Disposable) {
        self.parent = parent
        
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Result<Disposable> {
        let cancellable = self.throttleState.cancellable
        return parent.source.subscribeSafe(ObserverOf(self)) >== { subscription in
            return success(CompositeDisposable(subscription, cancellable))
        }
    }
    
    func on(event: Event<Element>) -> Result<Void> {
        switch event {
        case .Next:
            break
        case .Error: fallthrough
        case .Completed:
            throttleState.cancellable.dispose()
            break
        }
        
       
        var (latestId: UInt64, observer: ObserverOf<Element>, oldValue: Element?) = self.lock.calculateLocked {
            let observer = self.observer
            
            var oldValue = self.throttleState.value
            
            switch event {
            case .Next(let boxedValue):
                self.throttleState.value = boxedValue.value
            case .Error(let error):
                self.dispose()
                self.throttleState.value = nil
            case .Completed:
                self.dispose()
                self.throttleState.value = nil
            }
            
            self.throttleState.id = self.throttleState.id + 1
            return (self.throttleState.id, observer, oldValue)
        }
        
        
        switch event {
        case .Next(let boxedValue):
            let d = SingleAssignmentDisposable()
            self.throttleState.cancellable.setDisposable(d)
            
            let scheduler = self.parent.scheduler
            let dueTime = self.parent.dueTime
            
            return scheduler.schedule(latestId, dueTime: dueTime, action: { (id) in
                return self.propagate()
            }) >== { disposeTimer in
                d.setDisposable(disposeTimer)
                return SuccessResult
            }
        case .Error(let error):
            return observer.on(.Error(error))
        case .Completed:
            var sendResult: Result<Void>
            if let oldValue = oldValue {
                sendResult = observer.on(.Next(Box(oldValue)))
            }
            else {
                sendResult = SuccessResult
            }
            return sendResult >>> {
                return observer.on(.Completed)
            }
        }
    }
    
    func propagate() -> Result<Void> {
        var originalValue: Element? = self.lock.calculateLocked {
            var originalValue = self.throttleState.value
            self.throttleState.value = nil
            return originalValue
        }
        
        if let value = originalValue {
            return self.observer.on(.Next(Box(value)))
        }
        else {
            return SuccessResult
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
    
    override func run(observer: ObserverOf<Element>, cancel: Disposable, setSink: (Disposable) -> Void) -> Result<Disposable> {
        let sink = Throttle_(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
    
}