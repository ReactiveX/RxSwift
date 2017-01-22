//
//  ShareReplay1.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 10/10/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

fileprivate class ShareReplay1Connection<Element>
    : ObserverType
    , Disposable {
    typealias E = Element
    typealias Parent = ShareReplay1<Element>

    private let _parent: Parent
    private let _subscription: Disposable
    private let _subject: ReplaySubject<Element>
    private var _disposed: Bool = false

    init(parent: Parent, subject: ReplaySubject<Element>, subscription: Disposable) {
        _parent = parent
        _subscription = subscription
        _subject = subject
    }

    final func on(_ event: Event<Element>) {
        _subject.on(event)

        if event.isStopEvent {
            self.dispose()
        }
    }

    final func dispose() {
        _parent._lock.lock(); defer { _parent._lock.unlock() }
        if _disposed {
            return
        }

        _disposed = true

        if _parent._connection === self {
            _parent._connection = nil
        }

        _subscription.dispose()
    }
}

final class ShareReplay1Sink<O: ObserverType>
    : Sink<O>
    , ObserverType {
    typealias E = O.E

    override init(observer: O, cancel: Cancelable) {
        super.init(observer: observer, cancel: cancel)
    }

    func on(_ event: Event<O.E>) {
        forwardOn(event)
        if event.isStopEvent {
            self.dispose()
        }
    }
}

// optimized version of share replay for most common case
final class ShareReplay1<Element>
    : Observable<Element> {

    typealias DisposeKey = Bag<AnyObserver<Element>>.KeyType

    private let _source: Observable<Element>
    private let _subject = ReplaySubject<Element>.create(bufferSize: 1)

    fileprivate let _lock = RecursiveLock()
    private var _count = 0
    fileprivate var _connection: ShareReplay1Connection<Element>?

    init(source: Observable<Element>) {
        self._source = source
    }

    override func subscribe<O : ObserverType>(_ observer: O) -> Disposable where O.E == E {
        let cancel = SingleAssignmentDisposable()

        let sink = ShareReplay1Sink(observer: observer, cancel: cancel)
        let subscription = _subject.subscribe(sink)

        _lock.lock()
        let refCountDisposable = _synchronized_subscribe(observer)
        _lock.unlock()
        let resultDisposable = Disposables.create {
            subscription.dispose()
            sink.dispose()
            refCountDisposable.dispose()
        }

        cancel.setDisposable(resultDisposable)

        return cancel
    }

    func _synchronized_subscribe<O : ObserverType>(_ observer: O) -> Disposable where O.E == E {
        let initialCount = _count

        self._count += 1

        if initialCount == 0 {
            let subscription = SingleAssignmentDisposable()
            let connection = ShareReplay1Connection(parent: self, subject: _subject, subscription: subscription)
            _connection = connection

            if !self._subject.isStopped {
                subscription.setDisposable(self._source.subscribe(connection))
            }
        }

        return Disposables.create {
            self._lock.lock(); defer { self._lock.unlock() }
            self._count -= 1

            if self._count == 0 {
                guard let connection = self._connection else {
                    return
                }

                connection.dispose()
                self._connection = nil
            }
        }
    }
}
