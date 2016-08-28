//
//  Delay.swift
//  RxSwift
//
//  Created by tarunon on 2016/02/09.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation

class DelaySink<ElementType, O: ObserverType>
    : Sink<O>
    , ObserverType where O.E == ElementType {
    typealias E = O.E
    typealias Source = Observable<E>
    typealias DisposeKey = Bag<Disposable>.KeyType
    
    // state
    private let _group = CompositeDisposable()
    private let _sourceSubscription = SingleAssignmentDisposable()
    
    private let _lock = NSRecursiveLock()
    
    private var _queue = Queue<(time: RxTime, event: Event<E>)>(capacity: 0)
    private var _running = false
    private var _disposed = false

    private let _dueTime: RxTimeInterval
    private let _scheduler: SchedulerType
    
    init(observer: O, dueTime: RxTimeInterval, scheduler: SchedulerType) {
        _dueTime = dueTime
        _scheduler = scheduler
        super.init(observer: observer)
    }
    
    func drainQueue(key: DisposeKey) -> Disposable {
        _lock.lock(); defer { _lock.unlock() } // lock {
            if !_queue.isEmpty {
                let (time, event) = _queue.peek()
                let timeInterval = _scheduler.now.timeIntervalSince(time)
                if timeInterval < _dueTime {
                    return _scheduler.scheduleRelative(key, dueTime: _dueTime - timeInterval, action: drainQueue)
                }
                _queue.dequeue()
                forwardOn(event)
                if event.isStopEvent {
                    dispose()
                } else {
                    return drainQueue(key: key)
                }
            }
            _running = false
            _grou(key)
            return NopDisposable.instance
        // }
    }
    
    func on(_ event: Event<E>) {
        _lock.lock(); defer { _lock.unlock() } // lock {
            switch event {
            case .error(_):
                forwardOn(event)
                dispose()
            default:
                _queue.enqueue((_scheduler.now, event))
                if !_running {
                    _running = true
                    let delayDisposable = SingleAssignmentDisposable()
                    if let key = _group.addDisposable(delayDisposable) {
                        delayDisposable.disposable = _scheduler.scheduleRelative(key, dueTime: _dueTime, action: drainQueue)
                    }
                }
            }
        // }
    }
    
    func run(source: Source) -> Disposable {
        _group.addDisposable(_sourceSubscription)
        _sourceSubscription.disposable = source.subscribe(self)
        
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
    
    override func run<O : ObserverType>(_ observer: O) -> Disposable where O.E == Element {
        let sink = DelaySink(observer: observer, dueTime: _dueTime, scheduler: _scheduler)
        sink.disposable = sink.run(source: _source)
        return sink
    }
}
