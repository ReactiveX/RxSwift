//
//  AsyncSubject.swift
//  RxSwift
//
//  Created by Victor Galán on 07/01/2017.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import Foundation

/// Represents the result of an asynchronous operation
///
/// Emits the last value (and only the last value) emitted by the source observable sequence,
/// and only after that source Observable completes.
public final class AsyncSubject<Element>
    : Observable<Element>
    , SubjectType
    , ObserverType
    , SynchronizedUnsubscribeType
, Disposable {
    public typealias SubjectObserverType = AsyncSubject<Element>
    typealias DisposeKey = Bag<AnyObserver<Element>>.KeyType

    /// Indicates whether the subject has any observers
    public var hasObservers: Bool {
        _lock.lock(); defer { _lock.unlock() }
        return _observers.count > 0
    }

    let _lock = NSRecursiveLock()

    // state
    private var _isDisposed = false
    private var _observers = Bag<AnyObserver<Element>>()
    private var _stoppedEvent: Event<Element>?
    private var _stopped = false
    private var _lastValue: Element?

    /// Indicates whether the subject has been disposed.
    public var isDisposed: Bool {
        return _isDisposed
    }

    /// Creates a subject.
    public override init() {
        super.init()
    }

    /// Notifies all subscribed observers about next event.
    ///
    /// - parameter event: Event to send to the observers.
    public func on(_ event: Event<E>) {
        _synchronized_on(event)
    }

    func _synchronized_on(_ event: Event<E>) {
        _lock.lock(); defer { _lock.unlock() }
        if  _isDisposed || _stopped {
            return
        }

        switch event {
        case .next(let value):
            _lastValue = value
        
        case .error:
            _stoppedEvent = event
            _stopped = true

            let observers = _observers
            _observers.removeAll()
            _lock.unlock()

            observers.on(event)
        
        case .completed:
            _stoppedEvent = event
            _stopped = true

            let observers = _observers
            _observers.removeAll()
            _lock.unlock()

            if let lastValue = _lastValue {
                observers.on(.next(lastValue))
            }

            observers.on(event)
        }
    }

    /// Subscribes an observer to the subject.
    ///
    /// - parameter observer: Observer to subscribe to the subject.
    /// - returns: Disposable object that can be used to unsubscribe the observer from the subject.
    public override func subscribe<O : ObserverType>(_ observer: O) -> Disposable where O.E == Element {
        _lock.lock(); defer { _lock.unlock() }
        return _synchronized_subscribe(observer)
    }

    func _synchronized_subscribe<O : ObserverType>(_ observer: O) -> Disposable where O.E == E {
        if _isDisposed {
            observer.on(.error(RxError.disposed(object: self)))
            return Disposables.create()
        }

        if let stoppedEvent = _stoppedEvent {
            if let lastValue = _lastValue, case .completed = stoppedEvent {
                observer.onNext(lastValue)
            }
            observer.on(stoppedEvent)
            return Disposables.create()
        }

        let key = _observers.insert(observer.asObserver())

        return SubscriptionDisposable(owner: self, key: key)
    }

    func synchronizedUnsubscribe(_ disposeKey: DisposeKey) {
        _lock.lock(); defer { _lock.unlock() }
        _synchronized_unsubscribe(disposeKey)
    }
    
    func _synchronized_unsubscribe(_ disposeKey: DisposeKey) {
        if _isDisposed {
            return
        }
        
        _ = _observers.removeKey(disposeKey)
    }
    
    /// Returns observer interface for subject.
    public func asObserver() -> AsyncSubject<Element> {
        return self
    }
    
    /// Unsubscribe all observers and release resources.
    public func dispose() {
        _lock.performLocked {
            _isDisposed = true
            _observers.removeAll()
            _stoppedEvent = nil
        }
    }
}

