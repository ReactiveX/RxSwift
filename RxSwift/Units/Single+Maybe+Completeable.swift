//
//  Single+Maybe+Completeable.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 3/5/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

/// Common functionality of all a push style sequences containing 0 or 1 element.
public struct PrimitiveSequence<Proof, Element> {
    fileprivate let source: Observable<Element>

    fileprivate init(raw: Observable<Element>) {
        self.source = raw
    }
}

public enum SingleProof { }
/// Represents a push style sequence containing 1 element.
public typealias Single<Element> = PrimitiveSequence<SingleProof, Element>

public enum MaybeProof { }
/// Represents a push style sequence containing 0 or 1 element.
public typealias Maybe<Element> = PrimitiveSequence<MaybeProof, Element>

public enum CompleteableProof { }
/// Represents a push style sequence containing 0 elements.
public typealias Completeable = PrimitiveSequence<CompleteableProof, Swift.Never>

public protocol PrimitiveSequenceType {
    associatedtype ProofType
    associatedtype ElementType

    var primitiveSequence: PrimitiveSequence<ProofType, ElementType> { get }
}

extension PrimitiveSequence: PrimitiveSequenceType {
    public typealias ProofType = Proof
    public typealias ElementType = Element

    public var primitiveSequence: PrimitiveSequence<ProofType, ElementType> {
        return self
    }
}

extension PrimitiveSequence: ObservableConvertibleType {
    public typealias E = Element

    /// Converts `self` to `Observable` sequence.
    ///
    /// - returns: Observable sequence that represents `self`.
    public func asObservable() -> Observable<E> {
        return source
    }
}

// <Single>

public enum SingleEvent<Element> {
    /// One and only sequence element is produced. (underlying observable sequence emits: `.next(Element)`, `.completed`)
    case success(Element)

    /// Sequence terminated with an error. (underlying observable sequence emits: `.error(Error)`)
    case error(Swift.Error)
}

extension PrimitiveSequenceType where ProofType == SingleProof {
    public typealias SingleObserver = (SingleEvent<ElementType>) -> ()

    public static func create(subscribe: @escaping (@escaping SingleObserver) -> Disposable) -> PrimitiveSequence<ProofType, ElementType> {
        let source = Observable<ElementType>.create { observer in
            return subscribe { event in
                switch event {
                case .success(let element):
                    observer.on(.next(element))
                    observer.on(.completed)
                case .error(let error):
                    observer.on(.error(error))
                }
            }
        }

        return PrimitiveSequence(raw: source)
    }

    public func subscribe(_ observer: @escaping (SingleEvent<ElementType>) -> ()) -> Disposable {
        var stopped = false
        return self.primitiveSequence.asObservable().subscribe { event in
            guard !stopped else { return }
            stopped = true

            switch event {
            case .next(let element):
                observer(.success(element))
            case .error(let error):
                observer(.error(error))
            case .completed:
                rxFatalError("SingleProtocol")
            }
        }
    }
}

// </Single>

// <Maybe>

public enum MaybeEvent<Element> {
    /// One and only sequence element is produced. (underlying observable sequence emits: `.next(Element)`, `.completed`)
    case success(Element)

    /// Sequence terminated with an error. (underlying observable sequence emits: `.error(Error)`)
    case error(Swift.Error)

    /// Sequence completed successfully.
    case completed
}

public extension PrimitiveSequenceType where ProofType == MaybeProof {
    public typealias MaybeObserver = (MaybeEvent<ElementType>) -> ()

    public static func create(subscribe: @escaping (@escaping MaybeObserver) -> Disposable) -> PrimitiveSequence<ProofType, ElementType> {
        let source = Observable<ElementType>.create { observer in
            return subscribe { event in
                switch event {
                case .success(let element):
                    observer.on(.next(element))
                    observer.on(.completed)
                case .error(let error):
                    observer.on(.error(error))
                case .completed:
                    observer.on(.completed)
                }
            }
        }

        return PrimitiveSequence(raw: source)
    }

    public func subscribe(_ observer: @escaping (MaybeEvent<ElementType>) -> ()) -> Disposable {
        var stopped = false
        return self.primitiveSequence.asObservable().subscribe { event in
            guard !stopped else { return }
            stopped = true

            switch event {
            case .next(let element):
                observer(.success(element))
            case .error(let error):
                observer(.error(error))
            case .completed:
                observer(.completed)
            }
        }
    }
}

// </Maybe>

// <Completeable>

public enum CompleteableEvent {
    /// Sequence terminated with an error. (underlying observable sequence emits: `.error(Error)`)
    case error(Swift.Error)

    /// Sequence completed successfully.
    case completed
}

public extension PrimitiveSequenceType where ProofType == CompleteableProof, ElementType == Swift.Never {
    public typealias CompleteableObserver = (CompleteableEvent) -> ()

    public static func create(subscribe: @escaping (@escaping CompleteableObserver) -> Disposable) -> PrimitiveSequence<ProofType, ElementType> {
        let source = Observable<ElementType>.create { observer in
            return subscribe { event in
                switch event {
                case .error(let error):
                    observer.on(.error(error))
                case .completed:
                    observer.on(.completed)
                }
            }
        }

        return PrimitiveSequence(raw: source)
    }

    public func subscribe(_ observer: @escaping (CompleteableEvent) -> ()) -> Disposable {
        var stopped = false
        return self.primitiveSequence.asObservable().subscribe { event in
            guard !stopped else { return }
            stopped = true

            switch event {
            case .next:
                rxFatalError("SingleProtocol")
            case .error(let error):
                observer(.error(error))
            case .completed:
                observer(.completed)
            }
        }
    }
}

// </Completeable>

extension PrimitiveSequence {
    /**
     Returns an observable sequence that invokes the specified factory function whenever a new observer subscribes.

     - seealso: [defer operator on reactivex.io](http://reactivex.io/documentation/operators/defer.html)

     - parameter observableFactory: Observable factory function to invoke for each observer that subscribes to the resulting sequence.
     - returns: An observable sequence whose observers trigger an invocation of the given observable factory function.
     */
    public static func deferred(_ observableFactory: @escaping () throws -> PrimitiveSequence<Proof, Element>)
        -> PrimitiveSequence<Proof, Element> {
        return PrimitiveSequence(raw: Observable.deferred {
            try observableFactory().asObservable()
        })
    }

    /**
     Returns an observable sequence that contains a single element.

     - seealso: [just operator on reactivex.io](http://reactivex.io/documentation/operators/just.html)

     - parameter element: Single element in the resulting observable sequence.
     - returns: An observable sequence containing the single specified element.
     */
    public static func just(_ element: Element) -> PrimitiveSequence<Proof, ElementType> {
        return PrimitiveSequence(raw: Observable.just(element))
    }

    /**
     Returns an observable sequence that contains a single element.

     - seealso: [just operator on reactivex.io](http://reactivex.io/documentation/operators/just.html)

     - parameter element: Single element in the resulting observable sequence.
     - parameter: Scheduler to send the single element on.
     - returns: An observable sequence containing the single specified element.
     */
    public static func just(_ element: Element, scheduler: ImmediateSchedulerType) -> PrimitiveSequence<Proof, ElementType> {
        return PrimitiveSequence(raw: Observable.just(element, scheduler: scheduler))
    }

    /**
     Returns an observable sequence that terminates with an `error`.

     - seealso: [throw operator on reactivex.io](http://reactivex.io/documentation/operators/empty-never-throw.html)

     - returns: The observable sequence that terminates with specified error.
     */
    public static func error(_ error: Swift.Error) -> PrimitiveSequence<Proof, Element> {
        return PrimitiveSequence(raw: Observable.error(error))
    }


    /**
     Returns a non-terminating observable sequence, which can be used to denote an infinite duration.

     - seealso: [never operator on reactivex.io](http://reactivex.io/documentation/operators/empty-never-throw.html)

     - returns: An observable sequence whose observers will never get called.
     */
    public static func never() -> PrimitiveSequence<Proof, Element> {
        return PrimitiveSequence(raw: Observable.never())
    }

    /**
     Time shifts the observable sequence by delaying the subscription with the specified relative time duration, using the specified scheduler to run timers.

     - seealso: [delay operator on reactivex.io](http://reactivex.io/documentation/operators/delay.html)

     - parameter dueTime: Relative time shift of the subscription.
     - parameter scheduler: Scheduler to run the subscription delay timer on.
     - returns: Time-shifted sequence.
     */
    public func delaySubscription(_ dueTime: RxTimeInterval, scheduler: SchedulerType)
        -> PrimitiveSequence<Proof, Element> {
        return PrimitiveSequence(raw: source.delaySubscription(dueTime, scheduler: scheduler))
    }

    /**
     Returns an observable sequence by the source observable sequence shifted forward in time by a specified delay. Error events from the source observable sequence are not delayed.

     - seealso: [delay operator on reactivex.io](http://reactivex.io/documentation/operators/delay.html)

     - parameter dueTime: Relative time shift of the source by.
     - parameter scheduler: Scheduler to run the subscription delay timer on.
     - returns: the source Observable shifted in time by the specified delay.
     */
    public func delay(_ dueTime: RxTimeInterval, scheduler: SchedulerType)
        -> PrimitiveSequence<Proof, Element> {
        return PrimitiveSequence(raw: source.delay(dueTime, scheduler: scheduler))
    }

    /**
     Invokes an action for each event in the observable sequence, and propagates all observer messages through the result sequence.

     - seealso: [do operator on reactivex.io](http://reactivex.io/documentation/operators/do.html)

     - parameter onNext: Action to invoke for each element in the observable sequence.
     - parameter onError: Action to invoke upon errored termination of the observable sequence.
     - parameter onCompleted: Action to invoke upon graceful termination of the observable sequence.
     - parameter onSubscribe: Action to invoke before subscribing to source observable sequence.
     - parameter onSubscribed: Action to invoke after subscribing to source observable sequence.
     - parameter onDispose: Action to invoke after subscription to source observable has been disposed for any reason. It can be either because sequence terminates for some reason or observer subscription being disposed.
     - returns: The source sequence with the side-effecting behavior applied.
     */
    public func `do`(onNext: ((E) throws -> Void)? = nil, onError: ((Swift.Error) throws -> Void)? = nil, onCompleted: (() throws -> Void)? = nil, onSubscribe: (() -> ())? = nil, onSubscribed: (() -> ())? = nil, onDispose: (() -> ())? = nil)
        -> PrimitiveSequence<Proof, Element> {
            return PrimitiveSequence(raw: source.do(
                onNext: onNext,
                onError: onError,
                onCompleted: onCompleted,
                onSubscribe: onSubscribe,
                onSubscribed: onSubscribed,
                onDispose: onDispose)
            )
    }

    /**
     Filters the elements of an observable sequence based on a predicate.

     - seealso: [filter operator on reactivex.io](http://reactivex.io/documentation/operators/filter.html)

     - parameter predicate: A function to test each source element for a condition.
     - returns: An observable sequence that contains elements from the input sequence that satisfy the condition.
     */
    public func filter(_ predicate: @escaping (E) throws -> Bool)
        -> Maybe<Element> {
        return Maybe(raw: source.filter(predicate))
    }

    /**
     Projects each element of an observable sequence into a new form.

     - seealso: [map operator on reactivex.io](http://reactivex.io/documentation/operators/map.html)

     - parameter transform: A transform function to apply to each source element.
     - returns: An observable sequence whose elements are the result of invoking the transform function on each element of source.

     */
    public func map<R>(_ transform: @escaping (E) throws -> R)
        -> PrimitiveSequence<Proof, R> {
        return PrimitiveSequence<Proof, R>(raw: source.map(transform))
    }

    /**
     Projects each element of an observable sequence to an observable sequence and merges the resulting observable sequences into one observable sequence.

     - seealso: [flatMap operator on reactivex.io](http://reactivex.io/documentation/operators/flatmap.html)

     - parameter selector: A transform function to apply to each element.
     - returns: An observable sequence whose elements are the result of invoking the one-to-many transform function on each element of the input sequence.
     */
    public func flatMap<R>(_ selector: @escaping (ElementType) throws -> PrimitiveSequence<ProofType, R>)
        -> PrimitiveSequence<ProofType, R> {
        return PrimitiveSequence<ProofType, R>(raw: source.flatMap(selector))
    }

    /**
     Wraps the source sequence in order to run its observer callbacks on the specified scheduler.

     This only invokes observer callbacks on a `scheduler`. In case the subscription and/or unsubscription
     actions have side-effects that require to be run on a scheduler, use `subscribeOn`.

     - seealso: [observeOn operator on reactivex.io](http://reactivex.io/documentation/operators/observeon.html)

     - parameter scheduler: Scheduler to notify observers on.
     - returns: The source sequence whose observations happen on the specified scheduler.
     */
    public func observeOn(_ scheduler: ImmediateSchedulerType)
        -> PrimitiveSequence<Proof, Element> {
        return PrimitiveSequence(raw: source.observeOn(scheduler))
    }

    /**
     Continues an observable sequence that is terminated by an error with the observable sequence produced by the handler.

     - seealso: [catch operator on reactivex.io](http://reactivex.io/documentation/operators/catch.html)

     - parameter handler: Error handler function, producing another observable sequence.
     - returns: An observable sequence containing the source sequence's elements, followed by the elements produced by the handler's resulting observable sequence in case an error occurred.
     */
    public func catchError(_ handler: @escaping (Swift.Error) throws -> PrimitiveSequence<Proof, Element>)
        -> PrimitiveSequence<Proof, Element> {
        return PrimitiveSequence<Proof, Element>(raw: source.catchError { try handler($0).asObservable() })
    }

    /**
     Repeats the source observable sequence the specified number of times in case of an error or until it successfully terminates.

     If you encounter an error and want it to retry once, then you must use `retry(2)`

     - seealso: [retry operator on reactivex.io](http://reactivex.io/documentation/operators/retry.html)

     - parameter maxAttemptCount: Maximum number of times to repeat the sequence.
     - returns: An observable sequence producing the elements of the given sequence repeatedly until it terminates successfully.
     */
    public func retry(_ maxAttemptCount: Int)
        -> PrimitiveSequence<Proof, Element> {
        return PrimitiveSequence(raw: source.retry(maxAttemptCount))
    }

    /**
     Repeats the source observable sequence on error when the notifier emits a next value.
     If the source observable errors and the notifier completes, it will complete the source sequence.

     - seealso: [retry operator on reactivex.io](http://reactivex.io/documentation/operators/retry.html)

     - parameter notificationHandler: A handler that is passed an observable sequence of errors raised by the source observable and returns and observable that either continues, completes or errors. This behavior is then applied to the source observable.
     - returns: An observable sequence producing the elements of the given sequence repeatedly until it terminates successfully or is notified to error or complete.
     */
    public func retryWhen<TriggerObservable: ObservableType, Error: Swift.Error>(_ notificationHandler: @escaping (Observable<Error>) -> TriggerObservable)
        -> PrimitiveSequence<Proof, Element> {
        return PrimitiveSequence(raw: source.retryWhen(notificationHandler))
    }

    /**
     Repeats the source observable sequence on error when the notifier emits a next value.
     If the source observable errors and the notifier completes, it will complete the source sequence.

     - seealso: [retry operator on reactivex.io](http://reactivex.io/documentation/operators/retry.html)

     - parameter notificationHandler: A handler that is passed an observable sequence of errors raised by the source observable and returns and observable that either continues, completes or errors. This behavior is then applied to the source observable.
     - returns: An observable sequence producing the elements of the given sequence repeatedly until it terminates successfully or is notified to error or complete.
     */
    public func retryWhen<TriggerObservable: ObservableType>(_ notificationHandler: @escaping (Observable<Swift.Error>) -> TriggerObservable)
        -> PrimitiveSequence<Proof, Element> {
        return PrimitiveSequence(raw: source.retryWhen(notificationHandler))
    }
}

extension PrimitiveSequenceType where ElementType: SignedInteger
{
    /**
     Returns an observable sequence that periodically produces a value after the specified initial relative due time has elapsed, using the specified scheduler to run timers.

     - seealso: [timer operator on reactivex.io](http://reactivex.io/documentation/operators/timer.html)

     - parameter dueTime: Relative time at which to produce the first value.
     - parameter scheduler: Scheduler to run timers on.
     - returns: An observable sequence that produces a value after due time has elapsed and then each period.
     */
    public static func timer(_ dueTime: RxTimeInterval, scheduler: SchedulerType)
        -> PrimitiveSequence<ProofType, ElementType>  {
        return PrimitiveSequence(raw: Observable<ElementType>.timer(dueTime, scheduler: scheduler))
    }
}

// Zip: To be done
