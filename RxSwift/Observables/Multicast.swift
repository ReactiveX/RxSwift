//
//  Multicast.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/27/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/**
 Represents an observable wrapper that can be connected and disconnected from its underlying observable sequence.
 */
public class ConnectableObservable<Element>
    : Observable<Element>
    , ConnectableObservableType {

    /**
     Connects the observable wrapper to its source. All subscribed observers will receive values from the underlying observable sequence as long as the connection is established.

     - returns: Disposable used to disconnect the observable wrapper from its source, causing subscribed observer to stop receiving values from the underlying observable sequence.
     */
    public func connect() -> Disposable {
        rxAbstractMethod()
    }
}

extension ObservableType {
    
    /**
    Multicasts the source sequence notifications through an instantiated subject into all uses of the sequence within a selector function. 
    
    Each subscription to the resulting sequence causes a separate multicast invocation, exposing the sequence resulting from the selector function's invocation.

    For specializations with fixed subject types, see `publish` and `replay`.

    - seealso: [multicast operator on reactivex.io](http://reactivex.io/documentation/operators/publish.html)
    
    - parameter subjectSelector: Factory function to create an intermediate subject through which the source sequence's elements will be multicast to the selector function.
    - parameter selector: Selector function which can use the multicasted source sequence subject to the policies enforced by the created subject.
    - returns: An observable sequence that contains the elements of a sequence produced by multicasting the source sequence within a selector function.
    */
    public func multicast<S: SubjectType, R>(_ subjectSelector: @escaping () throws -> S, selector: @escaping (Observable<S.E>) throws -> Observable<R>)
        -> Observable<R> where S.SubjectObserverType.E == E {
        return Multicast(
            source: self.asObservable(),
            subjectSelector: subjectSelector,
            selector: selector
        )
    }
}

extension ObservableType {
    
    /**
    Returns a connectable observable sequence that shares a single subscription to the underlying sequence. 
    
    This operator is a specialization of `multicast` using a `PublishSubject`.

    - seealso: [publish operator on reactivex.io](http://reactivex.io/documentation/operators/publish.html)
    
    - returns: A connectable observable sequence that shares a single subscription to the underlying sequence.
    */
    public func publish() -> ConnectableObservable<E> {
        return self.multicast { PublishSubject() }
    }
}

extension ObservableType {

    /**
     Returns a connectable observable sequence that shares a single subscription to the underlying sequence replaying bufferSize elements.

     This operator is a specialization of `multicast` using a `ReplaySubject`.

     - seealso: [replay operator on reactivex.io](http://reactivex.io/documentation/operators/replay.html)

     - parameter bufferSize: Maximum element count of the replay buffer.
     - returns: A connectable observable sequence that shares a single subscription to the underlying sequence.
     */
    public func replay(_ bufferSize: Int)
        -> ConnectableObservable<E> {
        return self.multicast { ReplaySubject.create(bufferSize: bufferSize) }
    }

    /**
     Returns a connectable observable sequence that shares a single subscription to the underlying sequence replaying all elements.

     This operator is a specialization of `multicast` using a `ReplaySubject`.

     - seealso: [replay operator on reactivex.io](http://reactivex.io/documentation/operators/replay.html)

     - returns: A connectable observable sequence that shares a single subscription to the underlying sequence.
     */
    public func replayAll()
        -> ConnectableObservable<E> {
        return self.multicast { ReplaySubject.createUnbounded() }
    }
}

extension ConnectableObservableType {
    
    /**
    Returns an observable sequence that stays connected to the source as long as there is at least one subscription to the observable sequence.

    - seealso: [refCount operator on reactivex.io](http://reactivex.io/documentation/operators/refcount.html)
    
    - returns: An observable sequence that stays connected to the source as long as there is at least one subscription to the observable sequence.
    */
    public func refCount() -> Observable<E> {
        return RefCount(source: self)
    }
}

extension ObservableType {

    /**
     Multicasts the source sequence notifications through the specified subject to the resulting connectable observable.

     Upon connection of the connectable observable, the subject is subscribed to the source exactly one, and messages are forwarded to the observers registered with the connectable observable.

     For specializations with fixed subject types, see `publish` and `replay`.

     - seealso: [multicast operator on reactivex.io](http://reactivex.io/documentation/operators/publish.html)

     - parameter subject: Subject to push source elements into.
     - returns: A connectable observable sequence that upon connection causes the source sequence to push results into the specified subject.
     */
    public func multicast<S: SubjectType>(_ subject: S)
        -> ConnectableObservable<S.E> where S.SubjectObserverType.E == E {
        return ConnectableObservableAdapter(source: self.asObservable(), makeSubject: { subject })
    }

    /**
     Multicasts the source sequence notifications through an instantiated subject to the resulting connectable observable.

     Upon connection of the connectable observable, the subject is subscribed to the source exactly one, and messages are forwarded to the observers registered with the connectable observable.
     
     Subject is cleared on connection disposal or in case source sequence produces terminal event.

     - seealso: [multicast operator on reactivex.io](http://reactivex.io/documentation/operators/publish.html)

     - parameter makeSubject: Factory function used to instantiate a subject for each connection.
     - returns: A connectable observable sequence that upon connection causes the source sequence to push results into the specified subject.
     */
    public func multicast<S: SubjectType>(makeSubject: @escaping () -> S)
        -> ConnectableObservable<S.E> where S.SubjectObserverType.E == E {
        return ConnectableObservableAdapter(source: self.asObservable(), makeSubject: makeSubject)
    }
}

final fileprivate class Connection<S: SubjectType> : ObserverType, Disposable {
    typealias E = S.SubjectObserverType.E

    private var _lock: RecursiveLock
    // state
    private var _parent: ConnectableObservableAdapter<S>?
    private var _subscription : Disposable?
    private var _subjectObserver: S.SubjectObserverType

    private var _disposed: Bool = false

    init(parent: ConnectableObservableAdapter<S>, subjectObserver: S.SubjectObserverType, lock: RecursiveLock, subscription: Disposable) {
        _parent = parent
        _subscription = subscription
        _lock = lock
        _subjectObserver = subjectObserver
    }

    func on(_ event: Event<S.SubjectObserverType.E>) {
        if _disposed {
            return
        }
        if event.isStopEvent {
            self.dispose()
        }
        _subjectObserver.on(event)
    }

    func dispose() {
        _lock.lock(); defer { _lock.unlock() } // {
        _disposed = true
        guard let parent = _parent else {
            return
        }

        if parent._connection === self {
            parent._connection = nil
            parent._subject = nil
        }
        _parent = nil

        _subscription?.dispose()
        _subscription = nil
        // }
    }
}

final fileprivate class ConnectableObservableAdapter<S: SubjectType>
    : ConnectableObservable<S.E> {
    typealias ConnectionType = Connection<S>

    fileprivate let _source: Observable<S.SubjectObserverType.E>
    fileprivate let _makeSubject: () -> S

    fileprivate let _lock = RecursiveLock()
    fileprivate var _subject: S?

    // state
    fileprivate var _connection: ConnectionType?

    init(source: Observable<S.SubjectObserverType.E>, makeSubject: @escaping () -> S) {
        _source = source
        _makeSubject = makeSubject
        _subject = nil
        _connection = nil
    }

    override func connect() -> Disposable {
        return _lock.calculateLocked {
            if let connection = _connection {
                return connection
            }

            let singleAssignmentDisposable = SingleAssignmentDisposable()
            let connection = Connection(parent: self, subjectObserver: self.lazySubject.asObserver(), lock: _lock, subscription: singleAssignmentDisposable)
            _connection = connection
            let subscription = _source.subscribe(connection.on)
            singleAssignmentDisposable.setDisposable(subscription)
            return connection
        }
    }

    fileprivate var lazySubject: S {
        if let subject = self._subject {
            return subject
        }

        let subject = _makeSubject()
        self._subject = subject
        return subject
    }

    override func subscribe(_ observer: @escaping (Event<S.E>) -> ()) -> Disposable {
        return self.lazySubject.subscribe(observer)
    }
}

final fileprivate class RefCount<CO: ConnectableObservableType>: Producer<CO.E> {
    fileprivate let _lock = RecursiveLock()

    // state
    fileprivate var _count = 0
    fileprivate var _connectionId: Int64 = 0
    fileprivate var _connectableSubscription = nil as Disposable?

    fileprivate let _source: CO

    init(source: CO) {
        _source = source
    }

    override func run(_ observer: @escaping (Event<CO.E>) -> (), cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) {
        let sink = Sink(observer: observer, cancel: cancel)
        let subscription = { () -> Disposable in
            self._lock.lock(); defer { self._lock.unlock() } // {

            let _connectionIdSnapshot = self._connectionId

            let subscription = _source.subscribe { event in
                    switch event {
                    case .next:
                        sink.forwardOn(event)
                    case .error, .completed:
                        self._lock.lock() // {
                        if self._connectionId == _connectionIdSnapshot {
                            let connection = self._connectableSubscription
                            defer { connection?.dispose() }
                            self._count = 0
                            self._connectionId = self._connectionId &+ 1
                            self._connectableSubscription = nil
                        }
                        // }
                        self._lock.unlock()
                        sink.forwardOn(event)
                        sink.dispose()
                    }
                }

            if sink.disposed {
                return Disposables.create()
            }

            if self._count == 0 {
                self._count = 1
                self._connectableSubscription = self._source.connect()
            }
            else {
                self._count = self._count + 1
            }
            // }

            return Disposables.create {
                subscription.dispose()
                self._lock.lock(); defer { self._lock.unlock() } // {
                if self._connectionId != _connectionIdSnapshot {
                    return
                }
                if self._count == 1 {
                    self._count = 0
                    guard let connectableSubscription = self._connectableSubscription else {
                        return
                    }

                    connectableSubscription.dispose()
                    self._connectableSubscription = nil
                }
                else if self._count > 1 {
                    self._count = self._count - 1
                }
                else {
                    rxFatalError("Something went wrong with RefCount disposing mechanism")
                }
                // }
            }
        }()
        return (sink: sink, subscription: subscription)
    }
}

final fileprivate class Multicast<S: SubjectType, R>: Producer<R> {
    typealias SubjectSelectorType = () throws -> S
    typealias SelectorType = (Observable<S.E>) throws -> Observable<R>
    
    fileprivate let _source: Observable<S.SubjectObserverType.E>
    fileprivate let _subjectSelector: SubjectSelectorType
    fileprivate let _selector: SelectorType
    
    init(source: Observable<S.SubjectObserverType.E>, subjectSelector: @escaping SubjectSelectorType, selector: @escaping SelectorType) {
        _source = source
        _subjectSelector = subjectSelector
        _selector = selector
    }
    
    override func run(_ observer: @escaping (Event<R>) -> (), cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) {
        let sink = Sink(observer: observer, cancel: cancel)
        let subscription = { () -> Disposable in
            do {
                let subject = try self._subjectSelector()
                let connectable = ConnectableObservableAdapter(source: _source, makeSubject: { subject })

                let observable = try self._selector(connectable)

                let subscription = observable.subscribe { event in
                    sink.forwardOn(event)
                    switch event {
                    case .next: break
                    case .error, .completed:
                        sink.dispose()
                    }
                }
                let connection = connectable.connect()

                return Disposables.create(subscription, connection)
            }
            catch let e {
                sink.forwardOn(.error(e))
                sink.dispose()
                return Disposables.create()
            }
        }()
        return (sink: sink, subscription: subscription)
    }
}
