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
    @warn_unused_result(message="http://git.io/rxs.uo")
    func asDriver() -> Driver<E>
}

extension DriverConvertibleType {
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func asObservable() -> Observable<E> {
        return asDriver().asObservable()
    }
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

    `Driver<Element>` can be considered a builder pattern for observable sequences that drive the application.

    To find out more about units and how to use them, please go to `Documentation/Units.md`.
*/
public struct Driver<Element> : DriverConvertibleType {
    public typealias E = Element
    
    let _source: Observable<E>
    
    init(_ source: Observable<E>) {
        self._source = source.shareReplay(1)
    }

    init(raw: Observable<E>) {
        self._source = raw
    }

    #if EXPANDABLE_DRIVER
    public static func createUnsafe<O: ObservableType>(source: O) -> Driver<O.E> {
        return Driver<O.E>(raw: source.asObservable())
    }
    #endif

    /**
    - returns: Built observable sequence.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func asObservable() -> Observable<E> {
        return _source
    }

    /**
    - returns: `self`
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
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
    @warn_unused_result(message="http://git.io/rxs.uo")
    public static func empty<E>() -> Driver<E> {
        return Driver(raw: RxSwift.empty().subscribeOn(ConcurrentMainScheduler.sharedInstance))
    }
    
    /**
    Returns a non-terminating observable sequence, which can be used to denote an infinite duration.
    
    - returns: An observable sequence whose observers will never get called.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public static func never<E>() -> Driver<E> {
        return Driver(raw: RxSwift.never().subscribeOn(ConcurrentMainScheduler.sharedInstance))
    }
    
    /**
    Returns an observable sequence that contains a single element.
    
    - parameter element: Single element in the resulting observable sequence.
    - returns: An observable sequence containing the single specified element.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public static func just<E>(element: E) -> Driver<E> {
        return Driver(raw: RxSwift.just(element).subscribeOn(ConcurrentMainScheduler.sharedInstance))
    }
    
#else
    
    /**
    Returns an empty observable sequence, using the specified scheduler to send out the single `Completed` message.

    - returns: An observable sequence with no elements.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public static func empty<E>() -> Driver<E> {
        return Driver(raw: _empty().subscribeOn(ConcurrentMainScheduler.sharedInstance))
    }
   
    /**
    Returns a non-terminating observable sequence, which can be used to denote an infinite duration.
    
    - returns: An observable sequence whose observers will never get called.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public static func never<E>() -> Driver<E> {
        return Driver(raw: _never().subscribeOn(ConcurrentMainScheduler.sharedInstance))
    }
    
    /**
    Returns an observable sequence that contains a single element.
    
    - parameter element: Single element in the resulting observable sequence.
    - returns: An observable sequence containing the single specified element.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public static func just<E>(element: E) -> Driver<E> {
        return Driver(raw: _just(element).subscribeOn(ConcurrentMainScheduler.sharedInstance))
    }
    
#endif

    @warn_unused_result(message="http://git.io/rxs.uo")
    public static func sequenceOf<E>(elements: E ...) -> Driver<E> {
        let source = elements.toObservable().subscribeOn(ConcurrentMainScheduler.sharedInstance)
        return Driver(raw: source)
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
