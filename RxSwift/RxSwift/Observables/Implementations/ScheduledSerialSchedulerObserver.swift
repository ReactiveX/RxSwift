//
//  ScheduledSerialSchedulerObserver.swift
//  Rx
//
//  Created by Krunoslav Zaher on 4/5/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class ScheduledSerialSchedulerObserver<O: ObserverType> : ObserverBase<O.Element> {
    let scheduler: SerialDispatchQueueScheduler
    let observer: O
    
    init(scheduler: SerialDispatchQueueScheduler, observer: O) {
        self.scheduler = scheduler
        self.observer = observer
        super.init()
    }

    override func onCore(event: Event<Element>) {
        self.scheduler.schedule(()) { (_) -> RxResult<Disposable> in
            send(self.observer, event)
            
            if event.isStopEvent {
                self.dispose()
            }
            
            return NopDisposableResult
        }
    }
}