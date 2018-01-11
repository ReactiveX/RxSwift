//
//  Single.swift
//  RxSwift
//
//  Created by sergdort on 19/08/2017.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

#if DEBUG
import Foundation
#endif

/// Sequence containing exactly 1 element
public enum SingleTrait { }
/// Represents a push style sequence containing 1 element.
public typealias Single<Element> = PrimitiveSequence<SingleTrait, Element>

public enum SingleEvent<Element> {
    /// One and only sequence element is produced. (underlying observable sequence emits: `.next(Element)`, `.completed`)
    case success(Element)
    
    /// Sequence terminated with an error. (underlying observable sequence emits: `.error(Error)`)
    case error(Swift.Error)
}

extension PrimitiveSequenceType where TraitType == SingleTrait {
    public typealias SingleObserver = (SingleEvent<ElementType>) -> ()
    
    /**
     Creates an observable sequence from a specified subscribe method implementation.
     
     - seealso: [create operator on reactivex.io](http://reactivex.io/documentation/operators/create.html)
     
     - parameter subscribe: Implementation of the resulting observable sequence's `subscribe` method.
     - returns: The observable sequence with the specified implementation for the `subscribe` method.
     */
    public static func create(subscribe: @escaping (@escaping SingleObserver) -> Disposable) -> Single<ElementType> {
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
    
    
    /**
     Subscribes `observer` to receive events for this sequence.
     
     - returns: Subscription for `observer` that can be used to cancel production of sequence elements and free resources.
     */
    public func subscribe(_ observer: @escaping (SingleEvent<ElementType>) -> ()) -> Disposable {
        var stopped = false
        return self.primitiveSequence.asObservable().subscribe { event in
            if stopped { return }
            stopped = true
            
            switch event {
            case .next(let element):
                observer(.success(element))
            case .error(let error):
                observer(.error(error))
            case .completed:
                rxFatalErrorInDebug("Singles can't emit a completion event")
            }
        }
    }
    
    /**
     Subscribes a success handler, and an error handler for this sequence.
     
     - parameter onSuccess: Action to invoke for each element in the observable sequence.
     - parameter onError: Action to invoke upon errored termination of the observable sequence.
     - returns: Subscription object used to unsubscribe from the observable sequence.
     */
    public func subscribe(onSuccess: ((ElementType) -> Void)? = nil, onError: ((Swift.Error) -> Void)? = nil) -> Disposable {
        #if DEBUG
             let callStack = Hooks.recordCallStackOnError ? Thread.callStackSymbols : []
        #else
            let callStack = [String]()
        #endif
    
        return self.primitiveSequence.subscribe { event in
            switch event {
            case .success(let element):
                onSuccess?(element)
            case .error(let error):
                if let onError = onError {
                    onError(error)
                } else {
                    Hooks.defaultErrorHandler(callStack, error)
                }
            }
        }
    }
}

extension PrimitiveSequenceType where TraitType == SingleTrait {
    /**
     Returns an observable sequence that contains a single element.
     
     - seealso: [just operator on reactivex.io](http://reactivex.io/documentation/operators/just.html)
     
     - parameter element: Single element in the resulting observable sequence.
     - returns: An observable sequence containing the single specified element.
     */
    public static func just(_ element: ElementType) -> Single<ElementType> {
        return Single(raw: Observable.just(element))
    }
    
    /**
     Returns an observable sequence that contains a single element.
     
     - seealso: [just operator on reactivex.io](http://reactivex.io/documentation/operators/just.html)
     
     - parameter element: Single element in the resulting observable sequence.
     - parameter: Scheduler to send the single element on.
     - returns: An observable sequence containing the single specified element.
     */
    public static func just(_ element: ElementType, scheduler: ImmediateSchedulerType) -> Single<ElementType> {
        return Single(raw: Observable.just(element, scheduler: scheduler))
    }

    /**
     Returns an observable sequence that terminates with an `error`.

     - seealso: [throw operator on reactivex.io](http://reactivex.io/documentation/operators/empty-never-throw.html)

     - returns: The observable sequence that terminates with specified error.
     */
    public static func error(_ error: Swift.Error) -> Single<ElementType> {
        return PrimitiveSequence(raw: Observable.error(error))
    }

    /**
     Returns a non-terminating observable sequence, which can be used to denote an infinite duration.

     - seealso: [never operator on reactivex.io](http://reactivex.io/documentation/operators/empty-never-throw.html)

     - returns: An observable sequence whose observers will never get called.
     */
    public static func never() -> Single<ElementType> {
        return PrimitiveSequence(raw: Observable.never())
    }
}

extension PrimitiveSequenceType where TraitType == SingleTrait {

    /**
     Invokes an action for each event in the observable sequence, and propagates all observer messages through the result sequence.

     - seealso: [do operator on reactivex.io](http://reactivex.io/documentation/operators/do.html)

     - parameter onSuccess: Action to invoke for each element in the observable sequence.
     - parameter onError: Action to invoke upon errored termination of the observable sequence.
     - parameter onSubscribe: Action to invoke before subscribing to source observable sequence.
     - parameter onSubscribed: Action to invoke after subscribing to source observable sequence.
     - parameter onDispose: Action to invoke after subscription to source observable has been disposed for any reason. It can be either because sequence terminates for some reason or observer subscription being disposed.
     - returns: The source sequence with the side-effecting behavior applied.
     */
    public func `do`(onSuccess: ((ElementType) throws -> Void)? = nil,
                     onError: ((Swift.Error) throws -> Void)? = nil,
                     onSubscribe: (() -> ())? = nil,
                     onSubscribed: (() -> ())? = nil,
                     onDispose: (() -> ())? = nil)
        -> Single<ElementType> {
            return Single(raw: primitiveSequence.source.do(
                onNext: onSuccess,
                onError: onError,
                onSubscribe: onSubscribe,
                onSubscribed: onSubscribed,
                onDispose: onDispose)
            )
    }

    /**
     Invokes an action for each event in the observable sequence, and propagates all observer messages through the result sequence.
     
     - seealso: [do operator on reactivex.io](http://reactivex.io/documentation/operators/do.html)
     
     - parameter onNext: Action to invoke for each element in the observable sequence.
     - parameter onError: Action to invoke upon errored termination of the observable sequence.
     - parameter onSubscribe: Action to invoke before subscribing to source observable sequence.
     - parameter onSubscribed: Action to invoke after subscribing to source observable sequence.
     - parameter onDispose: Action to invoke after subscription to source observable has been disposed for any reason. It can be either because sequence terminates for some reason or observer subscription being disposed.
     - returns: The source sequence with the side-effecting behavior applied.
     */
    @available(*, deprecated, message: "Use do(onSuccess:onError:onSubscribe:onSubcribed:onDispose:) instead", renamed: "do(onSuccess:onError:onSubscribe:onSubcribed:onDispose:)")
    public func `do`(onNext: ((ElementType) throws -> Void)?,
                     onError: ((Swift.Error) throws -> Void)? = nil,
                     onSubscribe: (() -> ())? = nil,
                     onSubscribed: (() -> ())? = nil,
                     onDispose: (() -> ())? = nil)
        -> Single<ElementType> {
            return `do`(
                onSuccess: onNext,
                onError: onError,
                onSubscribe: onSubscribe,
                onSubscribed: onSubscribed,
                onDispose: onDispose
            )
    }
    
    /**
     Filters the elements of an observable sequence based on a predicate.
     
     - seealso: [filter operator on reactivex.io](http://reactivex.io/documentation/operators/filter.html)
     
     - parameter predicate: A function to test each source element for a condition.
     - returns: An observable sequence that contains elements from the input sequence that satisfy the condition.
     */
    public func filter(_ predicate: @escaping (ElementType) throws -> Bool)
        -> Maybe<ElementType> {
            return Maybe(raw: primitiveSequence.source.filter(predicate))
    }
    
    
    /**
     Projects each element of an observable sequence into a new form.
     
     - seealso: [map operator on reactivex.io](http://reactivex.io/documentation/operators/map.html)
     
     - parameter transform: A transform function to apply to each source element.
     - returns: An observable sequence whose elements are the result of invoking the transform function on each element of source.
     
     */
    public func map<R>(_ transform: @escaping (ElementType) throws -> R)
        -> Single<R> {
            return Single(raw: primitiveSequence.source.map(transform))
    }
    
    /**
     Projects each element of an observable sequence to an observable sequence and merges the resulting observable sequences into one observable sequence.
     
     - seealso: [flatMap operator on reactivex.io](http://reactivex.io/documentation/operators/flatmap.html)
     
     - parameter selector: A transform function to apply to each element.
     - returns: An observable sequence whose elements are the result of invoking the one-to-many transform function on each element of the input sequence.
     */
    public func flatMap<R>(_ selector: @escaping (ElementType) throws -> Single<R>)
        -> Single<R> {
            return Single<R>(raw: primitiveSequence.source.flatMap(selector))
    }
}
