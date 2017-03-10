//
//  Observable+StandardSequenceOperators.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/17/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

// MARK: filter aka where

extension ObservableType {
    
    /**
    Filters the elements of an observable sequence based on a predicate.

    - seealso: [filter operator on reactivex.io](http://reactivex.io/documentation/operators/filter.html)
    
    - parameter predicate: A function to test each source element for a condition.
    - returns: An observable sequence that contains elements from the input sequence that satisfy the condition.
    */
    public func filter(_ predicate: @escaping (E) throws -> Bool)
        -> Observable<E> {
        return Filter(source: asObservable(), predicate: predicate)
    }
}

// MARK: takeWhile

extension ObservableType {
    
    /**
    Returns elements from an observable sequence as long as a specified condition is true.
    
    - seealso: [takeWhile operator on reactivex.io](http://reactivex.io/documentation/operators/takewhile.html)

    - parameter predicate: A function to test each element for a condition.
    - returns: An observable sequence that contains the elements from the input sequence that occur before the element at which the test no longer passes.
    */
    public func takeWhile(_ predicate: @escaping (E) throws -> Bool)
        -> Observable<E> {
        return TakeWhile(source: asObservable(), predicate: predicate)
    }

    /**
    Returns elements from an observable sequence as long as a specified condition is true. 
    
    The element's index is used in the logic of the predicate function.
   
    - seealso: [takeWhile operator on reactivex.io](http://reactivex.io/documentation/operators/takewhile.html)

    - parameter predicate: A function to test each element for a condition; the second parameter of the function represents the index of the source element.
    - returns: An observable sequence that contains the elements from the input sequence that occur before the element at which the test no longer passes.
    */
    public func takeWhileWithIndex(_ predicate: @escaping (E, Int) throws -> Bool)
        -> Observable<E> {
        return TakeWhile(source: asObservable(), predicate: predicate)
    }
}

// MARK: take

extension ObservableType {
    
    /**
    Returns a specified number of contiguous elements from the start of an observable sequence.

    - seealso: [take operator on reactivex.io](http://reactivex.io/documentation/operators/take.html)
    
    - parameter count: The number of elements to return.
    - returns: An observable sequence that contains the specified number of elements from the start of the input sequence.
    */
    public func take(_ count: Int)
        -> Observable<E> {
        if count == 0 {
            return Observable.empty()
        }
        else {
            return TakeCount(source: asObservable(), count: count)
        }
    }
}

// MARK: takeLast

extension ObservableType {
    
    /**
    Returns a specified number of contiguous elements from the end of an observable sequence.
     
     This operator accumulates a buffer with a length enough to store elements count elements. Upon completion of the source sequence, this buffer is drained on the result sequence. This causes the elements to be delayed.

     - seealso: [takeLast operator on reactivex.io](http://reactivex.io/documentation/operators/takelast.html)
     
     - parameter count: Number of elements to take from the end of the source sequence.
     - returns: An observable sequence containing the specified number of elements from the end of the source sequence.
     */
    public func takeLast(_ count: Int)
        -> Observable<E> {
        return TakeLast(source: asObservable(), count: count)
    }
}


// MARK: skip

extension ObservableType {
    
    /**
    Bypasses a specified number of elements in an observable sequence and then returns the remaining elements.

    - seealso: [skip operator on reactivex.io](http://reactivex.io/documentation/operators/skip.html)
    
    - parameter count: The number of elements to skip before returning the remaining elements.
    - returns: An observable sequence that contains the elements that occur after the specified index in the input sequence.
    */
    public func skip(_ count: Int)
        -> Observable<E> {
        return SkipCount(source: asObservable(), count: count)
    }
}

// MARK: SkipWhile

extension ObservableType {
   
    /**
    Bypasses elements in an observable sequence as long as a specified condition is true and then returns the remaining elements.

    - seealso: [skipWhile operator on reactivex.io](http://reactivex.io/documentation/operators/skipwhile.html)
    
    - parameter predicate: A function to test each element for a condition.
    - returns: An observable sequence that contains the elements from the input sequence starting at the first element in the linear series that does not pass the test specified by predicate.
    */
    public func skipWhile(_ predicate: @escaping (E) throws -> Bool) -> Observable<E> {
        return SkipWhile(source: asObservable(), predicate: predicate)
    }
   
    /**
    Bypasses elements in an observable sequence as long as a specified condition is true and then returns the remaining elements.
    The element's index is used in the logic of the predicate function.

    - seealso: [skipWhile operator on reactivex.io](http://reactivex.io/documentation/operators/skipwhile.html)
    
    - parameter predicate: A function to test each element for a condition; the second parameter of the function represents the index of the source element.
    - returns: An observable sequence that contains the elements from the input sequence starting at the first element in the linear series that does not pass the test specified by predicate.
    */
    public func skipWhileWithIndex(_ predicate: @escaping (E, Int) throws -> Bool) -> Observable<E> {
        return SkipWhile(source: asObservable(), predicate: predicate)
    }
}

// MARK: map aka select

extension ObservableType {
    
    /**
    Projects each element of an observable sequence into a new form.
    
    - seealso: [map operator on reactivex.io](http://reactivex.io/documentation/operators/map.html)

    - parameter transform: A transform function to apply to each source element.
    - returns: An observable sequence whose elements are the result of invoking the transform function on each element of source.
     
    */
    public func map<R>(_ transform: @escaping (E) throws -> R)
        -> Observable<R> {
        return self.asObservable().composeMap(transform)
    }

    /**
    Projects each element of an observable sequence into a new form by incorporating the element's index.

    - seealso: [map operator on reactivex.io](http://reactivex.io/documentation/operators/map.html)
    
    - parameter selector: A transform function to apply to each source element; the second parameter of the function represents the index of the source element.
    - returns: An observable sequence whose elements are the result of invoking the transform function on each element of source.
    */
    public func mapWithIndex<R>(_ selector: @escaping (E, Int) throws -> R)
        -> Observable<R> {
        return MapWithIndex(source: asObservable(), selector: selector)
    }
}
    
// MARK: flatMap

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

    /**
    Projects each element of an observable sequence to an observable sequence by incorporating the element's index and merges the resulting observable sequences into one observable sequence.

    - seealso: [flatMap operator on reactivex.io](http://reactivex.io/documentation/operators/flatmap.html)

    - parameter selector: A transform function to apply to each element; the second parameter of the function represents the index of the source element.
    - returns: An observable sequence whose elements are the result of invoking the one-to-many transform function on each element of the input sequence.
    */
    public func flatMapWithIndex<O: ObservableConvertibleType>(_ selector: @escaping (E, Int) throws -> O)
        -> Observable<O.E> {
        return FlatMapWithIndex(source: asObservable(), selector: selector)
    }
}

// MARK: flatMapFirst

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

// MARK: flatMapLatest

extension ObservableType {
    /**
     Projects each element of an observable sequence into a new sequence of observable sequences and then
     transforms an observable sequence of observable sequences into an observable sequence producing values only from the most recent observable sequence.
     
     It is a combination of `map` + `switchLatest` operator

     - seealso: [flatMapLatest operator on reactivex.io](http://reactivex.io/documentation/operators/flatmap.html)

     - parameter selector: A transform function to apply to each element.
     - returns: An observable sequence whose elements are the result of invoking the transform function on each element of source producing an 
        Observable of Observable sequences and that at any point in time produces the elements of the most recent inner observable sequence that has been received.
     */
    public func flatMapLatest<O: ObservableConvertibleType>(_ selector: @escaping (E) throws -> O)
        -> Observable<O.E> {
            return FlatMapLatest(source: asObservable(), selector: selector)
    }
}

// MARK: elementAt

extension ObservableType {
    
    /**
    Returns a sequence emitting only item _n_ emitted by an Observable

    - seealso: [elementAt operator on reactivex.io](http://reactivex.io/documentation/operators/elementat.html)
    
    - parameter index: The index of the required item (starting from 0).
    - returns: An observable sequence that emits the desired item as its own sole emission.
    */
    public func elementAt(_ index: Int)
        -> Observable<E> {
        return ElementAt(source: asObservable(), index: index, throwOnEmpty: true)
    }
}

// MARK: single

extension ObservableType {
    
    /**
    The single operator is similar to first, but throws a `RxError.NoElements` or `RxError.MoreThanOneElement`
    if the source Observable does not emit exactly one item before successfully completing.

    - seealso: [single operator on reactivex.io](http://reactivex.io/documentation/operators/first.html)
    
    - returns: An observable sequence that emits a single item or throws an exception if more (or none) of them are emitted.
    */
    public func single()
        -> Observable<E> {
        return SingleAsync(source: asObservable())
    }
    
    /**
    The single operator is similar to first, but throws a `RxError.NoElements` or `RxError.MoreThanOneElement`
    if the source Observable does not emit exactly one item before successfully completing.

    - seealso: [single operator on reactivex.io](http://reactivex.io/documentation/operators/first.html)
    
    - parameter predicate: A function to test each source element for a condition.
    - returns: An observable sequence that emits a single item or throws an exception if more (or none) of them are emitted.
    */
    public func single(_ predicate: @escaping (E) throws -> Bool)
        -> Observable<E> {
        return SingleAsync(source: asObservable(), predicate: predicate)
    }

}

// MARK: groupBy 

extension ObservableType {
    /*
    Groups the elements of an observable sequence according to a specified key selector function.

    - seealso: [groupBy operator on reactivex.io](http://reactivex.io/documentation/operators/groupby.html)
     
    - parameter keySelector: A function to extract the key for each element.
    - returns: A sequence of observable groups, each of which corresponds to a unique key value, containing all elements that share that same key value.
    */
    public func groupBy<K: Hashable>(keySelector: @escaping (E) throws -> K)
        -> Observable<GroupedObservable<K,E>> {
        return GroupBy(source: self.asObservable(), selector: keySelector)
    }
}

//MARK: materialize

extension ObservableType {
    /**
     Convert any Observable into an Observable of its events.
     - seealso: [materialize operator on reactivex.io](http://reactivex.io/documentation/operators/materialize-dematerialize.html)
     - returns: An observable sequence that wraps events in an Event<E>. The returned Observable never errors, but it does complete after observing all of the events of the underlying Observable.
     */
    public func materialize() -> Observable<Event<E>> {
        return Observable.create { observer in
            return self.subscribe { event in
                observer.onNext(event)
                if event.isStopEvent {
                    observer.onCompleted()
                }
            }
        }
    }
}

/**
 A type that expresses convertibility into an RxSwift Event<E>.
 This is used mainly for the implementation of the dematerialize operator.
 */
public protocol EventConvertibleType {
    associatedtype E
    func asEvent() -> Event<E>
}

extension Event : EventConvertibleType {
    public typealias E = Element
    public func asEvent() -> Event<E> { return self }
}

extension ObservableType where E: EventConvertibleType {
    /**
     Convert an Observable<Event<E>> into an Observable<E> of the Event elements.
     - seealso: [materialize operator on reactivex.io](http://reactivex.io/documentation/operators/materialize-dematerialize.html)
     - returns: An observable sequence that unwraps the Events of the underlying observable.
     */
    public func dematerialize() -> Observable<E.E> {
        return Observable.create { observer in
            return self.subscribe(onNext: { event in
                switch event.asEvent() {
                case .next(let element): observer.onNext(element)
                case .error(let error): observer.onError(error)
                case .completed: observer.onCompleted()
                }
            })
        }
    }
    
    /// Return only the error events of an Observable<Event<E>>
    public func errors() -> Observable<Swift.Error> {
        return self.filter { $0.asEvent().error != nil }
            .map { $0.asEvent().error! }
    }
    
    /// Return only the onNext element events of an Observable<Event<E>>
    public func elements() -> Observable<E.E> {
        return self.filter { $0.asEvent().element != nil }
            .map { $0.asEvent().element! }
    }
}
