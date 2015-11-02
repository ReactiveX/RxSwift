//
//  FlatMap.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/11/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// It's value is one because initial source subscription is always in CompositeDisposable
let FlatMapNoIterators = 1

class FlatMapSinkIter<SourceType, S: ObservableConvertibleType, O: ObserverType where O.E == S.E> : ObserverType {
    typealias Parent = FlatMapSink<SourceType, S, O>
    typealias DisposeKey = CompositeDisposable.DisposeKey
    typealias E = O.E
    
    private let _parent: Parent
    private let _disposeKey: DisposeKey
    
    init(parent: Parent, disposeKey: DisposeKey) {
        _parent = parent
        _disposeKey = disposeKey
    }
    
    func on(event: Event<E>) {
        switch event {
        case .Next(let value):
            _parent._lock.lock(); defer { _parent._lock.unlock() } // lock {
                _parent.forwardOn(.Next(value))
            // }
        case .Error(let error):
            _parent._lock.lock(); defer { _parent._lock.unlock() } // lock {
                _parent.forwardOn(.Error(error))
                _parent.dispose()
            // }
        case .Completed:
            _parent._group.removeDisposable(_disposeKey)
            // If this has returned true that means that `Completed` should be sent.
            // In case there is a race who will sent first completed,
            // lock will sort it out. When first Completed message is sent
            // it will set observer to nil, and thus prevent further complete messages
            // to be sent, and thus preserving the sequence grammar.
            if _parent._stopped && _parent._group.count == FlatMapNoIterators {
                _parent._lock.lock(); defer { _parent._lock.unlock() } // lock {
                    _parent.forwardOn(.Completed)
                    _parent.dispose()
                // }
            }
        }
    }
}

class FlatMapSink<SourceType, S: ObservableConvertibleType, O: ObserverType where O.E == S.E> : Sink<O>, ObserverType {
    typealias ResultType = O.E
    typealias Element = SourceType
    typealias Parent = FlatMap<SourceType, S>
    
    private let _parent: Parent

    private let _lock = NSRecursiveLock()
    
    // state
    private let _group = CompositeDisposable()
    private let _sourceSubscription = SingleAssignmentDisposable()

    private var _stopped = false
    
    init(parent: Parent, observer: O) {
        _parent = parent
        super.init(observer: observer)
    }
    
    func performMap(element: SourceType) throws -> S {
        abstractMethod()
    }
    
    func on(event: Event<SourceType>) {
        switch event {
        case .Next(let element):
            do {
                let value = try performMap(element)
                subscribeInner(value.asObservable())
            }
            catch let e {
                forwardOn(.Error(e))
                dispose()
            }
        case .Error(let error):
            _lock.lock(); defer { _lock.unlock() } // lock {
                forwardOn(.Error(error))
                dispose()
            // }
        case .Completed:
            _lock.lock(); defer { _lock.unlock() } // lock {
                _stopped = true
                if _group.count == FlatMapNoIterators {
                    forwardOn(.Completed)
                    dispose()
                }
                else {
                    _sourceSubscription.dispose()
                }
            //}
        }
    }
    
    func subscribeInner(source: Observable<O.E>) {
        let iterDisposable = SingleAssignmentDisposable()
        if let disposeKey = _group.addDisposable(iterDisposable) {
            let iter = FlatMapSinkIter(parent: self, disposeKey: disposeKey)
            let subscription = source.subscribe(iter)
            iterDisposable.disposable = subscription
        }
    }
    
    func run() -> Disposable {
        _group.addDisposable(_sourceSubscription)

        let subscription = _parent._source.subscribe(self)
        _sourceSubscription.disposable = subscription
        
        return _group
    }
}

class FlatMapSink1<SourceType, S: ObservableConvertibleType, O : ObserverType where S.E == O.E> : FlatMapSink<SourceType, S, O> {
    override init(parent: Parent, observer: O) {
        super.init(parent: parent, observer: observer)
    }
    
    override func performMap(element: SourceType) throws -> S {
        return try _parent._selector1!(element)
    }
}

class FlatMapSink2<SourceType, S: ObservableConvertibleType, O: ObserverType where S.E == O.E> : FlatMapSink<SourceType, S, O> {
    private var _index = 0

    override init(parent: Parent, observer: O) {
        super.init(parent: parent, observer: observer)
    }
    
    override func performMap(element: SourceType) throws -> S {
        return try _parent._selector2!(element, try incrementChecked(&_index))
    }
}

class FlatMap<SourceType, S: ObservableConvertibleType>: Producer<S.E> {
    typealias Selector1 = (SourceType) throws -> S
    typealias Selector2 = (SourceType, Int) throws -> S
    
    private let _source: Observable<SourceType>
    
    private let _selector1: Selector1?
    private let _selector2: Selector2?
    
    init(source: Observable<SourceType>, selector: Selector1) {
        _source = source
        _selector1 = selector
        _selector2 = nil
    }
    
    init(source: Observable<SourceType>, selector: Selector2) {
        _source = source
        _selector2 = selector
        _selector1 = nil
    }
    
    override func run<O: ObserverType where O.E == S.E>(observer: O) -> Disposable {
        let sink: FlatMapSink<SourceType, S, O>
        if let _ = _selector1 {
            sink = FlatMapSink1(parent: self, observer: observer)
        }
        else {
            sink = FlatMapSink2(parent: self, observer: observer)
        }

        let subscription = sink.run()
        sink.disposable = subscription

        return sink
    }
}