//
//  RetryWhen.swift
//  Rx
//
//  Created by Junior B. on 06/10/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class RetryTriggerSink<S: Sequence, O: ObserverType, TriggerObservable: ObservableType, Error where S.Iterator.Element : ObservableType, S.Iterator.Element.E == O.E>
    : ObserverType {
    typealias E = TriggerObservable.E
    
    typealias Parent = RetryWhenSequenceSinkIter<S, O, TriggerObservable, Error>
    
    private let _parent: Parent

    init(parent: Parent) {
        _parent = parent
    }

    func on(_ event: Event<E>) {
        switch event {
        case .next:
            _parent._parent._lastError = nil
            _parent._parent.schedule(.moveNext)
        case .error(let e):
            _parent._parent.forwardOn(.error(e))
            _parent._parent.dispose()
        case .completed:
            _parent._parent.forwardOn(.completed)
            _parent._parent.dispose()
        }
    }
}

class RetryWhenSequenceSinkIter<S: Sequence, O: ObserverType, TriggerObservable: ObservableType, Error where S.Iterator.Element : ObservableType, S.Iterator.Element.E == O.E>
    : SingleAssignmentDisposable
    , ObserverType {
    typealias E = O.E
    typealias Parent = RetryWhenSequenceSink<S, O, TriggerObservable, Error>

    private let _parent: Parent
    private let _errorHandlerSubscription = SingleAssignmentDisposable()

    init(parent: Parent) {
        _parent = parent
    }

    func on(_ event: Event<E>) {
        switch event {
        case .next:
            _parent.forwardOn(event)
        case .error(let error):
            _parent._lastError = error

            if let failedWith = error as? Error {
                // dispose current subscription
                super.dispose()

                let errorHandlerSubscription = _parent._notifier.subscribe(RetryTriggerSink(parent: self))
                _errorHandlerSubscription.disposable = errorHandlerSubscription
                _parent._errorSubject.on(.next(failedWith))
            }
            else {
                _parent.forwardOn(.error(error))
                _parent.dispose()
            }
        case .completed:
            _parent.forwardOn(event)
            _parent.dispose()
        }
    }

    override func dispose() {
        super.dispose()
        _errorHandlerSubscription.dispose()
    }
}

class RetryWhenSequenceSink<S: Sequence, O: ObserverType, TriggerObservable: ObservableType, Error where S.Iterator.Element : ObservableType, S.Iterator.Element.E == O.E>
    : TailRecursiveSink<S, O> {
    typealias Element = O.E
    typealias Parent = RetryWhenSequence<S, TriggerObservable, Error>
    
    let _lock = RecursiveLock()
    
    private let _parent: Parent
    
    private var _lastError: ErrorProtocol?
    private let _errorSubject = PublishSubject<Error>()
    private let _handler: Observable<TriggerObservable.E>
    private let _notifier = PublishSubject<TriggerObservable.E>()

    init(parent: Parent, observer: O) {
        _parent = parent
        _handler = parent._notificationHandler(_errorSubject).asObservable()
        super.init(observer: observer)
    }
    
    override func done() {
        if let lastError = _lastError {
            forwardOn(.error(lastError))
            _lastError = nil
        }
        else {
            forwardOn(.completed)
        }

        dispose()
    }
    
    override func extract(_ observable: Observable<E>) -> SequenceGenerator? {
        // It is important to always return `nil` here because there are sideffects in the `run` method
        // that are dependant on particular `retryWhen` operator so single operator stack can't be reused in this
        // case.
        return nil
    }

    override func subscribeToNext(_ source: Observable<E>) -> Disposable {
        let iter = RetryWhenSequenceSinkIter(parent: self)
        iter.disposable = source.subscribe(iter)
        return iter
    }

    override func run(_ sources: SequenceGenerator) -> Disposable {
        let triggerSubscription = _handler.subscribe(_notifier.asObserver())
        let superSubscription = super.run(sources)
        return StableCompositeDisposable.create(superSubscription, triggerSubscription)
    }
}

class RetryWhenSequence<S: Sequence, TriggerObservable: ObservableType, Error where S.Iterator.Element : ObservableType> : Producer<S.Iterator.Element.E> {
    typealias Element = S.Iterator.Element.E
    
    private let _sources: S
    private let _notificationHandler: (Observable<Error>) -> TriggerObservable
    
    init(sources: S, notificationHandler: (Observable<Error>) -> TriggerObservable) {
        _sources = sources
        _notificationHandler = notificationHandler
    }
    
    override func run<O : ObserverType where O.E == Element>(_ observer: O) -> Disposable {
        let sink = RetryWhenSequenceSink<S, O, TriggerObservable, Error>(parent: self, observer: observer)
        sink.disposable = sink.run((self._sources.makeIterator(), nil))
        return sink
    }
}
