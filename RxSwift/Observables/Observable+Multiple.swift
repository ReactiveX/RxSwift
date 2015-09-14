//
//  Observable+Multiple.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/12/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// combineLatest

extension CollectionType where Generator.Element : ObservableType {
    
    /**
    Merges the specified observable sequences into one observable sequence by using the selector function whenever any of the observable sequences produces an element.
    
    - parameter resultSelector: Function to invoke whenever any of the sources produces an element.
    - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
    */
    public func combineLatest<R>(resultSelector: [Generator.Element.E] throws -> R) -> Observable<R> {
        return CombineLatestCollectionType(sources: self, resultSelector: resultSelector)
    }
}

// zip

extension CollectionType where Generator.Element : ObservableType {
    
    /**
    Merges the specified observable sequences into one observable sequence by using the selector function whenever all of the observable sequences have produced an element at a corresponding index.
    
    - parameter resultSelector: Function to invoke for each series of elements at corresponding indexes in the sources.
    - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
    */
    public func zip<R>(resultSelector: [Generator.Element.E] throws -> R) -> Observable<R> {
        return ZipCollectionType(sources: self, resultSelector: resultSelector)
    }
}

// switch

extension ObservableType where E : ObservableType {
    
    /**
    Transforms an observable sequence of observable sequences into an observable sequence
    producing values only from the most recent observable sequence.
    
    Each time a new inner observable sequence is received, unsubscribe from the
    previous inner observable sequence.
    
    - returns: The observable sequence that at any point in time produces the elements of the most recent inner observable sequence that has been received.
    */
    
    public func switchLatest() -> Observable<E.E> {
        return Switch(sources: self.asObservable())
    }
}

// concat

extension SequenceType where Generator.Element : ObservableType {
    
    /**
    Concatenates all observable sequences in the given sequence, as long as the previous observable sequence terminated successfully.
    
    - returns: An observable sequence that contains the elements of each given sequence, in sequential order.
    */
    public func concat()
        -> Observable<Generator.Element.E> {
        return Concat(sources: self)
    }
}

extension ObservableType where E : ObservableType {
    
    /**
    Concatenates all inner observable sequences, as long as the previous observable sequence terminated successfully.
    
    - returns: An observable sequence that contains the elements of each observed inner sequence, in sequential order.
    */
    public func concat() -> Observable<E.E> {
        return self.merge(maxConcurrent: 1)
    }
}

// merge

extension ObservableType where E : ObservableType {
    
    /**
    Merges elements from all observable sequences in the given enumerable sequence into a single observable sequence.
    
    - parameter maxConcurrent: Maximum number of inner observable sequences being subscribed to concurrently.
    - returns: The observable sequence that merges the elements of the observable sequences.
    */
    public func merge() -> Observable<E.E> {
        return Merge(sources: self.asObservable(), maxConcurrent: 0)
    }

    /**
    Merges elements from all inner observable sequences into a single observable sequence, limiting the number of concurrent subscriptions to inner sequences.
    
    - returns: The observable sequence that merges the elements of the inner sequences.
    */
    public func merge(maxConcurrent maxConcurrent: Int)
        -> Observable<E.E> {
        return Merge(sources: self.asObservable(), maxConcurrent: maxConcurrent)
    }
}

// catch

extension ObservableType {
    
    /**
    Continues an observable sequence that is terminated by an error with the observable sequence produced by the handler.
    
    - parameter handler: Error handler function, producing another observable sequence.
    - returns: An observable sequence containing the source sequence's elements, followed by the elements produced by the handler's resulting observable sequence in case an error occurred.
    */
    public func catchError(handler: (ErrorType) throws -> Observable<E>)
        -> Observable<E> {
        return Catch(source: self.asObservable(), handler: handler)
    }

    /**
    Continues an observable sequence that is terminated by an error with a single element.
    
    - parameter element: Last element in an observable sequence in case error occurs.
    - returns: An observable sequence containing the source sequence's elements, followed by the `element` in case an error occurred.
    */
    public func catchErrorJustReturn(element: E)
        -> Observable<E> {
        return Catch(source: self.asObservable(), handler: { _ in just(element) })
    }
    
}

extension SequenceType where Generator.Element : ObservableType {
    /**
    Continues an observable sequence that is terminated by an error with the next observable sequence.
    
    - returns: An observable sequence containing elements from consecutive source sequences until a source sequence terminates successfully.
    */
    public func catchError()
        -> Observable<Generator.Element.E> {
        return CatchSequence(sources: self)
    }
}

// takeUntil

extension ObservableType {
    
    /**
    Returns the elements from the source observable sequence until the other observable sequence produces an element.
    
    - parameter other: Observable sequence that terminates propagation of elements of the source sequence.
    - returns: An observable sequence containing the elements of the source sequence up to the point the other sequence interrupted further propagation.
    */
    public func takeUntil<O: ObservableType>(other: O)
        -> Observable<E> {
        return TakeUntil(source: self.asObservable(), other: other.asObservable())
    }
}

// amb

extension ObservableType {
    
    /**
    Propagates the observable sequence that reacts first.
    
    - parameter right: Second observable sequence.
    - returns: An observable sequence that surfaces either of the given sequences, whichever reacted first.
    */
    public func amb<O2: ObservableType where O2.E == E>
        (right: O2)
        -> Observable<E> {
        return Amb(left: self.asObservable(), right: right.asObservable())
    }
}

extension SequenceType where Generator.Element : ObservableType {
    
    /**
    Propagates the observable sequence that reacts first.
    
    - returns: An observable sequence that surfaces any of the given sequences, whichever reacted first.
    */
    public func amb()
        -> Observable<Generator.Element.E> {
        return self.reduce(never()) { a, o in
            return a.amb(o)
        }
    }
}
