//
//  ReplaySubject.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 4/14/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// Represents an object that is both an observable sequence as well as an observer.
///
/// Each notification is broadcasted to all subscribed and future observers, subject to buffer trimming policies.
public class ReplaySubject<Element>:
    Observable<Element>,
    SubjectType,
    ObserverType,
    Disposable
{
    public typealias SubjectObserverType = ReplaySubject<Element>

    typealias Observers = AnyObserver<Element>.s
    typealias DisposeKey = Observers.KeyType

    /// Indicates whether the subject has any observers
    public var hasObservers: Bool {
        lock.performLocked { self.observers.count > 0 }
    }

    fileprivate let lock = RecursiveLock()

    // state
    fileprivate var isDisposed = false
    fileprivate var stopped = false
    fileprivate var stoppedEvent = nil as Event<Element>? {
        didSet {
            stopped = stoppedEvent != nil
        }
    }

    fileprivate var observers = Observers()

    #if DEBUG
    fileprivate let synchronizationTracker = SynchronizationTracker()
    #endif

    final var isStopped: Bool {
        stopped
    }

    /// Notifies all subscribed observers about next event.
    ///
    /// - parameter event: Event to send to the observers.
    public func on(_: Event<Element>) {
        rxAbstractMethod()
    }

    /// Returns observer interface for subject.
    public func asObserver() -> ReplaySubject<Element> {
        self
    }

    /// Unsubscribe all observers and release resources.
    public func dispose() {}

    /// Creates new instance of `ReplaySubject` that replays at most `bufferSize` last elements of sequence.
    ///
    /// - parameter bufferSize: Maximal number of elements to replay to observer after subscription.
    /// - returns: New instance of replay subject.
    public static func create(bufferSize: Int) -> ReplaySubject<Element> {
        if bufferSize == 1 {
            ReplayOne()
        } else {
            ReplayMany(bufferSize: bufferSize)
        }
    }

    /// Creates a new instance of `ReplaySubject` that buffers all the elements of a sequence.
    /// To avoid filling up memory, developer needs to make sure that the use case will only ever store a 'reasonable'
    /// number of elements.
    public static func createUnbounded() -> ReplaySubject<Element> {
        ReplayAll()
    }

    #if TRACE_RESOURCES
    override init() {
        _ = Resources.incrementTotal()
    }

    deinit {
        _ = Resources.decrementTotal()
    }
    #endif
}

private class ReplayBufferBase<Element>:
    ReplaySubject<Element>,
    SynchronizedUnsubscribeType
{
    func trim() {
        rxAbstractMethod()
    }

    func addValueToBuffer(_: Element) {
        rxAbstractMethod()
    }

    func replayBuffer<Observer: ObserverType>(_: Observer) where Observer.Element == Element {
        rxAbstractMethod()
    }

    override func on(_ event: Event<Element>) {
        #if DEBUG
        synchronizationTracker.register(synchronizationErrorMessage: .default)
        defer { self.synchronizationTracker.unregister() }
        #endif
        dispatch(synchronized_on(event), event)
    }

    func synchronized_on(_ event: Event<Element>) -> Observers {
        lock.lock(); defer { self.lock.unlock() }
        if isDisposed {
            return Observers()
        }

        if isStopped {
            return Observers()
        }

        switch event {
        case let .next(element):
            addValueToBuffer(element)
            trim()
            return observers
        case .error, .completed:
            stoppedEvent = event
            trim()
            let observers = observers
            self.observers.removeAll()
            return observers
        }
    }

    override func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element {
        lock.performLocked { self.synchronized_subscribe(observer) }
    }

    func synchronized_subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element {
        if isDisposed {
            observer.on(.error(RxError.disposed(object: self)))
            return Disposables.create()
        }

        let anyObserver = observer.asObserver()

        replayBuffer(anyObserver)
        if let stoppedEvent {
            observer.on(stoppedEvent)
            return Disposables.create()
        } else {
            let key = observers.insert(observer.on)
            return SubscriptionDisposable(owner: self, key: key)
        }
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

    override func dispose() {
        super.dispose()

        synchronizedDispose()
    }

    func synchronizedDispose() {
        lock.performLocked { self.synchronized_dispose() }
    }

    func synchronized_dispose() {
        isDisposed = true
        observers.removeAll()
    }
}

private final class ReplayOne<Element>: ReplayBufferBase<Element> {
    private var value: Element?

    override init() {
        super.init()
    }

    override func trim() {}

    override func addValueToBuffer(_ value: Element) {
        self.value = value
    }

    override func replayBuffer<Observer: ObserverType>(_ observer: Observer) where Observer.Element == Element {
        if let value {
            observer.on(.next(value))
        }
    }

    override func synchronized_dispose() {
        super.synchronized_dispose()
        value = nil
    }
}

private class ReplayManyBase<Element>: ReplayBufferBase<Element> {
    fileprivate var queue: Queue<Element>

    init(queueSize: Int) {
        queue = Queue(capacity: queueSize + 1)
    }

    override func addValueToBuffer(_ value: Element) {
        queue.enqueue(value)
    }

    override func replayBuffer<Observer: ObserverType>(_ observer: Observer) where Observer.Element == Element {
        for item in queue {
            observer.on(.next(item))
        }
    }

    override func synchronized_dispose() {
        super.synchronized_dispose()
        queue = Queue(capacity: 0)
    }
}

private final class ReplayMany<Element>: ReplayManyBase<Element> {
    private let bufferSize: Int

    init(bufferSize: Int) {
        self.bufferSize = bufferSize

        super.init(queueSize: bufferSize)
    }

    override func trim() {
        while queue.count > bufferSize {
            _ = queue.dequeue()
        }
    }
}

private final class ReplayAll<Element>: ReplayManyBase<Element> {
    init() {
        super.init(queueSize: 0)
    }

    override func trim() {}
}
