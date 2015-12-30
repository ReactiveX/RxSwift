//
//  ObservableType.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 8/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

/**
Represents a push style sequence.
*/
public protocol ObservableType : ObservableConvertibleType {
    /**
    Type of elements in sequence.
    */
    typealias E
    
    /**
    Subscribes `observer` to receive events for this sequence.
    
    ### Grammar
    
    **Next\* (Error | Completed)?**
    
    * sequences can produce zero or more elements so zero or more `Next` events can be sent to `observer`
    * once an `Error` or `Completed` event is sent, the sequence terminates and can't produce any other element
    
    It is possible that events are sent from different threads, but no two events can be sent concurrently to
    `observer`.
    
    ### Resource Management
    
    When sequence sends `Complete` or `Error` event all internal resources that compute sequence elements
    will be freed.
    
    To cancel production of sequence elements and free resources immediatelly, call `dispose` on returned
    subscription.
    
    - returns: Subscription for `observer` that can be used to cancel production of sequence elements and free resources.
    */
    @warn_unused_result(message="http://git.io/rxs.ud")
    func subscribe<O: ObserverType where O.E == E>(observer: O) -> Disposable
   
}

extension ObservableType {
    
    /**
    Default implementation of converting `ObservableType` to `Observable`.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func asObservable() -> Observable<E> {
        return Observable.create(self.subscribe)
    }
}