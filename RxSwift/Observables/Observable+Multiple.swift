//
//  Observable+Multiple.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/12/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// MARK: combineLatest

extension CollectionType where Generator.Element : ObservableConvertibleType {
    
    /**
    Merges the specified observable sequences into one observable sequence by using the selector function whenever any of the observable sequences produces an element.
    
    - parameter resultSelector: Function to invoke whenever any of the sources produces an element.
    - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func combineLatest<R>(resultSelector: [Generator.Element.E] throws -> R) -> Observable<R> {
        return CombineLatestCollectionType(sources: self, resultSelector: resultSelector)
    }
}

// MARK: zip

extension CollectionType where Generator.Element : ObservableConvertibleType {
    
    /**
    Merges the specified observable sequences into one observable sequence by using the selector function whenever all of the observable sequences have produced an element at a corresponding index.
    
    - parameter resultSelector: Function to invoke for each series of elements at corresponding indexes in the sources.
    - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func zip<R>(resultSelector: [Generator.Element.E] throws -> R) -> Observable<R> {
        return ZipCollectionType(sources: self, resultSelector: resultSelector)
    }
}

// MARK: switch

extension ObservableType where E : ObservableConvertibleType {
    
    /**
    Transforms an observable sequence of observable sequences into an observable sequence
    producing values only from the most recent observable sequence.
    
    Each time a new inner observable sequence is received, unsubscribe from the
    previous inner observable sequence.
    
    - returns: The observable sequence that at any point in time produces the elements of the most recent inner observable sequence that has been received.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func switchLatest() -> Observable<E.E> {
        return Switch(source: asObservable())
    }
}

// MARK: concat

extension ObservableType {

    /**
    Concatenates the second observable sequence to `self` upon successful termination of `self`.
    
    - parameter second: Second observable sequence.
    - returns: An observable sequence that contains the elements of `self`, followed by those of the second sequence.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func concat<O: ObservableConvertibleType where O.E == E>(second: O) -> Observable<E> {
        return [asObservable(), second.asObservable()].concat()
    }
}

extension SequenceType where Generator.Element : ObservableConvertibleType {
    
    /**
    Concatenates all observable sequences in the given sequence, as long as the previous observable sequence terminated successfully.
    
    - returns: An observable sequence that contains the elements of each given sequence, in sequential order.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func concat()
        -> Observable<Generator.Element.E> {
        return Concat(sources: self)
    }
}

extension ObservableType where E : ObservableConvertibleType {
    
    /**
    Concatenates all inner observable sequences, as long as the previous observable sequence terminated successfully.
    
    - returns: An observable sequence that contains the elements of each observed inner sequence, in sequential order.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func concat() -> Observable<E.E> {
        return merge(maxConcurrent: 1)
    }
}

// MARK: merge

extension ObservableType where E : ObservableConvertibleType {
    
    /**
    Merges elements from all observable sequences in the given enumerable sequence into a single observable sequence.
    
    - returns: The observable sequence that merges the elements of the observable sequences.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func merge() -> Observable<E.E> {
        return Merge(source: asObservable())
    }

    /**
    Merges elements from all inner observable sequences into a single observable sequence, limiting the number of concurrent subscriptions to inner sequences.
    
    - parameter maxConcurrent: Maximum number of inner observable sequences being subscribed to concurrently.
    - returns: The observable sequence that merges the elements of the inner sequences.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func merge(maxConcurrent maxConcurrent: Int)
        -> Observable<E.E> {
        return MergeLimited(source: asObservable(), maxConcurrent: maxConcurrent)
    }
}

// MARK: catch

extension ObservableType {
    
    /**
    Continues an observable sequence that is terminated by an error with the observable sequence produced by the handler.
    
    - parameter handler: Error handler function, producing another observable sequence.
    - returns: An observable sequence containing the source sequence's elements, followed by the elements produced by the handler's resulting observable sequence in case an error occurred.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func catchError(handler: (ErrorType) throws -> Observable<E>)
        -> Observable<E> {
        return Catch(source: asObservable(), handler: handler)
    }

    /**
    Continues an observable sequence that is terminated by an error with a single element.
    
    - parameter element: Last element in an observable sequence in case error occurs.
    - returns: An observable sequence containing the source sequence's elements, followed by the `element` in case an error occurred.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func catchErrorJustReturn(element: E)
        -> Observable<E> {
        return Catch(source: asObservable(), handler: { _ in just(element) })
    }
    
}

extension SequenceType where Generator.Element : ObservableConvertibleType {
    /**
    Continues an observable sequence that is terminated by an error with the next observable sequence.
    
    - returns: An observable sequence containing elements from consecutive source sequences until a source sequence terminates successfully.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func catchError()
        -> Observable<Generator.Element.E> {
        return CatchSequence(sources: self)
    }
}

// MARK: takeUntil

extension ObservableType {
    
    /**
    Returns the elements from the source observable sequence until the other observable sequence produces an element.
    
    - parameter other: Observable sequence that terminates propagation of elements of the source sequence.
    - returns: An observable sequence containing the elements of the source sequence up to the point the other sequence interrupted further propagation.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func takeUntil<O: ObservableType>(other: O)
        -> Observable<E> {
        return TakeUntil(source: asObservable(), other: other.asObservable())
    }
}

// MARK: skipUntil

extension ObservableType {
    
    /**
    Returns the elements from the source observable sequence until the other observable sequence produces an element.
    
    - parameter other: Observable sequence that terminates propagation of elements of the source sequence.
    - returns: An observable sequence containing the elements of the source sequence up to the point the other sequence interrupted further propagation.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func skipUntil<O: ObservableType>(other: O)
        -> Observable<E> {
        return SkipUntil(source: asObservable(), other: other.asObservable())
    }
}

// MARK: amb

extension ObservableType {
    
    /**
    Propagates the observable sequence that reacts first.
    
    - parameter right: Second observable sequence.
    - returns: An observable sequence that surfaces either of the given sequences, whichever reacted first.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func amb<O2: ObservableType where O2.E == E>
        (right: O2)
        -> Observable<E> {
        return Amb(left: asObservable(), right: right.asObservable())
    }
}

extension SequenceType where Generator.Element : ObservableConvertibleType {
    
    /**
    Propagates the observable sequence that reacts first.
    
    - returns: An observable sequence that surfaces any of the given sequences, whichever reacted first.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func amb()
        -> Observable<Generator.Element.E> {
        return self.reduce(never()) { a, o in
            return a.amb(o.asObservable())
        }
    }
}

// withLatestFrom

extension ObservableType {
    
    /**
    Merges two observable sequences into one observable sequence by combining each element from self with the latest element from the second source, if any.
     
    - parameter second: Second observable source.
    - parameter resultSelector: Function to invoke for each element from the self combined with the latest element from the second source, if any.
    - returns: An observable sequence containing the result of combining each element of the self  with the latest element from the second source, if any, using the specified result selector function.
    */
    public func withLatestFrom<SecondO: ObservableConvertibleType, ResultType>(second: SecondO, resultSelector: (E, SecondO.E) throws -> ResultType) -> Observable<ResultType> {
        return WithLatestFrom(first: asObservable(), second: second.asObservable(), resultSelector: resultSelector)
    }

    /**
    Merges two observable sequences into one observable sequence by using latest element from the second sequence every time when `self` emitts an element.
     
    - parameter second: Second observable source.
    - returns: An observable sequence containing the result of combining each element of the self  with the latest element from the second source, if any, using the specified result selector function.
    */
    public func withLatestFrom<SecondO: ObservableConvertibleType>(second: SecondO) -> Observable<SecondO.E> {
        return WithLatestFrom(first: asObservable(), second: second.asObservable(), resultSelector: { $1 })
    }
}
