//
//  ShareReplay1WhileConnected.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 12/6/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

fileprivate final class ShareReplay1WhileConnectedConnection<Element>
    : ObserverType
    , SynchronizedUnsubscribeType {
    typealias E = Element
    typealias DisposeKey = Bag<(Event<Element>) -> ()>.KeyType

    typealias Parent = ShareReplay1WhileConnected<Element>
    private let _parent: Parent
    private let _subscription = SingleAssignmentDisposable()

    private let _lock: RecursiveLock
    private var _disposed: Bool = false
    fileprivate var _observers = Bag<(Event<Element>) -> ()>()
    fileprivate var _element: Element?

    init(parent: Parent, lock: RecursiveLock) {
        _parent = parent
        _lock = lock
    }

    final func on(_ event: Event<E>) {
        dispatch(_synchronized_on(event), event)
    }

    final private func _synchronized_on(_ event: Event<E>) -> Bag<(Event<Element>) -> ()> {
        _lock.lock(); defer { _lock.unlock() }
        if _disposed {
            return Bag()
        }

        switch event {
        case .next(let element):
            _element = element
            return _observers
        case .error, .completed:
            let observers = _observers
            self._synchronized_dispose()
            return observers
        }
    }

    func connect() {
        _subscription.setDisposable(_parent._source.subscribe(self))
    }

    func synchronizedUnsubscribe(_ disposeKey: DisposeKey) {
        _lock.lock()
        _synchronized_unsubscribe(disposeKey)
        _lock.unlock()
    }

    final private func _synchronized_dispose() {
        _disposed = true
        if _parent._connection === self {
            _parent._connection = nil
        }
        _observers = Bag()
        _subscription.dispose()
    }

    @inline(__always)
    final private func _synchronized_unsubscribe(_ disposeKey: DisposeKey) {
        // if already unsubscribed, just return
        if self._observers.removeKey(disposeKey) == nil {
            return
        }

        if _observers.count == 0 {
            _synchronized_dispose()
        }
    }
}

// optimized version of share replay for most common case
final class ShareReplay1WhileConnected<Element>
    : Observable<Element> {

    fileprivate typealias Connection = ShareReplay1WhileConnectedConnection<Element>

    fileprivate let _source: Observable<Element>

    private let _lock = RecursiveLock()

    fileprivate var _connection: Connection?

    init(source: Observable<Element>) {
        self._source = source
    }

    override func subscribe<O : ObserverType>(_ observer: O) -> Disposable where O.E == E {
        _lock.lock()
        let (disposable, connection) = _synchronized_subscribe(observer)
        let count = connection._observers.count
        _lock.unlock()

        if count == 1 {
            connection.connect()
        }
        
        return disposable
    }

    @inline(__always)
    private func _synchronized_subscribe<O : ObserverType>(_ observer: O) -> (Disposable, Connection) where O.E == E {
        let connection: Connection

        if let existingConnection = _connection {
            connection = existingConnection
        }
        else {
            connection = ShareReplay1WhileConnectedConnection<Element>(
                parent: self,
                lock: _lock)
            _connection = connection
        }
        
        if let element = connection._element {
            observer.on(.next(element))
        }

        let disposeKey = connection._observers.insert(observer.on)

        return (SubscriptionDisposable(owner: connection, key: disposeKey), connection)
    }

}
