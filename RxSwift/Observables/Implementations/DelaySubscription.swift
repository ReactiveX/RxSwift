//
//  DelaySubscription.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/14/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class DelaySubscriptionSink<ElementType, O: ObserverType, S: SchedulerType where O.E == ElementType> : Sink<O>, ObserverType {
    typealias Parent = DelaySubscription<ElementType, S>
    typealias E = O.E
    
    private let _parent: Parent
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        _parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<E>) {
        observer?.on(event)
        if event.isStopEvent {
            dispose()
        }
    }
    
}

class DelaySubscription<Element, S: SchedulerType>: Producer<Element> {
    typealias TimeInterval = S.TimeInterval
    
    private let _source: Observable<Element>
    private let _dueTime: TimeInterval
    private let _scheduler: S
    
    init(source: Observable<Element>, dueTime: TimeInterval, scheduler: S) {
        _source = source
        _dueTime = dueTime
        _scheduler = scheduler
    }
    
    override func run<O : ObserverType where O.E == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = DelaySubscriptionSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return _scheduler.scheduleRelative((), dueTime: _dueTime) { _ in
            return self._source.subscribe(sink)
        }
    }
}