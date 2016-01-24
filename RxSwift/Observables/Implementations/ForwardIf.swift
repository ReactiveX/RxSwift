//
//  ForwardIf.swift
//  Rx
//
//  Created by Jorge Bernal Ordovas on 20/01/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation

class ForwardIfSinkIter<S: ObservableType, O: ObserverType where O.E == S.E> : ObserverType {
    typealias Parent = ForwardIfSink<S, O>
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
            _parent._lock.lock(); defer { _parent._lock.unlock() } // lock {
                _parent.forwardOn(.Completed)
                _parent.dispose()
            // }
        }
    }

}

class ForwardIfSink<S: ObservableType, O: ObserverType where O.E == S.E>: Sink<O>, ObserverType {
    typealias E = Bool
    typealias SourceType = S.E
    typealias DisposeKey = CompositeDisposable.DisposeKey

    private let _lock = NSRecursiveLock()

    private let _source: S
    private let _group = CompositeDisposable()
    private let _conditionSubscription = SingleAssignmentDisposable()
    private var _sourceDisposeKey: DisposeKey? = nil

    init(observer: O, source: S) {
        _source = source
        super.init(observer: observer)
    }

    func on(event: Event<E>) {
        switch event {
        case .Next(let element):
            if element {
                subscribeInner(_source)
            } else {
                unsubscribeInner()
            }
        case .Completed:
            _lock.lock(); defer { _lock.unlock() } // lock {
                forwardOn(.Completed)
                dispose()
            // }
        case .Error(let error):
            _lock.lock(); defer { _lock.unlock() } // lock {
                forwardOn(.Error(error))
                dispose()
            // }
        }
    }

    func subscribeInner(source: S) {
        print("subscribeInner")
        if _sourceDisposeKey != nil {
            return
        }
        let iterDisposable = SingleAssignmentDisposable()
        if let disposeKey = _group.addDisposable(iterDisposable) {
            _sourceDisposeKey = disposeKey
            let iter = ForwardIfSinkIter(parent: self, disposeKey: disposeKey)
            let subscription = source.subscribe(iter)
            iterDisposable.disposable = subscription
        }
    }

    func unsubscribeInner() {
        if let disposeKey = _sourceDisposeKey {
            _group.removeDisposable(disposeKey)
            _sourceDisposeKey = nil
        }
    }

    func run(condition: Observable<Bool>) -> Disposable {
        _group.addDisposable(_conditionSubscription)

        let subscription = condition.subscribe(self)
        _conditionSubscription.disposable = subscription

        return _group
    }
}

class ForwardIf<S: ObservableType>: Producer<S.E> {
    private let _source: S
    private let _condition: Observable<Bool>

    init(source: S, condition: Observable<Bool>) {
        _source = source
        _condition = condition
    }

    override func run<O: ObserverType where O.E == S.E>(observer: O) -> Disposable {
        let sink = ForwardIfSink<S, O>(observer: observer, source: _source)
        sink.disposable = sink.run(_condition)
        return sink
    }
}
