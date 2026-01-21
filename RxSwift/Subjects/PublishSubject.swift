//
//  PublishSubject.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/11/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// Represents an object that is both an observable sequence as well as an observer.
///
/// Each notification is broadcasted to all subscribed observers.
public final class PublishSubject<Element>:
    Observable<Element>,
    SubjectType,
    Cancelable,
    ObserverType,
    SynchronizedUnsubscribeType
{
    public typealias SubjectObserverType = PublishSubject<Element>

    typealias Observers = AnyObserver<Element>.s
    typealias DisposeKey = Observers.KeyType

    /// Indicates whether the subject has any observers
    public var hasObservers: Bool {
        lock.performLocked { self.observers.count > 0 }
    }

    private let lock = RecursiveLock()

    // state
    private var disposed = false
    private var observers = Observers()
    private var stopped = false
    private var stoppedEvent = nil as Event<Element>?

    #if DEBUG
    private let synchronizationTracker = SynchronizationTracker()
    #endif

    /// Indicates whether the subject has been isDisposed.
    public var isDisposed: Bool {
        disposed
    }

    /// Creates a subject.
    override public init() {
        super.init()
        #if TRACE_RESOURCES
        _ = Resources.incrementTotal()
        #endif
    }

    /// Notifies all subscribed observers about next event.
    ///
    /// - parameter event: Event to send to the observers.
    public func on(_ event: Event<Element>) {
        #if DEBUG
        synchronizationTracker.register(synchronizationErrorMessage: .default)
        defer { self.synchronizationTracker.unregister() }
        #endif
        dispatch(synchronized_on(event), event)
    }

    func synchronized_on(_ event: Event<Element>) -> Observers {
        lock.lock(); defer { self.lock.unlock() }
        switch event {
        case .next:
            if isDisposed || stopped {
                return Observers()
            }

            return observers
        case .completed, .error:
            if stoppedEvent == nil {
                stoppedEvent = event
                stopped = true
                let observers = observers
                self.observers.removeAll()
                return observers
            }

            return Observers()
        }
    }

    /**
     Subscribes an observer to the subject.

     - parameter observer: Observer to subscribe to the subject.
     - returns: Disposable object that can be used to unsubscribe the observer from the subject.
     */
    override public func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element {
        lock.performLocked { self.synchronized_subscribe(observer) }
    }

    func synchronized_subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element {
        if let stoppedEvent {
            observer.on(stoppedEvent)
            return Disposables.create()
        }

        if isDisposed {
            observer.on(.error(RxError.disposed(object: self)))
            return Disposables.create()
        }

        let key = observers.insert(observer.on)
        return SubscriptionDisposable(owner: self, key: key)
    }

    func synchronizedUnsubscribe(_ disposeKey: DisposeKey) {
        lock.performLocked { self.synchronized_unsubscribe(disposeKey) }
    }

    func synchronized_unsubscribe(_ disposeKey: DisposeKey) {
        _ = observers.removeKey(disposeKey)
    }

    /// Returns observer interface for subject.
    public func asObserver() -> PublishSubject<Element> {
        self
    }

    /// Unsubscribe all observers and release resources.
    public func dispose() {
        lock.performLocked { self.synchronized_dispose() }
    }

    final func synchronized_dispose() {
        disposed = true
        observers.removeAll()
        stoppedEvent = nil
    }

    #if TRACE_RESOURCES
    deinit {
        _ = Resources.decrementTotal()
    }
    #endif
}
