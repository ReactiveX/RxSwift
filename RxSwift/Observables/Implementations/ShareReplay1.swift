//
//  ShareReplay1.swift
//  Rx
//
//  Created by Krunoslav Zaher on 10/10/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// optimized version of share replay for most common case
class ShareReplay1<Element>
    : Observable<Element>
    , ObserverType
    , LockOwnerType
    , SynchronizedOnType
    , SynchronizedSubscribeType
    , SynchronizedUnsubscribeType {

    typealias DisposeKey = Bag<AnyObserver<Element>>.KeyType

    private let _source: Observable<Element>

    let _lock = NSRecursiveLock()

    private var _subscription: Disposable?
    private var _element: Element?
    private var _stopEvent = nil as Event<Element>?
    private var _observers = Bag<AnyObserver<Element>>()

    init(source: Observable<Element>) {
        self._source = source
    }


    override func subscribe<O : ObserverType where O.E == E>(observer: O) -> Disposable {
        return synchronizedSubscribe(observer)
    }

    func _synchronized_subscribe<O : ObserverType where O.E == E>(observer: O) -> Disposable {
        if let element = self._element {
            observer.on(.Next(element))
        }

        if let stopEvent = self._stopEvent {
            observer.on(stopEvent)
            return NopDisposable.instance
        }

        let initialCount = self._observers.count

        let disposeKey = self._observers.insert(AnyObserver(observer))

        if initialCount == 0 {
            self._subscription = self._source.subscribe(self)
        }

        return SubscriptionDisposable(owner: self, key: disposeKey)
    }

    func _synchronized_unsubscribe(disposeKey: DisposeKey) {
        // if already unsubscribed, just return
        if self._observers.removeKey(disposeKey) == nil {
            return
        }

        if self._observers.count == 0 {
            self._subscription?.dispose()
            self._subscription = nil
        }
    }

    func on(event: Event<E>) {
        synchronizedOn(event)
    }

    func _synchronized_on(event: Event<E>) {
        if self._stopEvent != nil {
            return
        }

        if case .Next(let element) = event {
            self._element = element
        }

        if event.isStopEvent {
            self._stopEvent = event
        }

        _observers.on(event)
    }
}