//
//  Switch.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/12/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class SwitchSink<S: ObservableConvertibleType, O: ObserverType where S.E == O.E> : Sink<O>, ObserverType {
    typealias E = S
    typealias Parent = Switch<S>

    private let _subscriptions: SingleAssignmentDisposable = SingleAssignmentDisposable()
    private let _innerSubscription: SerialDisposable = SerialDisposable()
    private let _parent: Parent
    
    private let _lock = NSRecursiveLock()
    
    // state
    private var _stopped = false
    private var _latest = 0
    private var _hasLatest = false
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        _parent = parent
        
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Disposable {
        let subscription = _parent._sources.subscribeSafe(self)
        _subscriptions.disposable = subscription
        return CompositeDisposable(_subscriptions, _innerSubscription)
    }
    
    func on(event: Event<E>) {
        switch event {
        case .Next(let observable):
            let latest: Int = _lock.calculateLocked {
                _hasLatest = true
                _latest = _latest &+ 1
                return _latest
            }
            
            let d = SingleAssignmentDisposable()
            _innerSubscription.disposable = d
               
            let observer = SwitchSinkIter(parent: self, id: latest, _self: d)
            let disposable = observable.asObservable().subscribeSafe(observer)
            d.disposable = disposable
        case .Error(let error):
            _lock.performLocked {
                observer?.on(.Error(error))
                dispose()
            }
        case .Completed:
            _lock.performLocked {
                _stopped = true
                
                _subscriptions.dispose()
                
                if !_hasLatest {
                    observer?.on(.Completed)
                    dispose()
                }
            }
        }
    }
}

class SwitchSinkIter<S: ObservableConvertibleType, O: ObserverType where S.E == O.E> : ObserverType {
    typealias E = O.E
    typealias Parent = SwitchSink<S, O>
    
    private let _parent: Parent
    private let _id: Int
    private let _self: Disposable
    
    init(parent: Parent, id: Int, _self: Disposable) {
        _parent = parent
        _id = id
        self._self = _self
    }
    
    func on(event: Event<E>) {
        return _parent._lock.calculateLocked {
            
            switch event {
            case .Next: break
            case .Error, .Completed:
                _self.dispose()
            }
            
            if _parent._latest != _id {
                return
            }
           
            let observer = _parent.observer
            
            switch event {
            case .Next:
                observer?.on(event)
            case .Error:
                observer?.on(event)
                _parent.dispose()
            case .Completed:
                _parent._hasLatest = false
                if _parent._stopped {
                    observer?.on(event)
                    _parent.dispose()
                }
            }
        }
    }
}

class Switch<S: ObservableConvertibleType> : Producer<S.E> {
    private let _sources: Observable<S>
    
    init(sources: Observable<S>) {
        _sources = sources
    }
    
    override func run<O : ObserverType where O.E == S.E>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = SwitchSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
}