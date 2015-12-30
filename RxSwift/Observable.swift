//
//  Observable.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

/**
A type-erased `ObservableType`. 

It represents a push style sequence.
*/
public class Observable<Element> : ObservableType {
    /**
    Type of elements in sequence.
    */
    public typealias E = Element
    
    init() {
#if TRACE_RESOURCES
        OSAtomicIncrement32(&resourceCount)
#endif
    }
    
    public func subscribe<O: ObserverType where O.E == E>(observer: O) -> Disposable {
        abstractMethod()
    }
    
    public func asObservable() -> Observable<E> {
        return self
    }
    
    deinit {
#if TRACE_RESOURCES
        AtomicDecrement(&resourceCount)
#endif
    }

    // this is kind of ugly I know :(
    // Swift compiler reports "Not supported yet" when trying to override protocol extensions, so ¯\_(ツ)_/¯

    /**
    Optimizations for map operator
    */
    internal func composeMap<R>(selector: Element throws -> R) -> Observable<R> {
        return Map(source: self, selector: selector)
    }
}
