//
//  Switch.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/12/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class SwitchSink<S: ObservableConvertibleType, O: ObserverType where S.E == O.E>
    : Sink<O>
    , ObserverType
    , LockOwnerType
    , SynchronizedOnType {
    typealias E = S
    typealias Parent = Switch<S>

    private let _subscriptions: SingleAssignmentDisposable = SingleAssignmentDisposable()
    private let _innerSubscription: SerialDisposable = SerialDisposable()
    private let _parent: Parent
    
    let _lock = NSRecursiveLock()
    
    // state
    private var _stopped = false
    private var _latest = 0
    private var _hasLatest = false
    
    init(parent: Parent, observer: O) {
        _parent = parent
        
        super.init(observer: observer)
    }
    
    func run() -> Disposable {
        let subscription = _parent._sources.subscribe(self)
        _subscriptions.disposable = subscription
        return StableCompositeDisposable.create(_subscriptions, _innerSubscription)
    }
    
    func on(event: Event<E>) {
        synchronizedOn(event)
    }

    func _synchronized_on(event: Event<E>) {
        switch event {
        case .Next(let observable):
            _hasLatest = true
            _latest = _latest &+ 1
            let latest = _latest

            let d = SingleAssignmentDisposable()
            _innerSubscription.disposable = d
               
            let observer = SwitchSinkIter(parent: self, id: latest, _self: d)
            let disposable = observable.asObservable().subscribe(observer)
            d.disposable = disposable
        case .Error(let error):
            forwardOn(.Error(error))
            dispose()
        case .Completed:
            _stopped = true
            
            _subscriptions.dispose()
            
            if !_hasLatest {
                forwardOn(.Completed)
                dispose()
            }
        }
    }
}

class SwitchSinkIter<S: ObservableConvertibleType, O: ObserverType where S.E == O.E>
    : ObserverType
    , LockOwnerType
    , SynchronizedOnType {
    typealias E = O.E
    typealias Parent = SwitchSink<S, O>
    
    private let _parent: Parent
    private let _id: Int
    private let _self: Disposable

    var _lock: NSRecursiveLock {
        return _parent._lock
    }

    init(parent: Parent, id: Int, _self: Disposable) {
        _parent = parent
        _id = id
        self._self = _self
    }
    
    func on(event: Event<E>) {
        synchronizedOn(event)
    }

    func _synchronized_on(event: Event<E>) {
        switch event {
        case .Next: break
        case .Error, .Completed:
            _self.dispose()
        }
        
        if _parent._latest != _id {
            return
        }
       
        switch event {
        case .Next:
            _parent.forwardOn(event)
        case .Error:
            _parent.forwardOn(event)
            _parent.dispose()
        case .Completed:
            _parent._hasLatest = false
            if _parent._stopped {
                _parent.forwardOn(event)
                _parent.dispose()
            }
        }
    }
}

class Switch<S: ObservableConvertibleType> : Producer<S.E> {
    private let _sources: Observable<S>
    
    init(sources: Observable<S>) {
        _sources = sources
    }
    
    override func run<O : ObserverType where O.E == S.E>(observer: O) -> Disposable {
        let sink = SwitchSink(parent: self, observer: observer)
        sink.disposable = sink.run()
        return sink
    }
}