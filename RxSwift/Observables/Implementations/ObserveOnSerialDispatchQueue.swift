//
//  ObserveOnSerialDispatchQueue.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 5/31/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

#if TRACE_RESOURCES
/**
Counts number of `SerialDispatchQueueObservables`.

Purposed for unit tests.
*/
public var numberOfSerialDispatchQueueObservables: AtomicInt = 0
#endif

class ObserveOnSerialDispatchQueueSink<O: ObserverType> : ObserverBase<O.E> {
    let scheduler: SerialDispatchQueueScheduler
    let observer: O
    
    let subscription = SingleAssignmentDisposable()

    var cachedScheduleLambda: ((ObserveOnSerialDispatchQueueSink<O>, Event<E>) -> Disposable)!

    init(scheduler: SerialDispatchQueueScheduler, observer: O) {
        self.scheduler = scheduler
        self.observer = observer
        super.init()

        cachedScheduleLambda = { sink, event in
            sink.observer.on(event)

            if event.isStopEvent {
                sink.dispose()
            }

            return NopDisposable.instance
        }
    }

    override func onCore(event: Event<E>) {
        self.scheduler.schedule((self, event), action: cachedScheduleLambda)
    }
   
    override func dispose() {
        super.dispose()

        subscription.dispose()
    }
}
    
class ObserveOnSerialDispatchQueue<E> : Producer<E> {
    let scheduler: SerialDispatchQueueScheduler
    let source: Observable<E>
    
    init(source: Observable<E>, scheduler: SerialDispatchQueueScheduler) {
        self.scheduler = scheduler
        self.source = source
        
#if TRACE_RESOURCES
        AtomicIncrement(&resourceCount)
        AtomicIncrement(&numberOfSerialDispatchQueueObservables)
#endif
    }
    
    override func run<O : ObserverType where O.E == E>(observer: O) -> Disposable {
        let sink = ObserveOnSerialDispatchQueueSink(scheduler: scheduler, observer: observer)
        sink.subscription.disposable = source.subscribe(sink)
        return sink
    }
    
#if TRACE_RESOURCES
    deinit {
        AtomicDecrement(&resourceCount)
        AtomicDecrement(&numberOfSerialDispatchQueueObservables)
    }
#endif
}