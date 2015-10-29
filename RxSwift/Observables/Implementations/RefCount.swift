//
//  RefCount.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/5/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class RefCountSink<CO: ConnectableObservableType, O: ObserverType where CO.E == O.E> : Sink<O>, ObserverType {
    typealias Element = O.E
    typealias Parent = RefCount<CO>
    
    private let _parent: Parent
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        _parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Disposable {
        let subscription = _parent._source.subscribeSafe(self)
        
        _parent._lock.performLocked {
            if _parent._count == 0 {
                _parent._count = 1
                _parent._connectableSubscription = _parent._source.connect()
            }
            else {
                _parent._count = _parent._count + 1
            }
        }
        
        return AnonymousDisposable {
            subscription.dispose()
            self._parent._lock.performLocked {
                if self._parent._count == 1 {
                    self._parent._connectableSubscription!.dispose()
                    self._parent._count = 0
                    self._parent._connectableSubscription = nil
                }
                else if self._parent._count > 1 {
                    self._parent._count = self._parent._count - 1
                }
                else {
                    rxFatalError("Something went wrong with RefCount disposing mechanism")
                }
            }
        }
    }

    func on(event: Event<Element>) {
        switch event {
        case .Next:
            observer?.on(event)
        case .Error, .Completed:
            observer?.on(event)
            dispose()
        }
    }
}

class RefCount<CO: ConnectableObservableType>: Producer<CO.E> {
    private let _lock = NSRecursiveLock()
    
    // state
    private var _count = 0
    private var _connectableSubscription = nil as Disposable?
    
    private let _source: CO
    
    init(source: CO) {
        _source = source
    }
    
    override func run<O: ObserverType where O.E == CO.E>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = RefCountSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
}