//
//  Observable+StandardSequenceOperators.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/17/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// filter aka where

extension ObservableType {
    
    /**
    Filters the elements of an observable sequence based on a predicate.
    
    - parameter predicate: A function to test each source element for a condition.
    - returns: An observable sequence that contains elements from the input sequence that satisfy the condition.
    */
    public func filter(predicate: (E) throws -> Bool)
        -> Observable<E> {
        return Filter(source: self.asObservable(), predicate: predicate)
    }
}

// takeWhile

extension ObservableType {
    
    /**
    Returns elements from an observable sequence as long as a specified condition is true.
    
    - parameter predicate: A function to test each element for a condition.
    - returns: An observable sequence that contains the elements from the input sequence that occur before the element at which the test no longer passes.
    */
    public func takeWhile(predicate: (E) -> Bool)
        -> Observable<E> {
        return TakeWhile(source: self.asObservable(), predicate: predicate)
    }

    /**
    Returns elements from an observable sequence as long as a specified condition is true. 
    
    The element's index is used in the logic of the predicate function.
    
    - parameter predicate: A function to test each element for a condition; the second parameter of the function represents the index of the source element.
    - returns: An observable sequence that contains the elements from the input sequence that occur before the element at which the test no longer passes.
    */
    public func takeWhile(predicate: (E, Int) -> Bool)
        -> Observable<E> {
        return TakeWhile(source: self.asObservable(), predicate: predicate)
    }
}

// take

extension ObservableType {
    
    /**
    Returns a specified number of contiguous elements from the start of an observable sequence.
    
    - parameter count: The number of elements to return.
    - returns: An observable sequence that contains the specified number of elements from the start of the input sequence.
    */
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
    
// skip

extension ObservableType {
    
    /**
    Bypasses a specified number of elements in an observable sequence and then returns the remaining elements.
    
    - parameter count: The number of elements to skip before returning the remaining elements.
    - returns: An observable sequence that contains the elements that occur after the specified index in the input sequence.
    */
    public func skip(count: Int)
        -> Observable<E> {
        return SkipCount(source: self.asObservable(), count: count)
    }
}

// map aka select

extension ObservableType {
    
    /**
    Projects each element of an observable sequence into a new form.
    
    - parameter selector: A transform function to apply to each source element.
    - returns: An observable sequence whose elements are the result of invoking the transform function on each element of source.
    */
    public func map<R>(selector: E throws -> R)
        -> Observable<R> {
        return Map(source: self.asObservable(), selector: selector)
    }

    /**
    Projects each element of an observable sequence into a new form by incorporating the element's index.
    
    - parameter selector: A transform function to apply to each source element; the second parameter of the function represents the index of the source element.
    - returns: An observable sequence whose elements are the result of invoking the transform function on each element of source.
    */
    public func mapWithIndex<R>(selector: (E, Int) throws -> R)
        -> Observable<R> {
        return Map(source: self.asObservable(), selector: selector)
    }
}
    
// flatMap

extension ObservableType {

    /**
    Projects each element of an observable sequence to an observable sequence and merges the resulting observable sequences into one observable sequence.
    
    - parameter selector: A transform function to apply to each element.
    - returns: An observable sequence whose elements are the result of invoking the one-to-many transform function on each element of the input sequence.
    */
    public func flatMap<O: ObservableType>(selector: (E) throws -> O)
        -> Observable<O.E> {
        return FlatMap(source: self.asObservable(), selector: selector)
    }

    /**
    Projects each element of an observable sequence to an observable sequence by incorporating the element's index and merges the resulting observable sequences into one observable sequence.
    
    - parameter selector: A transform function to apply to each element; the second parameter of the function represents the index of the source element.
    - returns: An observable sequence whose elements are the result of invoking the one-to-many transform function on each element of the input sequence.
    */
    public func flatMapWithIndex<O: ObservableType>(selector: (E, Int) throws -> O)
        -> Observable<O.E> {
        return FlatMap(source: self.asObservable(), selector: selector)
    }
}