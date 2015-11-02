//
//  Merge.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// sequential

class MergeSinkIter<S: ObservableConvertibleType, O: ObserverType where O.E == S.E>
    : ObserverType
    , LockOwnerType
    , SynchronizedOnType {
    typealias E = O.E
    typealias DisposeKey = Bag<Disposable>.KeyType
    typealias Parent = MergeSink<S, O>
    
    private let _parent: Parent
    private let _disposeKey: DisposeKey

    var _lock: NSRecursiveLock {
        return _parent._lock
    }

    init(parent: Parent, disposeKey: DisposeKey) {
        _parent = parent
        _disposeKey = disposeKey
    }
    
    func on(event: Event<E>) {
        synchronizedOn(event)
    }

    func _synchronized_on(event: Event<E>) {
        switch event {
        case .Next:
            _parent.forwardOn(event)
        case .Error:
            _parent.forwardOn(event)
            _parent.dispose()
        case .Completed:
            _parent._group.removeDisposable(_disposeKey)
            
            if _parent._stopped && _parent._group.count == 1 {
                _parent.forwardOn(.Completed)
                _parent.dispose()
            }
        }
    }
}

class MergeSink<S: ObservableConvertibleType, O: ObserverType where O.E == S.E>
    : Sink<O>
    , ObserverType
    , LockOwnerType
    , SynchronizedOnType {
    typealias E = S
    typealias Parent = Merge<S>
    
    private let _parent: Parent
    
    let _lock = NSRecursiveLock()
    
    // state
    private var _stopped = false
    
    private let _group = CompositeDisposable()
    private let _sourceSubscription = SingleAssignmentDisposable()
    
    init(parent: Parent, observer: O) {
        _parent = parent
        
        super.init(observer: observer)
    }
    
    func run() -> Disposable {
        _group.addDisposable(_sourceSubscription)
        
        let disposable = _parent._sources.subscribe(self)
        _sourceSubscription.disposable = disposable

        return _group
    }
    
    func on(event: Event<E>) {
        if case .Next(let value) = event {
            let innerSubscription = SingleAssignmentDisposable()
            let maybeKey = _group.addDisposable(innerSubscription)
            
            if let key = maybeKey {
                let observer = MergeSinkIter(parent: self, disposeKey: key)
                let disposable = value.asObservable().subscribe(observer)
                innerSubscription.disposable = disposable
            }

            return
        }

        synchronizedOn(event)
    }

    func _synchronized_on(event: Event<E>) {
        switch event {
        case .Next:
            rxFatalError("Next should have been handled")
        case .Error(let error):
            forwardOn(.Error(error))
            dispose()
        case .Completed:
            _stopped = true
            
            if _group.count == 1 {
                forwardOn(.Completed)
                dispose()
            }
            else {
                _sourceSubscription.dispose()
            }
        }
    }
}

// concurrent

class MergeConcurrentSinkIter<S: ObservableConvertibleType, O: ObserverType where S.E == O.E>
    : ObserverType
    , LockOwnerType
    , SynchronizedOnType {
    typealias E = O.E
    typealias DisposeKey = Bag<Disposable>.KeyType
    typealias Parent = MergeConcurrentSink<S, O>
    
    private let _parent: Parent
    private let _disposeKey: DisposeKey

    var _lock: NSRecursiveLock {
        return _parent._lock
    }
    
    init(parent: Parent, disposeKey: DisposeKey) {
        _parent = parent
        _disposeKey = disposeKey
    }
    
    func on(event: Event<E>) {
        synchronizedOn(event)
    }

    func _synchronized_on(event: Event<E>) {
        switch event {
        case .Next:
            _parent.forwardOn(event)
        case .Error:
            _parent.forwardOn(event)
            _parent.dispose()
        case .Completed:
            _parent._group.removeDisposable(_disposeKey)
            let queue = _parent._queue
            if queue.value.count > 0 {
                let s = queue.value.dequeue()
                _parent.subscribe(s, group: _parent._group)
            }
            else {
                _parent._activeCount = _parent._activeCount - 1
                
                if _parent._stopped && _parent._activeCount == 0 {
                    _parent.forwardOn(.Completed)
                    _parent.dispose()
                }
            }
        }
    }
}

class MergeConcurrentSink<S: ObservableConvertibleType, O: ObserverType where S.E == O.E>
    : Sink<O>
    , ObserverType
    , LockOwnerType
    , SynchronizedOnType {
    typealias E = S
    typealias Parent = Merge<S>
    typealias QueueType = Queue<S>
    
    private let _parent: Parent
    
    let _lock = NSRecursiveLock()

    // state
    private var _stopped = false
    private var _activeCount = 0
    private var _queue = RxMutableBox(QueueType(capacity: 2))
    
    private let _sourceSubscription = SingleAssignmentDisposable()
    private let _group = CompositeDisposable()
    
    init(parent: Parent, observer: O) {
        _parent = parent
        
        _group.addDisposable(_sourceSubscription)
        super.init(observer: observer)
    }
    
    func run() -> Disposable {
        _group.addDisposable(_sourceSubscription)
        
        let disposable = _parent._sources.subscribe(self)
        _sourceSubscription.disposable = disposable
        return _group
    }
    
    func subscribe(innerSource: E, group: CompositeDisposable) {
        let subscription = SingleAssignmentDisposable()
        
        let key = group.addDisposable(subscription)
        
        if let key = key {
            let observer = MergeConcurrentSinkIter(parent: self, disposeKey: key)
            
            let disposable = innerSource.asObservable().subscribe(observer)
            subscription.disposable = disposable
        }
    }
    
    func on(event: Event<E>) {
        synchronizedOn(event)
    }

    func _synchronized_on(event: Event<E>) {
        switch event {
        case .Next(let value):
            let subscribe: Bool
            if _activeCount < _parent._maxConcurrent {
                _activeCount += 1
                subscribe = true
            }
            else {
                _queue.value.enqueue(value)
                subscribe = false
            }

            if subscribe {
                self.subscribe(value, group: _group)
            }
        case .Error(let error):
            forwardOn(.Error(error))
            dispose()
        case .Completed:
            if _activeCount == 0 {
                forwardOn(.Completed)
                dispose()
            }
            else {
                _sourceSubscription.dispose()
            }
                
            _stopped = true
        }
    }
}

class Merge<S: ObservableConvertibleType> : Producer<S.E> {
    private let _sources: Observable<S>
    private let _maxConcurrent: Int
    
    init(sources: Observable<S>, maxConcurrent: Int) {
        _sources = sources
        _maxConcurrent = maxConcurrent
    }
    
    override func run<O: ObserverType where O.E == S.E>(observer: O) -> Disposable {
        if _maxConcurrent > 0 {
            let sink = MergeConcurrentSink(parent: self, observer: observer)
            sink.disposable = sink.run()
            return sink
        }
        else {
            let sink = MergeSink(parent: self, observer: observer)
            sink.disposable = sink.run()
            return sink
        }
    }
}