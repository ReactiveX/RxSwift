//
//  Merge.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension ObservableType {

    /**
     Projects each element of an observable sequence to an observable sequence and merges the resulting observable sequences into one observable sequence.

     - seealso: [flatMap operator on reactivex.io](http://reactivex.io/documentation/operators/flatmap.html)

     - parameter selector: A transform function to apply to each element.
     - returns: An observable sequence whose elements are the result of invoking the one-to-many transform function on each element of the input sequence.
     */
    public func flatMap<O: ObservableConvertibleType>(_ selector: @escaping (E) throws -> O)
        -> Observable<O.E> {
            return FlatMap(source: asObservable(), selector: selector)
    }

}

extension ObservableType {

    /**
     Projects each element of an observable sequence to an observable sequence and merges the resulting observable sequences into one observable sequence.
     If element is received while there is some projected observable sequence being merged it will simply be ignored.

     - seealso: [flatMapFirst operator on reactivex.io](http://reactivex.io/documentation/operators/flatmap.html)

     - parameter selector: A transform function to apply to element that was observed while no observable is executing in parallel.
     - returns: An observable sequence whose elements are the result of invoking the one-to-many transform function on each element of the input sequence that was received while no other sequence was being calculated.
     */
    public func flatMapFirst<O: ObservableConvertibleType>(_ selector: @escaping (E) throws -> O)
        -> Observable<O.E> {
            return FlatMapFirst(source: asObservable(), selector: selector)
    }
}

extension ObservableType where E : ObservableConvertibleType {

    /**
     Merges elements from all observable sequences in the given enumerable sequence into a single observable sequence.

     - seealso: [merge operator on reactivex.io](http://reactivex.io/documentation/operators/merge.html)

     - returns: The observable sequence that merges the elements of the observable sequences.
     */
    public func merge() -> Observable<E.E> {
        return Merge(source: asObservable())
    }

    /**
     Merges elements from all inner observable sequences into a single observable sequence, limiting the number of concurrent subscriptions to inner sequences.

     - seealso: [merge operator on reactivex.io](http://reactivex.io/documentation/operators/merge.html)

     - parameter maxConcurrent: Maximum number of inner observable sequences being subscribed to concurrently.
     - returns: The observable sequence that merges the elements of the inner sequences.
     */
    public func merge(maxConcurrent: Int)
        -> Observable<E.E> {
        return MergeLimited(source: asObservable(), maxConcurrent: maxConcurrent)
    }
}

extension ObservableType where E : ObservableConvertibleType {

    /**
     Concatenates all inner observable sequences, as long as the previous observable sequence terminated successfully.

     - seealso: [concat operator on reactivex.io](http://reactivex.io/documentation/operators/concat.html)

     - returns: An observable sequence that contains the elements of each observed inner sequence, in sequential order.
     */
    public func concat() -> Observable<E.E> {
        return merge(maxConcurrent: 1)
    }
}

extension ObservableType {
    /**
     Merges elements from all observable sequences from collection into a single observable sequence.

     - seealso: [merge operator on reactivex.io](http://reactivex.io/documentation/operators/merge.html)

     - parameter sources: Collection of observable sequences to merge.
     - returns: The observable sequence that merges the elements of the observable sequences.
     */
    public static func merge<C: Collection>(_ sources: C) -> Observable<E> where C.Iterator.Element == Observable<E> {
        return MergeArray(sources: Array(sources))
    }

    /**
     Merges elements from all observable sequences from array into a single observable sequence.

     - seealso: [merge operator on reactivex.io](http://reactivex.io/documentation/operators/merge.html)

     - parameter sources: Array of observable sequences to merge.
     - returns: The observable sequence that merges the elements of the observable sequences.
     */
    public static func merge(_ sources: [Observable<E>]) -> Observable<E> {
        return MergeArray(sources: sources)
    }

    /**
     Merges elements from all observable sequences into a single observable sequence.

     - seealso: [merge operator on reactivex.io](http://reactivex.io/documentation/operators/merge.html)

     - parameter sources: Collection of observable sequences to merge.
     - returns: The observable sequence that merges the elements of the observable sequences.
     */
    public static func merge(_ sources: Observable<E>...) -> Observable<E> {
        return MergeArray(sources: sources)
    }
}

// MARK: concatMap

extension ObservableType {
    /**
     Projects each element of an observable sequence to an observable sequence and concatenates the resulting observable sequences into one observable sequence.
     
     - seealso: [concat operator on reactivex.io](http://reactivex.io/documentation/operators/concat.html)
     
     - returns: An observable sequence that contains the elements of each observed inner sequence, in sequential order.
     */
    
    public func concatMap<O: ObservableConvertibleType>(_ selector: @escaping (E) throws -> O)
        -> Observable<O.E> {
            return ConcatMap(source: asObservable(), selector: selector)
    }
}

fileprivate final class ConcatMapSink<SourceElement, SourceSequence: ObservableConvertibleType>: MergeLimitedSink<SourceElement, SourceSequence> {
    typealias Selector = (SourceElement) throws -> SourceSequence
    
    private let _selector: Selector
    
    init(selector: @escaping Selector, observer: @escaping (Event<E>) -> (), cancel: Cancelable) {
        _selector = selector
        super.init(maxConcurrent: 1, observer: observer, cancel: cancel)
    }
    
    override func performMap(_ element: SourceElement) throws -> SourceSequence {
        return try _selector(element)
    }
}

fileprivate final class MergeLimitedBasicSink<SourceSequence: ObservableConvertibleType>: MergeLimitedSink<SourceSequence, SourceSequence> {
    
    override func performMap(_ element: SourceSequence) throws -> SourceSequence {
        return element
    }
}

fileprivate class MergeLimitedSink<SourceElement, SourceSequence: ObservableConvertibleType>
    : Sink<SourceSequence.E> {
    typealias QueueType = Queue<SourceSequence>
    typealias E = SourceSequence.E

    let _maxConcurrent: Int

    let _lock = RecursiveLock()

    // state
    var _stopped = false
    var _activeCount = 0
    var _queue = QueueType(capacity: 2)
    
    let _sourceSubscription = SingleAssignmentDisposable()
    let _group = CompositeDisposable()
    
    init(maxConcurrent: Int, observer: @escaping (Event<E>) -> (), cancel: Cancelable) {
        _maxConcurrent = maxConcurrent
        
        let _ = _group.insert(_sourceSubscription)
        super.init(observer: observer, cancel: cancel)
    }
    
    func run(_ source: Observable<SourceElement>) -> Disposable {
        let _ = _group.insert(_sourceSubscription)
        
        let disposable = source.subscribe { event in
            switch event {
            case .next(let element):
                if let sequence = self.nextElementArrived(element: element) {
                    self.subscribe(sequence, group: self._group)
                }
            case .error(let error):
                self._lock.lock(); defer { self._lock.unlock() }

                self.forwardOn(.error(error))
                self.dispose()
            case .completed:
                self._lock.lock(); defer { self._lock.unlock() }

                if self._activeCount == 0 {
                    self.forwardOn(.completed)
                    self.dispose()
                }
                else {
                    self._sourceSubscription.dispose()
                }

                self._stopped = true
            }
        }
        _sourceSubscription.setDisposable(disposable)
        return _group
    }
    
    func subscribe(_ innerSource: SourceSequence, group: CompositeDisposable) {
        let subscription = SingleAssignmentDisposable()
        
        let key = group.insert(subscription)
        
        if let disposeKey = key {
            let disposable = innerSource.asObservable().subscribe { event in
                self._lock.lock(); defer { self._lock.unlock() }
                switch event {
                case .next:
                    self.forwardOn(event)
                case .error:
                    self.forwardOn(event)
                    self.dispose()
                case .completed:
                    self._group.remove(for: disposeKey)
                    if let next = self._queue.dequeue() {
                        self.subscribe(next, group: self._group)
                    }
                    else {
                        self._activeCount = self._activeCount - 1

                        if self._stopped && self._activeCount == 0 {
                            self.forwardOn(.completed)
                            self.dispose()
                        }
                    }
                }
            }
            subscription.setDisposable(disposable)
        }
    }
    
    func performMap(_ element: SourceElement) throws -> SourceSequence {
        rxAbstractMethod()
    }

    @inline(__always)
    final private func nextElementArrived(element: SourceElement) -> SourceSequence? {
        _lock.lock(); defer { _lock.unlock() } // {
            let subscribe: Bool
            if _activeCount < _maxConcurrent {
                _activeCount += 1
                subscribe = true
            }
            else {
                do {
                    let value = try performMap(element)
                    _queue.enqueue(value)
                } catch {
                    forwardOn(.error(error))
                    dispose()
                }
                subscribe = false
            }

            if subscribe {
                do {
                    return try performMap(element)
                } catch {
                    forwardOn(.error(error))
                    dispose()
                }
            }

            return nil
        // }
    }

}

final fileprivate class MergeLimited<SourceSequence: ObservableConvertibleType> : Producer<SourceSequence.E> {
    private let _source: Observable<SourceSequence>
    private let _maxConcurrent: Int
    
    init(source: Observable<SourceSequence>, maxConcurrent: Int) {
        _source = source
        _maxConcurrent = maxConcurrent
    }
    
    override func run(_ observer: @escaping (Event<SourceSequence.E>) -> (), cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) {
        let sink = MergeLimitedBasicSink<SourceSequence>(maxConcurrent: _maxConcurrent, observer: observer, cancel: cancel)
        let subscription = sink.run(_source)
        return (sink: sink, subscription: subscription)
    }
}

// MARK: Merge

fileprivate final class MergeBasicSink<S: ObservableConvertibleType> : MergeSink<S, S> {
    override func performMap(_ element: S) throws -> S {
        return element
    }
}

// MARK: flatMap

fileprivate final class FlatMapSink<SourceElement, SourceSequence: ObservableConvertibleType> : MergeSink<SourceElement, SourceSequence> {
    typealias Selector = (SourceElement) throws -> SourceSequence

    private let _selector: Selector

    init(selector: @escaping Selector, observer: @escaping (Event<SourceSequence.E>) -> (), cancel: Cancelable) {
        _selector = selector
        super.init(observer: observer, cancel: cancel)
    }

    override func performMap(_ element: SourceElement) throws -> SourceSequence {
        return try _selector(element)
    }
}

// MARK: FlatMapFirst

fileprivate final class FlatMapFirstSink<SourceElement, SourceSequence: ObservableConvertibleType> : MergeSink<SourceElement, SourceSequence> {
    typealias Selector = (SourceElement) throws -> SourceSequence

    private let _selector: Selector

    override var subscribeNext: Bool {
        return _activeCount == 0
    }

    init(selector: @escaping Selector, observer: @escaping (Event<SourceSequence.E>) -> (), cancel: Cancelable) {
        _selector = selector
        super.init(observer: observer, cancel: cancel)
    }

    override func performMap(_ element: SourceElement) throws -> SourceSequence {
        return try _selector(element)
    }
}


fileprivate class MergeSink<SourceElement, SourceSequence: ObservableConvertibleType>
    : Sink<SourceSequence.E> {
    typealias ResultType = SourceSequence.E
    typealias Element = SourceElement

    let _lock = RecursiveLock()

    var subscribeNext: Bool {
        return true
    }

    // state
    let _group = CompositeDisposable()
    let _sourceSubscription = SingleAssignmentDisposable()

    var _activeCount = 0
    var _stopped = false

    func performMap(_ element: SourceElement) throws -> SourceSequence {
        rxAbstractMethod()
    }

    @inline(__always)
    final private func nextElementArrived(element: SourceElement) -> SourceSequence? {
        _lock.lock(); defer { _lock.unlock() } // {
            if !subscribeNext {
                return nil
            }

            do {
                let value = try performMap(element)
                _activeCount += 1
                return value
            }
            catch let e {
                forwardOn(.error(e))
                dispose()
                return nil
            }
        // }
    }

    func subscribeInner(_ source: Observable<SourceSequence.E>) {
        let iterDisposable = SingleAssignmentDisposable()
        if let disposeKey = _group.insert(iterDisposable) {
            let subscription = source.subscribe { event in
                self._lock.lock(); defer { self._lock.unlock() } // lock {
                switch event {
                case .next(let value):
                    self.forwardOn(.next(value))
                case .error(let error):
                    self.forwardOn(.error(error))
                    self.dispose()
                case .completed:
                    self._group.remove(for: disposeKey)
                    self._activeCount -= 1
                    self.checkCompleted()
                }
                // }
            }
            iterDisposable.setDisposable(subscription)
        }
    }

    func run(_ sources: [Observable<SourceSequence.E>]) -> Disposable {
        _activeCount += sources.count

        for source in sources {
            subscribeInner(source)
        }

        _stopped = true

        checkCompleted()

        return _group
    }

    @inline(__always)
    func checkCompleted() {
        if _stopped && _activeCount == 0 {
            self.forwardOn(.completed)
            self.dispose()
        }
    }
    
    func run(_ source: Observable<SourceElement>) -> Disposable {
        let _ = _group.insert(_sourceSubscription)

        let subscription = source.subscribe { event in
            switch event {
            case .next(let element):
                if let value = self.nextElementArrived(element: element) {
                    self.subscribeInner(value.asObservable())
                }
            case .error(let error):
                self._lock.lock(); defer { self._lock.unlock() }
                self.forwardOn(.error(error))
                self.dispose()
            case .completed:
                self._lock.lock(); defer { self._lock.unlock() }
                self._stopped = true
                self._sourceSubscription.dispose()
                self.checkCompleted()
            }
        }
        _sourceSubscription.setDisposable(subscription)
        
        return _group
    }
}

// MARK: Producers

final fileprivate class FlatMap<SourceElement, SourceSequence: ObservableConvertibleType>: Producer<SourceSequence.E> {
    typealias Selector = (SourceElement) throws -> SourceSequence

    private let _source: Observable<SourceElement>
    
    private let _selector: Selector

    init(source: Observable<SourceElement>, selector: @escaping Selector) {
        _source = source
        _selector = selector
    }
    
    override func run(_ observer: @escaping (Event<SourceSequence.E>) -> (), cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) {
        let sink = FlatMapSink(selector: _selector, observer: observer, cancel: cancel)
        let subscription = sink.run(_source)
        return (sink: sink, subscription: subscription)
    }
}

final fileprivate class FlatMapFirst<SourceElement, SourceSequence: ObservableConvertibleType>: Producer<SourceSequence.E> {
    typealias Selector = (SourceElement) throws -> SourceSequence

    private let _source: Observable<SourceElement>

    private let _selector: Selector

    init(source: Observable<SourceElement>, selector: @escaping Selector) {
        _source = source
        _selector = selector
    }

    override func run(_ observer: @escaping (Event<SourceSequence.E>) -> (), cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) {
        let sink = FlatMapFirstSink<SourceElement, SourceSequence>(selector: _selector, observer: observer, cancel: cancel)
        let subscription = sink.run(_source)
        return (sink: sink, subscription: subscription)
    }
}

final class ConcatMap<SourceElement, SourceSequence: ObservableConvertibleType>: Producer<SourceSequence.E> {
    typealias Selector = (SourceElement) throws -> SourceSequence
    
    private let _source: Observable<SourceElement>
    private let _selector: Selector
    
    init(source: Observable<SourceElement>, selector: @escaping Selector) {
        _source = source
        _selector = selector
    }
    
    override func run(_ observer: @escaping (Event<SourceSequence.E>) -> (), cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) {
        let sink = ConcatMapSink<SourceElement, SourceSequence>(selector: _selector, observer: observer, cancel: cancel)
        let subscription = sink.run(_source)
        return (sink: sink, subscription: subscription)
    }
}

final class Merge<SourceSequence: ObservableConvertibleType> : Producer<SourceSequence.E> {
    private let _source: Observable<SourceSequence>

    init(source: Observable<SourceSequence>) {
        _source = source
    }
    
    override func run(_ observer: @escaping (Event<SourceSequence.E>) -> (), cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) {
        let sink = MergeBasicSink<SourceSequence>(observer: observer, cancel: cancel)
        let subscription = sink.run(_source)
        return (sink: sink, subscription: subscription)
    }
}

final fileprivate class MergeArray<Element> : Producer<Element> {
    private let _sources: [Observable<Element>]

    init(sources: [Observable<Element>]) {
        _sources = sources
    }

    override func run(_ observer: @escaping (Event<Element>) -> (), cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) {
        let sink = MergeBasicSink<Observable<E>>(observer: observer, cancel: cancel)
        let subscription = sink.run(_sources)
        return (sink: sink, subscription: subscription)
    }
}
