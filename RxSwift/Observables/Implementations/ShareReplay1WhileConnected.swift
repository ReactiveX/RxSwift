//
//  ShareReplay1WhileConnected.swift
//  Rx
//
//  Created by Krunoslav Zaher on 12/6/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// optimized version of share replay for most common case
final class ShareReplay1WhileConnected<Element>
    : Observable<Element>
    , ObserverType
    , SynchronizedUnsubscribeType {

    typealias DisposeKey = Bag<AnyObserver<Element>>.KeyType

    private let _source: Observable<Element>

    private var _lock = RecursiveLock()

    private var _connection: SingleAssignmentDisposable?
    private var _element: Element?
    private var _observers = Bag<AnyObserver<Element>>()

    init(source: Observable<Element>) {
        self._source = source
    }

    override func subscribe<O : ObserverType where O.E == E>(_ observer: O) -> Disposable {
        _lock.lock(); defer { _lock.unlock() }
        return _synchronized_subscribe(observer)
    }

    func _synchronized_subscribe<O : ObserverType where O.E == E>(_ observer: O) -> Disposable {
        if let element = self._element {
            observer.on(.next(element))
        }

        let initialCount = self._observers.count

        let disposeKey = self._observers.insert(AnyObserver(observer))

        if initialCount == 0 {
            let connection = SingleAssignmentDisposable()
            _connection = connection

            connection.disposable = self._source.subscribe(self)
        }

        return SubscriptionDisposable(owner: self, key: disposeKey)
    }

    func synchronizedUnsubscribe(_ disposeKey: DisposeKey) {
        _lock.lock(); defer { _lock.unlock() }
        _synchronized_unsubscribe(disposeKey)
    }

    func _synchronized_unsubscribe(_ disposeKey: DisposeKey) {
        // if already unsubscribed, just return
        if self._observers.removeKey(disposeKey) == nil {
            return
        }

        if _observers.count == 0 {
            _connection?.dispose()
            _connection = nil
            _element = nil
        }
    }

    func on(_ event: Event<E>) {
        _lock.lock(); defer { _lock.unlock() }
        _synchronized_on(event)
    }

    func _synchronized_on(_ event: Event<E>) {
        switch event {
        case .next(let element):
            _element = element
            _observers.on(event)
        case .error, .completed:
            _element = nil
            _connection?.dispose()
            _connection = nil
            let observers = _observers
            _observers = Bag()
            observers.on(event)
        }
    }
}
