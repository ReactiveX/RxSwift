//
//  ObserveOnSerialDispatchQueue.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 5/31/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class ObserveOnSerialDispatchQueueSink<O: ObserverType> : ObserverBase<O.E> {
    
    let scheduler: SerialDispatchQueueScheduler
    let observer: O
    
    var disposeLock = SpinLock()
    
    var cancel: Disposable
    
    init(scheduler: SerialDispatchQueueScheduler, observer: O, cancel: Disposable) {
        self.cancel = cancel
        self.scheduler = scheduler
        self.observer = observer
        super.init()
    }

    override func onCore(event: Event<E>) {
        self.scheduler.schedule(()) { (_) -> Disposable in
            send(self.observer, event)
            
            if event.isStopEvent {
                self.dispose()
            }
            
            return NopDisposable.instance
        }
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
    
class ObserveOnSerialDispatchQueue<E> : Producer<E> {
    let scheduler: SerialDispatchQueueScheduler
    let source: Observable<E>
    
    init(source: Observable<E>, scheduler: SerialDispatchQueueScheduler) {
        self.scheduler = scheduler
        self.source = source
        
#if TRACE_RESOURCES
        OSAtomicIncrement32(&resourceCount)
        OSAtomicIncrement32(&numberOfSerialDispatchQueueObservables)
#endif
    }
    
    override func run<O : ObserverType where O.E == E>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = ObserveOnSerialDispatchQueueSink(scheduler: scheduler, observer: observer, cancel: cancel)
        setSink(sink)
        return source.subscribeSafe(sink)
    }
    
#if TRACE_RESOURCES
    deinit {
        OSAtomicDecrement32(&resourceCount)
        OSAtomicDecrement32(&numberOfSerialDispatchQueueObservables)
    }
#endif
}