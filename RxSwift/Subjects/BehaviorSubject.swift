//
//  BehaviorSubject.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 5/23/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// Represents a value that changes over time.
///
/// Observers can subscribe to the subject to receive the last (or initial) value and all subsequent notifications.
public final class BehaviorSubject<Element>:
    Observable<Element>,
    SubjectType,
    ObserverType,
    SynchronizedUnsubscribeType,
    Cancelable
{
    public typealias SubjectObserverType = BehaviorSubject<Element>

    typealias Observers = AnyObserver<Element>.s
    typealias DisposeKey = Observers.KeyType

    /// Indicates whether the subject has any observers
    public var hasObservers: Bool {
        lock.performLocked { self.observers.count > 0 }
    }

    let lock = RecursiveLock()

    // state
    private var disposed = false
    private var element: Element
    private var observers = Observers()
    private var stoppedEvent: Event<Element>?

    #if DEBUG
    private let synchronizationTracker = SynchronizationTracker()
    #endif

    /// Indicates whether the subject has been disposed.
    public var isDisposed: Bool {
        disposed
    }

    /// Initializes a new instance of the subject that caches its last value and starts with the specified value.
    ///
    /// - parameter value: Initial value sent to observers when no other value has been received by the subject yet.
    public init(value: Element) {
        element = value

        #if TRACE_RESOURCES
        _ = Resources.incrementTotal()
        #endif
    }

    /// Gets the current value or throws an error.
    ///
    /// - returns: Latest value.
    public func value() throws -> Element {
        lock.lock(); defer { self.lock.unlock() }
        if isDisposed {
            throw RxError.disposed(object: self)
        }

        if let error = stoppedEvent?.error {
            // intentionally throw exception
            throw error
        } else {
            return element
        }
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
        if stoppedEvent != nil || isDisposed {
            return Observers()
        }

        switch event {
        case let .next(element):
            self.element = element
        case .error, .completed:
            stoppedEvent = event
        }

        return observers
    }

    /// Subscribes an observer to the subject.
    ///
    /// - parameter observer: Observer to subscribe to the subject.
    /// - returns: Disposable object that can be used to unsubscribe the observer from the subject.
    override public func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element {
        lock.performLocked { self.synchronized_subscribe(observer) }
    }

    func synchronized_subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element {
        if isDisposed {
            observer.on(.error(RxError.disposed(object: self)))
            return Disposables.create()
        }

        if let stoppedEvent {
            observer.on(stoppedEvent)
            return Disposables.create()
        }

        let key = observers.insert(observer.on)
        observer.on(.next(element))

        return SubscriptionDisposable(owner: self, key: key)
    }

    func synchronizedUnsubscribe(_ disposeKey: DisposeKey) {
        lock.performLocked { self.synchronized_unsubscribe(disposeKey) }
    }

    func synchronized_unsubscribe(_ disposeKey: DisposeKey) {
        if isDisposed {
            return
        }

        _ = observers.removeKey(disposeKey)
    }

    /// Returns observer interface for subject.
    public func asObserver() -> BehaviorSubject<Element> {
        self
    }

    /// Unsubscribe all observers and release resources.
    public func dispose() {
        lock.performLocked {
            self.disposed = true
            self.observers.removeAll()
            self.stoppedEvent = nil
        }
    }

    #if TRACE_RESOURCES
    deinit {
        _ = Resources.decrementTotal()
    }
    #endif
}
