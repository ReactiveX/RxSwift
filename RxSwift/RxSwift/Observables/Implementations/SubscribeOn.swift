//
//  SubscribeOn.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/14/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class SubscribeOnSink<O: ObserverType> : Sink<O>, ObserverType {
    typealias Element = O.Element
    typealias Parent = SubscribeOn<Element>
    
    let parent: Parent
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<Element>) {
        trySend(observer, event)
        
        if event.isStopEvent {
            self.dispose()
        }
    }
    
    func run() -> Disposable {
        let disposeEverything = SerialDisposable()
        let cancelSchedule = SingleAssignmentDisposable()
        
        disposeEverything.setDisposable(cancelSchedule)
        
        let scheduleResult = parent.scheduler.schedule(()) { (_) -> RxResult<Disposable> in
            let subscription = self.parent.source.subscribeSafe(self)
            disposeEverything.setDisposable(ScheduledDisposable(scheduler: self.parent.scheduler, disposable: subscription))
            return NopDisposableResult
        }
    
        cancelSchedule.disposable = getScheduledDisposable(scheduleResult)
    
        return disposeEverything
    }
}

class SubscribeOn<Element> : Producer<Element> {
    let source: Observable<Element>
    let scheduler: ImmediateScheduler
    
    init(source: Observable<Element>, scheduler: ImmediateScheduler) {
        self.source = source
        self.scheduler = scheduler
    }
    
    override func run<O : ObserverType where O.Element == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = SubscribeOnSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
}