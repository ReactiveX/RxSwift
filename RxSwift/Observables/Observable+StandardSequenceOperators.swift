//
//  Observable+StandardSequenceOperators.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/17/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// MARK: filter aka where

extension ObservableType {
    
    /**
    Filters the elements of an observable sequence based on a predicate.
    
    - parameter predicate: A function to test each source element for a condition.
    - returns: An observable sequence that contains elements from the input sequence that satisfy the condition.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func filter(predicate: (E) throws -> Bool)
        -> Observable<E> {
        return Filter(source: self.asObservable(), predicate: predicate)
    }
}

// MARK: takeWhile

extension ObservableType {
    
    /**
    Returns elements from an observable sequence as long as a specified condition is true.
    
    - parameter predicate: A function to test each element for a condition.
    - returns: An observable sequence that contains the elements from the input sequence that occur before the element at which the test no longer passes.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func takeWhile(predicate: (E) throws -> Bool)
        -> Observable<E> {
        return TakeWhile(source: asObservable(), predicate: predicate)
    }

    /**
    Returns elements from an observable sequence as long as a specified condition is true. 
    
    The element's index is used in the logic of the predicate function.
    
    - parameter predicate: A function to test each element for a condition; the second parameter of the function represents the index of the source element.
    - returns: An observable sequence that contains the elements from the input sequence that occur before the element at which the test no longer passes.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func takeWhileWithIndex(predicate: (E, Int) throws -> Bool)
        -> Observable<E> {
        return TakeWhile(source: asObservable(), predicate: predicate)
    }
}

// MARK: take

extension ObservableType {
    
    /**
    Returns a specified number of contiguous elements from the start of an observable sequence.
    
    - parameter count: The number of elements to return.
    - returns: An observable sequence that contains the specified number of elements from the start of the input sequence.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func take(count: Int)
        -> Observable<E> {
        if count == 0 {
            return empty()
        }
        else {
            return TakeCount(source: self.asObservable(), count: count)
        }
    }
}

// MARK: takeLast

extension ObservableType {
    
    /**
    Returns a specified number of contiguous elements from the end of an observable sequence.
     
     This operator accumulates a buffer with a length enough to store elements count elements. Upon completion of the source sequence, this buffer is drained on the result sequence. This causes the elements to be delayed.
     
     - parameter count: Number of elements to take from the end of the source sequence.
     - returns: An observable sequence containing the specified number of elements from the end of the source sequence.
     */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func takeLast(count: Int)
        -> Observable<E> {
        return TakeLast(source: self.asObservable(), count: count)
    }
}


// MARK: skip

extension ObservableType {
    
    /**
    Bypasses a specified number of elements in an observable sequence and then returns the remaining elements.
    
    - parameter count: The number of elements to skip before returning the remaining elements.
    - returns: An observable sequence that contains the elements that occur after the specified index in the input sequence.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func skip(count: Int)
        -> Observable<E> {
        return SkipCount(source: self.asObservable(), count: count)
    }
}

// MARK: SkipWhile

extension ObservableType {
   
    /**
    Bypasses elements in an observable sequence as long as a specified condition is true and then returns the remaining elements.
    
    - parameter predicate: A function to test each element for a condition.
    - returns: An observable sequence that contains the elements from the input sequence starting at the first element in the linear series that does not pass the test specified by predicate.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func skipWhile(predicate: (E) throws -> Bool) -> Observable<E> {
        return SkipWhile(source: self.asObservable(), predicate: predicate)
    }
   
    /**
    Bypasses elements in an observable sequence as long as a specified condition is true and then returns the remaining elements.
    The element's index is used in the logic of the predicate function.
    
    - parameter predicate: A function to test each element for a condition; the second parameter of the function represents the index of the source element.
    - returns: An observable sequence that contains the elements from the input sequence starting at the first element in the linear series that does not pass the test specified by predicate.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func skipWhileWithIndex(predicate: (E, Int) throws -> Bool) -> Observable<E> {
        return SkipWhile(source: self.asObservable(), predicate: predicate)
    }
}

// MARK: map aka select

extension ObservableType {
    
    /**
    Projects each element of an observable sequence into a new form.
    
    - parameter selector: A transform function to apply to each source element.
    - returns: An observable sequence whose elements are the result of invoking the transform function on each element of source.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func map<R>(selector: E throws -> R)
        -> Observable<R> {
        return Map(source: self.asObservable(), selector: selector)
    }

    /**
    Projects each element of an observable sequence into a new form by incorporating the element's index.
    
    - parameter selector: A transform function to apply to each source element; the second parameter of the function represents the index of the source element.
    - returns: An observable sequence whose elements are the result of invoking the transform function on each element of source.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func mapWithIndex<R>(selector: (E, Int) throws -> R)
        -> Observable<R> {
        return Map(source: self.asObservable(), selector: selector)
    }
}
    
// MARK: flatMap

extension ObservableType {

    /**
    Projects each element of an observable sequence to an observable sequence and merges the resulting observable sequences into one observable sequence.
    
    - parameter selector: A transform function to apply to each element.
    - returns: An observable sequence whose elements are the result of invoking the one-to-many transform function on each element of the input sequence.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func flatMap<O: ObservableConvertibleType>(selector: (E) throws -> O)
        -> Observable<O.E> {
        return FlatMap(source: self.asObservable(), selector: selector)
    }

    /**
    Projects each element of an observable sequence to an observable sequence by incorporating the element's index and merges the resulting observable sequences into one observable sequence.
    
    - parameter selector: A transform function to apply to each element; the second parameter of the function represents the index of the source element.
    - returns: An observable sequence whose elements are the result of invoking the one-to-many transform function on each element of the input sequence.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func flatMapWithIndex<O: ObservableConvertibleType>(selector: (E, Int) throws -> O)
        -> Observable<O.E> {
        return FlatMap(source: self.asObservable(), selector: selector)
    }
}

// elementAt

extension ObservableType {
    
    /**
    Returns a sequence emitting only item _n_ emitted by an Observable
    
    - parameter index: The index of the required item (starting from 0).
    - returns: An observable sequence that emits the desired item as its own sole emission.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func elementAt(index: Int)
        -> Observable<E> {
            return ElementAt(source: self.asObservable(), index: index, throwOnEmpty: true)
    }
}