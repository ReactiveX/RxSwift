//
//  Merge.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

public extension ObservableType {
    /**
     Projects each element of an observable sequence to an observable sequence and merges the resulting observable sequences into one observable sequence.

     - seealso: [flatMap operator on reactivex.io](http://reactivex.io/documentation/operators/flatmap.html)

     - parameter selector: A transform function to apply to each element.
     - returns: An observable sequence whose elements are the result of invoking the one-to-many transform function on each element of the input sequence.
     */
    func flatMap<Source: ObservableConvertibleType>(_ selector: @escaping (Element) throws -> Source)
        -> Observable<Source.Element>
    {
        FlatMap(source: asObservable(), selector: selector)
    }
}

public extension ObservableType {
    /**
     Projects each element of an observable sequence to an observable sequence and merges the resulting observable sequences into one observable sequence.
     If element is received while there is some projected observable sequence being merged it will simply be ignored.

     - seealso: [flatMapFirst operator on reactivex.io](http://reactivex.io/documentation/operators/flatmap.html)

     - parameter selector: A transform function to apply to element that was observed while no observable is executing in parallel.
     - returns: An observable sequence whose elements are the result of invoking the one-to-many transform function on each element of the input sequence that was received while no other sequence was being calculated.
     */
    func flatMapFirst<Source: ObservableConvertibleType>(_ selector: @escaping (Element) throws -> Source)
        -> Observable<Source.Element>
    {
        FlatMapFirst(source: asObservable(), selector: selector)
    }
}

public extension ObservableType where Element: ObservableConvertibleType {
    /**
     Merges elements from all observable sequences in the given enumerable sequence into a single observable sequence.

     - seealso: [merge operator on reactivex.io](http://reactivex.io/documentation/operators/merge.html)

     - returns: The observable sequence that merges the elements of the observable sequences.
     */
    func merge() -> Observable<Element.Element> {
        Merge(source: asObservable())
    }

    /**
     Merges elements from all inner observable sequences into a single observable sequence, limiting the number of concurrent subscriptions to inner sequences.

     - seealso: [merge operator on reactivex.io](http://reactivex.io/documentation/operators/merge.html)

     - parameter maxConcurrent: Maximum number of inner observable sequences being subscribed to concurrently.
     - returns: The observable sequence that merges the elements of the inner sequences.
     */
    func merge(maxConcurrent: Int)
        -> Observable<Element.Element>
    {
        MergeLimited(source: asObservable(), maxConcurrent: maxConcurrent)
    }
}

public extension ObservableType where Element: ObservableConvertibleType {
    /**
     Concatenates all inner observable sequences, as long as the previous observable sequence terminated successfully.

     - seealso: [concat operator on reactivex.io](http://reactivex.io/documentation/operators/concat.html)

     - returns: An observable sequence that contains the elements of each observed inner sequence, in sequential order.
     */
    func concat() -> Observable<Element.Element> {
        merge(maxConcurrent: 1)
    }
}

public extension ObservableType {
    /**
     Merges elements from all observable sequences from collection into a single observable sequence.

     - seealso: [merge operator on reactivex.io](http://reactivex.io/documentation/operators/merge.html)

     - parameter sources: Collection of observable sequences to merge.
     - returns: The observable sequence that merges the elements of the observable sequences.
     */
    static func merge<Collection: Swift.Collection>(_ sources: Collection) -> Observable<Element> where Collection.Element == Observable<Element> {
        MergeArray(sources: Array(sources))
    }

    /**
     Merges elements from all observable sequences from array into a single observable sequence.

     - seealso: [merge operator on reactivex.io](http://reactivex.io/documentation/operators/merge.html)

     - parameter sources: Array of observable sequences to merge.
     - returns: The observable sequence that merges the elements of the observable sequences.
     */
    static func merge(_ sources: [Observable<Element>]) -> Observable<Element> {
        MergeArray(sources: sources)
    }

    /**
     Merges elements from all observable sequences into a single observable sequence.

     - seealso: [merge operator on reactivex.io](http://reactivex.io/documentation/operators/merge.html)

     - parameter sources: Collection of observable sequences to merge.
     - returns: The observable sequence that merges the elements of the observable sequences.
     */
    static func merge(_ sources: Observable<Element>...) -> Observable<Element> {
        MergeArray(sources: sources)
    }
}

// MARK: concatMap

public extension ObservableType {
    /**
     Projects each element of an observable sequence to an observable sequence and concatenates the resulting observable sequences into one observable sequence.

     - seealso: [concat operator on reactivex.io](http://reactivex.io/documentation/operators/concat.html)

     - returns: An observable sequence that contains the elements of each observed inner sequence, in sequential order.
     */

    func concatMap<Source: ObservableConvertibleType>(_ selector: @escaping (Element) throws -> Source)
        -> Observable<Source.Element>
    {
        ConcatMap(source: asObservable(), selector: selector)
    }
}

private final class MergeLimitedSinkIter<SourceElement, SourceSequence: ObservableConvertibleType, Observer: ObserverType>:
    ObserverType where SourceSequence.Element == Observer.Element
{
    typealias Element = Observer.Element
    typealias DisposeKey = CompositeDisposable.DisposeKey
    typealias Parent = MergeLimitedSink<SourceElement, SourceSequence, Observer>

    private let parent: Parent
    private let disposeKey: DisposeKey

    init(parent: Parent, disposeKey: DisposeKey) {
        self.parent = parent
        self.disposeKey = disposeKey
    }

    func on(_ event: Event<Element>) {
        switch event {
        case .next:
            parent.synchronizedForwardOn(event)
        case .error:
            parent.synchronizedForwardOnAndDispose(event)
        case .completed:
            parent.group.remove(for: disposeKey)
            parent.dequeueNextAndSubscribe()
        }
    }
}

private final class ConcatMapSink<SourceElement, SourceSequence: ObservableConvertibleType, Observer: ObserverType>: MergeLimitedSink<SourceElement, SourceSequence, Observer> where Observer.Element == SourceSequence.Element {
    typealias Selector = (SourceElement) throws -> SourceSequence

    private let selector: Selector

    init(selector: @escaping Selector, observer: Observer, cancel: Cancelable) {
        self.selector = selector
        super.init(maxConcurrent: 1, observer: observer, cancel: cancel)
    }

    override func performMap(_ element: SourceElement) throws -> SourceSequence {
        try selector(element)
    }
}

private final class MergeLimitedBasicSink<SourceSequence: ObservableConvertibleType, Observer: ObserverType>: MergeLimitedSink<SourceSequence, SourceSequence, Observer> where Observer.Element == SourceSequence.Element {
    override func performMap(_ element: SourceSequence) throws -> SourceSequence {
        element
    }
}

private class MergeLimitedSink<SourceElement, SourceSequence: ObservableConvertibleType, Observer: ObserverType>:
    Sink<Observer>,
    ObserverType where Observer.Element == SourceSequence.Element
{
    typealias QueueType = Queue<SourceSequence>

    let maxConcurrent: Int

    let lock = RecursiveLock()
    let forwardLock = RecursiveLock()

    // state
    var stopped = false
    var terminating = false
    var activeCount = 0
    var queue = QueueType(capacity: 2)

    let sourceSubscription = SingleAssignmentDisposable()
    let group = CompositeDisposable()

    init(maxConcurrent: Int, observer: Observer, cancel: Cancelable) {
        self.maxConcurrent = maxConcurrent
        super.init(observer: observer, cancel: cancel)
    }

    func run(_ source: Observable<SourceElement>) -> Disposable {
        _ = group.insert(sourceSubscription)

        let disposable = source.subscribe(self)
        sourceSubscription.setDisposable(disposable)
        return group
    }

    @discardableResult
    func subscribe(_ innerSource: SourceSequence, group: CompositeDisposable) -> Disposable {
        let subscription = SingleAssignmentDisposable()

        let shouldSubscribe = lock.performLocked { () -> Bool in
            if self.terminating {
                self.activeCount -= 1
                return false
            }

            return true
        }

        guard shouldSubscribe else {
            return subscription
        }

        let key = group.insert(subscription)

        if let key {
            let observer = MergeLimitedSinkIter(parent: self, disposeKey: key)

            let disposable = innerSource.asObservable().subscribe(observer)
            subscription.setDisposable(disposable)
        }
        return subscription
    }

    func dequeueNextAndSubscribe() {
        let next: SourceSequence?
        let completed: Bool

        (next, completed) = lock.performLocked {
            if terminating {
                activeCount -= 1
                return (nil, false)
            }

            if let next = queue.dequeue() {
                return (next, false)
            }

            activeCount -= 1

            return (nil, shouldComplete)
        }

        if let next {
            // subscribing immediately can produce values immediately which can re-enter and cause stack overflows
            let disposable = CurrentThreadScheduler.instance.schedule(()) { _ in
                self.subscribe(next, group: self.group)
            }
            _ = group.insert(disposable)
        } else if completed {
            synchronizedForwardOnAndDispose(.completed)
        }
    }

    func performMap(_: SourceElement) throws -> SourceSequence {
        rxAbstractMethod()
    }

    @inline(__always)
    private final func nextElementArrived(element: SourceElement) -> Result<SourceSequence?, Swift.Error> {
        let subscribeImmediately = lock.performLocked { () -> Bool? in
            if self.stopped || self.terminating {
                return nil
            }

            if self.activeCount < self.maxConcurrent {
                self.activeCount += 1
                return true
            }

            return false
        }

        guard let subscribeImmediately else {
            return .success(nil)
        }

        do {
            let value = try self.performMap(element)

            if subscribeImmediately {
                return .success(value)
            }

            let next = lock.performLocked { () -> SourceSequence? in
                if self.terminating {
                    return nil
                }

                self.queue.enqueue(value)

                if self.activeCount < self.maxConcurrent, let next = self.queue.dequeue() {
                    self.activeCount += 1
                    return next
                }

                return nil
            }

            return .success(next)
        } catch {
            let shouldFail = lock.performLocked { () -> Bool in
                if subscribeImmediately {
                    self.activeCount -= 1
                }

                return !self.terminating
            }

            if shouldFail {
                return .failure(error)
            }

            return .success(nil)
        }
    }

    func on(_ event: Event<SourceElement>) {
        switch event {
        case let .next(element):
            switch nextElementArrived(element: element) {
            case let .success(.some(sequence)):
                subscribe(sequence, group: group)
            case .success(.none):
                break
            case let .failure(error):
                synchronizedForwardOnAndDispose(.error(error))
            }
        case let .error(error):
            synchronizedForwardOnAndDispose(.error(error))
        case .completed:
            let completed = lock.performLocked { () -> Bool in
                self.stopped = true
                return self.shouldComplete
            }

            if completed {
                synchronizedForwardOnAndDispose(.completed)
            } else {
                sourceSubscription.dispose()
            }
        }
    }

    var shouldComplete: Bool {
        stopped && activeCount == 0 && !terminating
    }

    func synchronizedForwardOn(_ event: Event<Observer.Element>) {
        let shouldForward = lock.performLocked {
            !self.terminating
        }

        guard shouldForward else {
            return
        }

        forwardLock.performLocked {
            self.forwardOn(event)
        }
    }

    func synchronizedForwardOnAndDispose(_ event: Event<Observer.Element>) {
        lock.performLocked {
            self.terminating = true
        }

        // The disposed flag has to be set before `forwardLock` is released: it is what makes
        // `forwardOn` drop an event from a thread that passed the `terminating` check and is
        // parked on `forwardLock`. The teardown itself calls out to user code, so it runs after.
        forwardLock.performLocked {
            self.forwardOn(event)
            self.markDisposed()
        }

        dispose()
    }
}

private final class MergeLimited<SourceSequence: ObservableConvertibleType>: Producer<SourceSequence.Element> {
    private let source: Observable<SourceSequence>
    private let maxConcurrent: Int

    init(source: Observable<SourceSequence>, maxConcurrent: Int) {
        self.source = source
        self.maxConcurrent = maxConcurrent
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == SourceSequence.Element {
        let sink = MergeLimitedBasicSink<SourceSequence, Observer>(maxConcurrent: maxConcurrent, observer: observer, cancel: cancel)
        let subscription = sink.run(source)
        return (sink: sink, subscription: subscription)
    }
}

// MARK: Merge

private final class MergeBasicSink<Source: ObservableConvertibleType, Observer: ObserverType>: MergeSink<Source, Source, Observer> where Observer.Element == Source.Element {
    override func performMap(_ element: Source) throws -> Source {
        element
    }
}

// MARK: flatMap

private final class FlatMapSink<SourceElement, SourceSequence: ObservableConvertibleType, Observer: ObserverType>: MergeSink<SourceElement, SourceSequence, Observer> where Observer.Element == SourceSequence.Element {
    typealias Selector = (SourceElement) throws -> SourceSequence

    private let selector: Selector

    init(selector: @escaping Selector, observer: Observer, cancel: Cancelable) {
        self.selector = selector
        super.init(observer: observer, cancel: cancel)
    }

    override func performMap(_ element: SourceElement) throws -> SourceSequence {
        try selector(element)
    }
}

// MARK: FlatMapFirst

private final class FlatMapFirstSink<SourceElement, SourceSequence: ObservableConvertibleType, Observer: ObserverType>: MergeSink<SourceElement, SourceSequence, Observer> where Observer.Element == SourceSequence.Element {
    typealias Selector = (SourceElement) throws -> SourceSequence

    private let selector: Selector

    override var subscribeNext: Bool {
        activeCount == 0
    }

    init(selector: @escaping Selector, observer: Observer, cancel: Cancelable) {
        self.selector = selector
        super.init(observer: observer, cancel: cancel)
    }

    override func performMap(_ element: SourceElement) throws -> SourceSequence {
        try selector(element)
    }
}

private final class MergeSinkIter<SourceElement, SourceSequence: ObservableConvertibleType, Observer: ObserverType>: ObserverType where Observer.Element == SourceSequence.Element {
    typealias Parent = MergeSink<SourceElement, SourceSequence, Observer>
    typealias DisposeKey = CompositeDisposable.DisposeKey
    typealias Element = Observer.Element

    private let parent: Parent
    private let disposeKey: DisposeKey

    init(parent: Parent, disposeKey: DisposeKey) {
        self.parent = parent
        self.disposeKey = disposeKey
    }

    func on(_ event: Event<Element>) {
        switch event {
        case let .next(value):
            parent.synchronizedForwardOn(.next(value))
        case let .error(error):
            parent.synchronizedForwardOnAndDispose(.error(error))
        case .completed:
            let completed = parent.lock.performLocked { () -> Bool in
                self.parent.activeCount -= 1
                return self.parent.shouldComplete
            }

            parent.group.remove(for: disposeKey)

            if completed {
                parent.synchronizedForwardOnAndDispose(.completed)
            }
        }
    }
}

private class MergeSink<SourceElement, SourceSequence: ObservableConvertibleType, Observer: ObserverType>:
    Sink<Observer>,
    ObserverType where Observer.Element == SourceSequence.Element
{
    typealias ResultType = Observer.Element
    typealias Element = SourceElement

    let lock = RecursiveLock()
    let forwardLock = RecursiveLock()

    var subscribeNext: Bool {
        true
    }

    // state
    let group = CompositeDisposable()
    let sourceSubscription = SingleAssignmentDisposable()

    var activeCount = 0
    var stopped = false
    var terminating = false

    override init(observer: Observer, cancel: Cancelable) {
        super.init(observer: observer, cancel: cancel)
    }

    func performMap(_: SourceElement) throws -> SourceSequence {
        rxAbstractMethod()
    }

    @inline(__always)
    private final func nextElementArrived(element: SourceElement) -> Result<SourceSequence?, Swift.Error> {
        let subscribe = lock.performLocked { () -> Bool in
            if self.stopped || self.terminating || !self.subscribeNext {
                return false
            }

            self.activeCount += 1
            return true
        }

        if !subscribe {
            return .success(nil)
        }

        do {
            return .success(try self.performMap(element))
        } catch let error {
            let shouldFail = lock.performLocked { () -> Bool in
                self.activeCount -= 1

                return !self.terminating
            }

            if shouldFail {
                return .failure(error)
            }

            return .success(nil)
        }
    }

    func on(_ event: Event<SourceElement>) {
        switch event {
        case let .next(element):
            switch nextElementArrived(element: element) {
            case let .success(.some(value)):
                subscribeInner(value.asObservable())
            case .success(.none):
                break
            case let .failure(error):
                synchronizedForwardOnAndDispose(.error(error))
            }
        case let .error(error):
            synchronizedForwardOnAndDispose(.error(error))
        case .completed:
            let completed = lock.performLocked { () -> Bool in
                self.stopped = true
                return self.shouldComplete
            }

            if completed {
                synchronizedForwardOnAndDispose(.completed)
            } else {
                sourceSubscription.dispose()
            }
        }
    }

    func subscribeInner(_ source: Observable<Observer.Element>) {
        let iterDisposable = SingleAssignmentDisposable()

        let shouldSubscribe = lock.performLocked { () -> Bool in
            if self.terminating {
                self.activeCount -= 1
                return false
            }

            return true
        }

        guard shouldSubscribe else {
            return
        }

        if let disposeKey = group.insert(iterDisposable) {
            let iter = MergeSinkIter(parent: self, disposeKey: disposeKey)
            let subscription = source.subscribe(iter)
            iterDisposable.setDisposable(subscription)
        }
    }

    func run(_ sources: [Observable<Observer.Element>]) -> Disposable {
        lock.performLocked {
            activeCount += sources.count
        }

        for source in sources {
            subscribeInner(source)
        }

        let completed = lock.performLocked { () -> Bool in
            self.stopped = true
            return self.shouldComplete
        }

        if completed {
            synchronizedForwardOnAndDispose(.completed)
        }

        return group
    }

    var shouldComplete: Bool {
        stopped && activeCount == 0 && !terminating
    }

    func synchronizedForwardOn(_ event: Event<Observer.Element>) {
        let shouldForward = lock.performLocked {
            !self.terminating
        }

        guard shouldForward else {
            return
        }

        forwardLock.performLocked {
            self.forwardOn(event)
        }
    }

    func synchronizedForwardOnAndDispose(_ event: Event<Observer.Element>) {
        lock.performLocked {
            self.terminating = true
        }

        // The disposed flag has to be set before `forwardLock` is released: it is what makes
        // `forwardOn` drop an event from a thread that passed the `terminating` check and is
        // parked on `forwardLock`. The teardown itself calls out to user code, so it runs after.
        forwardLock.performLocked {
            self.forwardOn(event)
            self.markDisposed()
        }

        dispose()
    }

    func run(_ source: Observable<SourceElement>) -> Disposable {
        _ = group.insert(sourceSubscription)

        let subscription = source.subscribe(self)
        sourceSubscription.setDisposable(subscription)

        return group
    }
}

// MARK: Producers

private final class FlatMap<SourceElement, SourceSequence: ObservableConvertibleType>: Producer<SourceSequence.Element> {
    typealias Selector = (SourceElement) throws -> SourceSequence

    private let source: Observable<SourceElement>

    private let selector: Selector

    init(source: Observable<SourceElement>, selector: @escaping Selector) {
        self.source = source
        self.selector = selector
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == SourceSequence.Element {
        let sink = FlatMapSink(selector: selector, observer: observer, cancel: cancel)
        let subscription = sink.run(source)
        return (sink: sink, subscription: subscription)
    }
}

private final class FlatMapFirst<SourceElement, SourceSequence: ObservableConvertibleType>: Producer<SourceSequence.Element> {
    typealias Selector = (SourceElement) throws -> SourceSequence

    private let source: Observable<SourceElement>

    private let selector: Selector

    init(source: Observable<SourceElement>, selector: @escaping Selector) {
        self.source = source
        self.selector = selector
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == SourceSequence.Element {
        let sink = FlatMapFirstSink<SourceElement, SourceSequence, Observer>(selector: selector, observer: observer, cancel: cancel)
        let subscription = sink.run(source)
        return (sink: sink, subscription: subscription)
    }
}

final class ConcatMap<SourceElement, SourceSequence: ObservableConvertibleType>: Producer<SourceSequence.Element> {
    typealias Selector = (SourceElement) throws -> SourceSequence

    private let source: Observable<SourceElement>
    private let selector: Selector

    init(source: Observable<SourceElement>, selector: @escaping Selector) {
        self.source = source
        self.selector = selector
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == SourceSequence.Element {
        let sink = ConcatMapSink<SourceElement, SourceSequence, Observer>(selector: selector, observer: observer, cancel: cancel)
        let subscription = sink.run(source)
        return (sink: sink, subscription: subscription)
    }
}

final class Merge<SourceSequence: ObservableConvertibleType>: Producer<SourceSequence.Element> {
    private let source: Observable<SourceSequence>

    init(source: Observable<SourceSequence>) {
        self.source = source
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == SourceSequence.Element {
        let sink = MergeBasicSink<SourceSequence, Observer>(observer: observer, cancel: cancel)
        let subscription = sink.run(source)
        return (sink: sink, subscription: subscription)
    }
}

private final class MergeArray<Element>: Producer<Element> {
    private let sources: [Observable<Element>]

    init(sources: [Observable<Element>]) {
        self.sources = sources
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element {
        let sink = MergeBasicSink<Observable<Element>, Observer>(observer: observer, cancel: cancel)
        let subscription = sink.run(sources)
        return (sink: sink, subscription: subscription)
    }
}
