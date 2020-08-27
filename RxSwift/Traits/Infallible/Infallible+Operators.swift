//
//  Infallible+Operators.swift
//  RxSwift
//
//  Created by Shai Mishali on 27/08/2020.
//  Copyright © 2020 Krunoslav Zaher. All rights reserved.
//

// MARK: - Filter
extension Infallible {
    /**
     Filters the elements of an observable sequence based on a predicate.

     - seealso: [filter operator on reactivex.io](http://reactivex.io/documentation/operators/filter.html)

     - parameter predicate: A function to test each source element for a condition.
     - returns: An observable sequence that contains elements from the input sequence that satisfy the condition.
     */
    public func filter(_ predicate: @escaping (Element) -> Bool)
        -> Infallible<Element> {
        Infallible(asObservable().filter(predicate))
    }
}

// MARK: - Map
extension InfallibleType {
    /**
     Projects each element of an observable sequence into a new form.

     - seealso: [map operator on reactivex.io](http://reactivex.io/documentation/operators/map.html)

     - parameter transform: A transform function to apply to each source element.
     - returns: An observable sequence whose elements are the result of invoking the transform function on each element of source.

     */
    public func map<Result>(_ transform: @escaping (Element) -> Result)
        -> Infallible<Result> {
        Infallible(asObservable().map(transform))
    }

    /**
     Projects each element of an observable sequence into an optional form and filters all optional results.

     - parameter transform: A transform function to apply to each source element and which returns an element or nil.
     - returns: An observable sequence whose elements are the result of filtering the transform function for each element of the source.

     */
    public func compactMap<Result>(_ transform: @escaping (Element) -> Result?)
        -> Infallible<Result> {
        Infallible(asObservable().compactMap(transform))
    }
}

// MARK: - Throttle
extension Infallible {
    /**
     Ignores elements from an observable sequence which are followed by another element within a specified relative time duration, using the specified scheduler to run throttling timers.

     - seealso: [debounce operator on reactivex.io](http://reactivex.io/documentation/operators/debounce.html)

     - parameter dueTime: Throttling duration for each element.
     - parameter scheduler: Scheduler to run the throttle timers on.
     - returns: The throttled sequence.
     */
    public func debounce(_ dueTime: RxTimeInterval, scheduler: SchedulerType)
        -> Infallible<Element> {
        Infallible(asObservable().debounce(dueTime, scheduler: scheduler))
    }

    /**
     Returns an Observable that emits the first and the latest item emitted by the source Observable during sequential time windows of a specified duration.

     This operator makes sure that no two elements are emitted in less then dueTime.

     - seealso: [debounce operator on reactivex.io](http://reactivex.io/documentation/operators/debounce.html)

     - parameter dueTime: Throttling duration for each element.
     - parameter latest: Should latest element received in a dueTime wide time window since last element emission be emitted.
     - parameter scheduler: Scheduler to run the throttle timers on.
     - returns: The throttled sequence.
     */
    public func throttle(_ dueTime: RxTimeInterval, latest: Bool = true, scheduler: SchedulerType)
        -> Infallible<Element> {
        Infallible(asObservable().throttle(dueTime, latest: latest, scheduler: scheduler))
    }
}

// MARK: - FlatMap
extension InfallibleType {
    /**
     Projects each element of an observable sequence to an observable sequence and merges the resulting observable sequences into one observable sequence.

     - seealso: [flatMap operator on reactivex.io](http://reactivex.io/documentation/operators/flatmap.html)

     - parameter selector: A transform function to apply to each element.
     - returns: An observable sequence whose elements are the result of invoking the one-to-many transform function on each element of the input sequence.
     */
    public func flatMap<Source: ObservableConvertibleType>(_ selector: @escaping (Element) -> Source)
        -> Infallible<Source.Element> {
        Infallible(asObservable().flatMap(selector))
    }

    /**
     Projects each element of an observable sequence into a new sequence of observable sequences and then
     transforms an observable sequence of observable sequences into an observable sequence producing values only from the most recent observable sequence.

     It is a combination of `map` + `switchLatest` operator

     - seealso: [flatMapLatest operator on reactivex.io](http://reactivex.io/documentation/operators/flatmap.html)

     - parameter selector: A transform function to apply to each element.
     - returns: An observable sequence whose elements are the result of invoking the transform function on each element of source producing an
     Observable of Observable sequences and that at any point in time produces the elements of the most recent inner observable sequence that has been received.
     */
    public func flatMapLatest<Source: ObservableConvertibleType>(_ selector: @escaping (Element) -> Source)
        -> Infallible<Source.Element> {
        Infallible(asObservable().flatMapLatest(selector))
    }

    /**
     Projects each element of an observable sequence to an observable sequence and merges the resulting observable sequences into one observable sequence.
     If element is received while there is some projected observable sequence being merged it will simply be ignored.

     - seealso: [flatMapFirst operator on reactivex.io](http://reactivex.io/documentation/operators/flatmap.html)

     - parameter selector: A transform function to apply to element that was observed while no observable is executing in parallel.
     - returns: An observable sequence whose elements are the result of invoking the one-to-many transform function on each element of the input sequence that was received while no other sequence was being calculated.
     */
    public func flatMapFirst<Source: ObservableConvertibleType>(_ selector: @escaping (Element) -> Source)
        -> Infallible<Source.Element> {
        Infallible(asObservable().flatMapFirst(selector))
    }
}

// MARK: - Concat
extension InfallibleType {
    /**
     Concatenates the second observable sequence to `self` upon successful termination of `self`.

     - seealso: [concat operator on reactivex.io](http://reactivex.io/documentation/operators/concat.html)

     - parameter second: Second observable sequence.
     - returns: An observable sequence that contains the elements of `self`, followed by those of the second sequence.
     */
    public func concat<Source: ObservableConvertibleType>(_ second: Source) -> Infallible<Element> where Source.Element == Element {
        Infallible(Observable.concat([self.asObservable(), second.asObservable()]))
    }

    /**
     Concatenates all observable sequences in the given sequence, as long as the previous observable sequence terminated successfully.

     This operator has tail recursive optimizations that will prevent stack overflow.

     Optimizations will be performed in cases equivalent to following:

     [1, [2, [3, .....].concat()].concat].concat()

     - seealso: [concat operator on reactivex.io](http://reactivex.io/documentation/operators/concat.html)

     - returns: An observable sequence that contains the elements of each given sequence, in sequential order.
     */
    public static func concat<Sequence: Swift.Sequence>(_ sequence: Sequence) -> Infallible<Element>
        where Sequence.Element == Infallible<Element> {
        Infallible(Observable.concat(sequence.map { $0.asObservable() }))
    }

    /**
     Concatenates all observable sequences in the given collection, as long as the previous observable sequence terminated successfully.

     This operator has tail recursive optimizations that will prevent stack overflow.

     Optimizations will be performed in cases equivalent to following:

     [1, [2, [3, .....].concat()].concat].concat()

     - seealso: [concat operator on reactivex.io](http://reactivex.io/documentation/operators/concat.html)

     - returns: An observable sequence that contains the elements of each given sequence, in sequential order.
     */
    public static func concat<Collection: Swift.Collection>(_ collection: Collection) -> Infallible<Element>
        where Collection.Element == Infallible<Element> {
        Infallible(Observable.concat(collection.map { $0.asObservable() }))
    }

    /**
     Concatenates all observable sequences in the given collection, as long as the previous observable sequence terminated successfully.

     This operator has tail recursive optimizations that will prevent stack overflow.

     Optimizations will be performed in cases equivalent to following:

     [1, [2, [3, .....].concat()].concat].concat()

     - seealso: [concat operator on reactivex.io](http://reactivex.io/documentation/operators/concat.html)

     - returns: An observable sequence that contains the elements of each given sequence, in sequential order.
     */
    public static func concat(_ sources: Infallible<Element> ...) -> Infallible<Element> {
        Infallible(Observable.concat(sources.map { $0.asObservable() }))
    }

    /**
     Projects each element of an observable sequence to an observable sequence and concatenates the resulting observable sequences into one observable sequence.

     - seealso: [concat operator on reactivex.io](http://reactivex.io/documentation/operators/concat.html)

     - returns: An observable sequence that contains the elements of each observed inner sequence, in sequential order.
     */
    public func concatMap<Source: ObservableConvertibleType>(_ selector: @escaping (Element) -> Source)
        -> Infallible<Source.Element> {
        Infallible(asObservable().concatMap(selector))
    }
}

// MARK: - Merge
extension InfallibleType {
    /**
     Merges elements from all observable sequences from collection into a single observable sequence.

     - seealso: [merge operator on reactivex.io](http://reactivex.io/documentation/operators/merge.html)

     - parameter sources: Collection of observable sequences to merge.
     - returns: The observable sequence that merges the elements of the observable sequences.
     */
    public static func merge<Collection: Swift.Collection>(_ sources: Collection) -> Infallible<Element> where Collection.Element == Infallible<Element> {
        Infallible(Observable.concat(sources.map { $0.asObservable() }))
    }

    /**
     Merges elements from all observable sequences from array into a single observable sequence.

     - seealso: [merge operator on reactivex.io](http://reactivex.io/documentation/operators/merge.html)

     - parameter sources: Array of observable sequences to merge.
     - returns: The observable sequence that merges the elements of the observable sequences.
     */
    public static func merge(_ sources: [Observable<Element>]) -> Infallible<Element> {
        Infallible(Observable.merge(sources.map { $0.asObservable() }))
    }

    /**
     Merges elements from all observable sequences into a single observable sequence.

     - seealso: [merge operator on reactivex.io](http://reactivex.io/documentation/operators/merge.html)

     - parameter sources: Collection of observable sequences to merge.
     - returns: The observable sequence that merges the elements of the observable sequences.
     */
    public static func merge(_ sources: Observable<Element>...) -> Infallible<Element> {
        Infallible(Observable.merge(sources.map { $0.asObservable() }))
    }
}

// MARK: - Scan
extension InfallibleType {
    /**
     Applies an accumulator function over an observable sequence and returns each intermediate result. The specified seed value is used as the initial accumulator value.

     For aggregation behavior with no intermediate results, see `reduce`.

     - seealso: [scan operator on reactivex.io](http://reactivex.io/documentation/operators/scan.html)

     - parameter seed: The initial accumulator value.
     - parameter accumulator: An accumulator function to be invoked on each element.
     - returns: An observable sequence containing the accumulated values.
     */
    public func scan<Seed>(into seed: Seed, accumulator: @escaping (inout Seed, Element) -> Void)
        -> Infallible<Seed> {
        Infallible(asObservable().scan(into: seed, accumulator: accumulator))
    }

    /**
     Applies an accumulator function over an observable sequence and returns each intermediate result. The specified seed value is used as the initial accumulator value.

     For aggregation behavior with no intermediate results, see `reduce`.

     - seealso: [scan operator on reactivex.io](http://reactivex.io/documentation/operators/scan.html)

     - parameter seed: The initial accumulator value.
     - parameter accumulator: An accumulator function to be invoked on each element.
     - returns: An observable sequence containing the accumulated values.
     */
    public func scan<Seed>(_ seed: Seed, accumulator: @escaping (Seed, Element) -> Seed)
        -> Infallible<Seed> {
        Infallible(asObservable().scan(seed, accumulator: accumulator))
    }
}

// MARK: - Share
extension InfallibleType {
    /**
     Returns an observable sequence that **shares a single subscription to the underlying sequence**, and immediately upon subscription replays  elements in buffer.

     This operator is equivalent to:
     * `.whileConnected`
     ```
     // Each connection will have it's own subject instance to store replay events.
     // Connections will be isolated from each another.
     source.multicast(makeSubject: { Replay.create(bufferSize: replay) }).refCount()
     ```
     * `.forever`
     ```
     // One subject will store replay events for all connections to source.
     // Connections won't be isolated from each another.
     source.multicast(Replay.create(bufferSize: replay)).refCount()
     ```

     It uses optimized versions of the operators for most common operations.

     - parameter replay: Maximum element count of the replay buffer.
     - parameter scope: Lifetime scope of sharing subject. For more information see `SubjectLifetimeScope` enum.

     - seealso: [shareReplay operator on reactivex.io](http://reactivex.io/documentation/operators/replay.html)

     - returns: An observable sequence that contains the elements of a sequence produced by multicasting the source sequence.
     */
    public func share(replay: Int = 0, scope: SubjectLifetimeScope = .whileConnected)
        -> Infallible<Element> {
        Infallible(asObservable().share(replay: replay, scope: scope))
    }
}
