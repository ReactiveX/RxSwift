//
//  DelaySubscription.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/14/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class DelaySubscriptionSink<ElementType, O: ObserverType, S: Scheduler where O.E == ElementType> : Sink<O>, ObserverType {
    typealias Parent = DelaySubscription<ElementType, S>
    typealias E = O.E
    
    let parent: Parent
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<E>) {
        observer?.on(event)
        if event.isStopEvent {
            self.dispose()
        }
    }
    
}

class DelaySubscription<Element, S: Scheduler>: Producer<Element> {
    typealias TimeInterval = S.TimeInterval
    
    let source: Observable<Element>
    let dueTime: TimeInterval
    let scheduler: S
    
    init(source: Observable<Element>, dueTime: TimeInterval, scheduler: S) {
        self.source = source
        self.dueTime = dueTime
        self.scheduler = scheduler
    }
    
    override func run<O : ObserverType where O.E == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = DelaySubscriptionSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return scheduler.scheduleRelative((), dueTime: dueTime) { _ in
            return self.source.subscribeSafe(sink)
        }
    }
}