
//  ObserveOn.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 7/25/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class ObserveOn<E> : Producer<E> {
    let scheduler: ImmediateScheduler
    let source: Observable<E>
    
    init(source: Observable<E>, scheduler: ImmediateScheduler) {
        self.scheduler = scheduler
        self.source = source
        
#if TRACE_RESOURCES
        OSAtomicIncrement32(&resourceCount)
#endif
    }
    
    override func run<O : ObserverType where O.E == E>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = ObserveOnSink(scheduler: scheduler, observer: observer, cancel: cancel)
        setSink(sink)
        return source.subscribeSafe(sink)
    }
    
#if TRACE_RESOURCES
    deinit {
        OSAtomicDecrement32(&resourceCount)
    }
#endif
}

enum ObserveOnState : Int32 {
    // pump is not running
    case Stopped = 0
    // pump is running
    case Running = 1
}

class ObserveOnSink<O: ObserverType> : ObserverBase<O.E> {
    typealias E = O.E
    
    var cancel: Disposable
    
    let scheduler: ImmediateScheduler
    var observer: O?
    
    var state = ObserveOnState.Stopped
    
    var queue = Queue<Event<E>>(capacity: 10)
    let scheduleDisposable = SerialDisposable()
    
    init(scheduler: ImmediateScheduler, observer: O, cancel: Disposable) {
        self.cancel = cancel
        self.scheduler = scheduler
        self.observer = observer
    }

    override func onCore(event: Event<E>) {
        let shouldStart = lock.calculateLocked { () -> Bool in
            self.queue.enqueue(event)
            
            switch self.state {
            case .Stopped:
                self.state = .Running
                return true
            case .Running:
                return false
            }
        }
        
        if shouldStart {
            scheduleDisposable.disposable = self.scheduler.scheduleRecursively((), action: self.run)
        }
    }
    
    func run(state: Void, recurse: Void -> Void) {
        let (nextEvent, observer) = self.lock.calculateLocked { () -> (Event<E>?, O?) in
            if self.queue.count > 0 {
                return (self.queue.dequeue(), self.observer)
            }
            else {
                self.state = .Stopped
                return (nil, self.observer)
            }
        }
        
        if let nextEvent = nextEvent {
            observer?.on(nextEvent)
            if nextEvent.isStopEvent {
                self.dispose()
            }
        }
        else {
            return
        }
        
        let shouldContinue = self.lock.calculateLocked { () -> Bool in
            if self.queue.count > 0 {
                return true
            }
            else {
                self.state = .Stopped
                return false
            }
        }
        
        if shouldContinue {
            recurse()
        }
    }
    
    override func dispose() {
        super.dispose()
        
        let toDispose = lock.calculateLocked { () -> Disposable in
            let originalCancel = self.cancel
            self.cancel = NopDisposable.instance
            self.scheduleDisposable.dispose()
            self.observer = nil
            return originalCancel
        }
        
        toDispose.dispose()
    }
}