//
//  Observable+Extensions.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public func subscribe<E>
    (on: (event: Event<E>) -> Void)
    -> (Observable<E> -> Disposable) {
    return { source in
        let observer = AnonymousObserver { e in
            on(event: e)
        }
        return source.subscribeSafe(observer)
    }
}

public func subscribe<E>
    (#next: (E) -> Void, #error: (ErrorType) -> Void, #completed: () -> Void)
    -> (Observable<E> -> Disposable) {
    return { source in
        let observer = AnonymousObserver<E> { e in
            switch e {
            case .Next(let boxedValue):
                let value = boxedValue.value
                next(value)
            case .Error(let e):
                error(e)
            case .Completed:
                completed()
            }
        }
        return source.subscribeSafe(observer)
    }
}

public func subscribeNext<E>
    (onNext: (E) -> Void)
    -> (Observable<E>) -> Disposable {
    return { source in
        let observer = AnonymousObserver<E> { e in
            switch e {
            case .Next(let boxedValue):
                onNext(boxedValue.value)
            default:
                break
            }
        }
        return source.subscribeSafe(observer)
    }
}

public func subscribeError<E>
    (onError: (ErrorType) -> Void)
    -> (Observable<E> -> Disposable) {
    return { source in
        let observer = AnonymousObserver<E> { e in
            switch e {
            case .Error(let error):
                onError(error)
            default:
                break
            }
        }
        return source.subscribeSafe(observer)
    }
}

public func subscribeCompleted<E>
    (onCompleted: () -> Void)
    -> (Observable<E> -> Disposable) {
    return { source in
        let observer = AnonymousObserver<E> { e in
            switch e {
            case .Completed:
                onCompleted()
            default:
                break
            }
        }
        return source.subscribeSafe(observer)
    }
}

public extension Observable {
    /*
    Observables can really be anything, implemented by anyone and hooked into large `Observable` chains.

    Some of them maybe have flawed implementations that don't respect Rx message grammar.
    
    To guard from rogue `Observable`s and `Observer`s Rx internal classes have safeguards in place.
    Those safeguards will ensure that those rogue `Observables` or `Observers` don't cause 
    havoc in the system.

    Unfortunately, that comes with significant performance penalty. To improve overall performance
    internal Rx classes can drop their safety mechanisms when talking with other known implementations.
    
    `Producers` are special kind of observables that need to make sure that message grammar is respected.
    
    */
    public func subscribeSafe<O: ObserverType where O.Element == Element>(observer: O) -> Disposable {
        if let source = self as? Producer<O.Element> {
            return source.subscribeRaw(observer, enableSafeguard: false)
        }
            
        if let source = self as? ObservableBase<O.Element> {
            return source.subscribe(observer)
        }

        return self.subscribe(observer)
    }
}