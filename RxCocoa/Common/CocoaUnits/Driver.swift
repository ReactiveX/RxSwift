//
//  Driver.swift
//  Rx
//
//  Created by Krunoslav Zaher on 8/27/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif

/**
A type that can be converted to `Driver`.
*/
public protocol DriverConvertibleType : ObservableConvertibleType {
    
    /**
    Converts self to `Driver`.
    */
    func asDriver() -> Driver<E>
}

/**
    Unit that represents observable sequence with following properties:

    - it never fails
    - it delivers events on `MainScheduler.sharedInstance`
    - `shareReplay(1)` behavior
        - all observers share sequence computation resources
        - it's stateful, upon subscription (calling subscribe) last element is immediatelly replayed if it was produced
        - computation of elements is reference counted with respect to the number of observers
        - if there are no subscribers, it will release sequence computation resources
    - it uses lockless versions of optimized operators (main dispatch queue is used as shared lock)

    `Driver<Element>` can be considered a builder pattern for observable sequences that drive the application.

    To find out more about units and how to use them, please go to `Documentation/Units.md`.
*/
public struct Driver<Element> : DriverConvertibleType {
    public typealias E = Element
    
    let _source: Observable<E>
    
    init(_ source: Observable<E>) {
        self._source = source.shareReplay(1)
    }
    
    #if EXPANDABLE_DRIVER
    public static func createUnsafe<O: ObservableType>(source: O) -> Driver<O.E> {
        return Driver<O.E>(source.asObservable())
    }
    #endif
    
    public func asObservable() -> Observable<E> {
        return _source.subscribeOn(MainScheduler.sharedInstance)
    }
    
    public func asDriver() -> Driver<E> {
        return self
    }
}

public struct Drive {
    
#if !RX_NO_MODULE
    
    /**
    Returns an empty observable sequence, using the specified scheduler to send out the single `Completed` message.
    
    - returns: An observable sequence with no elements.
    */
    public static func empty<E>() -> Driver<E> {
        return Driver(RxSwift.empty())
    }
    
    /**
    Returns a non-terminating observable sequence, which can be used to denote an infinite duration.
    
    - returns: An observable sequence whose observers will never get called.
    */
    public static func never<E>() -> Driver<E> {
        return Driver(RxSwift.never())
    }
    
    /**
    Returns an observable sequence that contains a single element.
    
    - parameter element: Single element in the resulting observable sequence.
    - returns: An observable sequence containing the single specified element.
    */
    public static func just<E>(element: E) -> Driver<E> {
        return Driver(RxSwift.just(element))
    }
    
#else
    
    /**
    Returns an empty observable sequence, using the specified scheduler to send out the single `Completed` message.
    
    - returns: An observable sequence with no elements.
    */
    public static func empty<E>() -> Driver<E> {
        return Driver(_empty())
    }
   
    /**
    Returns a non-terminating observable sequence, which can be used to denote an infinite duration.
    
    - returns: An observable sequence whose observers will never get called.
    */
    public static func never<E>() -> Driver<E> {
        return Driver(_never())
    }
    
    /**
    Returns an observable sequence that contains a single element.
    
    - parameter element: Single element in the resulting observable sequence.
    - returns: An observable sequence containing the single specified element.
    */
    public static func just<E>(element: E) -> Driver<E> {
        return Driver(_just(element))
    }
    
#endif
    
    public static func sequenceOf<E>(elements: E ...) -> Driver<E> {
        let source = elements.asObservable()
        return Driver(source)
    }
    
}

// name clashes :(
    
#if RX_NO_MODULE

func _empty<E>() -> Observable<E> {
    return empty()
}

func _never<E>() -> Observable<E> {
    return never()
}

func _just<E>(element: E) -> Observable<E> {
    return just(element)
}
    
#endif
