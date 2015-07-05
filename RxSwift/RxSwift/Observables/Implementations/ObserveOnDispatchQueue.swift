//
//  ObserveOnDispatchQueue.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 5/31/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class ObserveOnDispatchQueueSink<O: ObserverType> : ScheduledSerialSchedulerObserver<O> {
    var disposeLock = Lock()
    
    var cancel: Disposable
    
    init(scheduler: SerialDispatchQueueScheduler, observer: O, cancel: Disposable) {
        self.cancel = cancel
        super.init(scheduler: scheduler, observer: observer)
    }
   
    override func dispose() {
        super.dispose()
        
        let toDispose = disposeLock.calculateLocked { () -> Disposable in
            let originalCancel = self.cancel
            self.cancel = NopDisposable.instance
            return originalCancel
        }
        
        toDispose.dispose()
    }
}

#if TRACE_RESOURCES
public var numberOfDispatchQueueObservables: Int32 = 0
#endif
    
class ObserveOnDispatchQueue<E> : Producer<E> {
    let scheduler: SerialDispatchQueueScheduler
    let source: Observable<E>
    
    init(source: Observable<E>, scheduler: SerialDispatchQueueScheduler) {
        self.scheduler = scheduler
        self.source = source
        
#if TRACE_RESOURCES
        OSAtomicIncrement32(&numberOfDispatchQueueObservables)
#endif
    }
    
    override func run<O : ObserverType where O.Element == E>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = ObserveOnDispatchQueueSink(scheduler: scheduler, observer: observer, cancel: cancel)
        setSink(sink)
        return source.subscribeSafe(sink)
    }
    
#if TRACE_RESOURCES
    deinit {
        OSAtomicDecrement32(&numberOfDispatchQueueObservables)
    }
#endif
}