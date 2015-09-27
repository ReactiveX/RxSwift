//
//  ObserverType.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

/**
Supports push-style iteration over an observable sequence.
*/
public protocol ObserverType {
    /**
    The type of elements in sequence that observer can observe.
    */
    typealias E

    /**
    Notify observer about sequence event.
    
    - parameter event: Event that occured.
    */
    func on(event: Event<E>)
}

/**
Convienence API extensions to provide alternate next, error, completed events
*/
public extension ObserverType {
    
    /**
    Convienence method equivalent to `on(.Next(element: E))`
    
    - parameter element: Next element to send to observer(s)
    */
    final func onNext(element: E) {
        on(.Next(element))
    }
    
    /**
    Convienence method equivalent to `on(.Completed)`
    */
    final func onComplete() {
        on(.Completed)
    }
    
    /**
    Convienence method equivalent to `on(.Error(error: ErrorType))`
    - parameter error: ErrorType to send to observer(s)
    */
    final func onError(error: ErrorType) {
        on(.Error(error))
    }
}
