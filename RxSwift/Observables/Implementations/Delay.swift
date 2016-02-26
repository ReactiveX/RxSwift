//
//  Delay.swift
//  Rx
//
//  Created by tarunon on 2016/02/09.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation

class DelaySink<ElementType, O: ObserverType where O.E == ElementType>
    : Sink<O>
, ObserverType {
    typealias Source = Observable<ElementType>
    typealias E = O.E
    
    // state
    private let _group = CompositeDisposable()
    private let _sourceSubscription = SingleAssignmentDisposable()
    
    private let _lock = NSRecursiveLock()

    private let _dueTime: RxTimeInterval
    private let _scheduler: SchedulerType
    
    init(observer: O, dueTime: RxTimeInterval, scheduler: SchedulerType) {
        _dueTime = dueTime
        _scheduler = scheduler
        super.init(observer: observer)
    }
    
    func on(event: Event<E>) {
        switch event {
        case .Error(_):
            _lock.lock(); defer { _lock.unlock() } // lock {
                forwardOn(event)
                dispose()
            // }
        default:
            let delayDisposable = SingleAssignmentDisposable()
            if let _ = _group.addDisposable(delayDisposable) {
                delayDisposable.disposable = _scheduler.scheduleRecursive((), dueTime: _dueTime) { _ in
                    self.forwardOn(event)
                    if event.isStopEvent {
                        self.dispose()
                    }
                    delayDisposable.dispose()
                }
            }
        }
    }
    
    func run(source: Source) -> Disposable {
        _group.addDisposable(_sourceSubscription)
        
        let subscription = source.subscribe(self)
        _sourceSubscription.disposable = subscription
        
        return _group
    }
}

class Delay<Element>: Producer<Element> {
    private let _source: Observable<Element>
    private let _dueTime: RxTimeInterval
    private let _scheduler: SchedulerType
    
    init(source: Observable<Element>, dueTime: RxTimeInterval, scheduler: SchedulerType) {
        _source = source
        _dueTime = dueTime
        _scheduler = scheduler
    }
    
    override func run<O : ObserverType where O.E == Element>(observer: O) -> Disposable {
        let sink = DelaySink(observer: observer, dueTime: _dueTime, scheduler: _scheduler)
        sink.disposable = sink.run(_source)
        return sink
    }
}