//
//  SubscribeOn.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/14/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class SubscribeOnSink<O: ObserverType> : Sink<O>, ObserverType {
    typealias Element = O.E
    typealias Parent = SubscribeOn<Element>
    
    let parent: Parent
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<Element>) {
        observer?.on(event)
        
        if event.isStopEvent {
            self.dispose()
        }
    }
    
    func run() -> Disposable {
        let disposeEverything = SerialDisposable()
        let cancelSchedule = SingleAssignmentDisposable()
        
        disposeEverything.disposable = cancelSchedule
        
        cancelSchedule.disposable = parent.scheduler.schedule(()) { (_) -> Disposable in
            let subscription = self.parent.source.subscribeSafe(self)
            disposeEverything.disposable = ScheduledDisposable(scheduler: self.parent.scheduler, disposable: subscription)
            return NopDisposable.instance
        }
    
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
    
    override func run<O : ObserverType where O.E == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = SubscribeOnSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
}