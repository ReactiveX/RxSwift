//
//  Observable+Extensions.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

extension ObservableType {
    public func subscribe(on: (event: Event<E>) -> Void)
        -> Disposable {
        let observer = AnonymousObserver { e in
            on(event: e)
        }
        return self.subscribeSafe(observer)
    }

    public func subscribe(next next: ((E) -> Void)? = nil, error: ((ErrorType) -> Void)? = nil, completed: (() -> Void)? = nil, disposed: (() -> Void)? = nil)
        -> Disposable {
        let observer = AnonymousObserver<E> { e in
            switch e {
            case .Next(let value):
                next?(value)
            case .Error(let e):
                error?(e)
                disposed?()
            case .Completed:
                completed?()
                disposed?()
            }
        }
        return self.subscribeSafe(observer)
    }

    public func subscribeNext(onNext: (E) -> Void)
        -> Disposable {
        let observer = AnonymousObserver<E> { e in
            switch e {
            case .Next(let value):
                onNext(value)
            default:
                break
            }
        }
        return self.subscribeSafe(observer)
    }

    public func subscribeError(onError: (ErrorType) -> Void)
        -> Disposable {
        let observer = AnonymousObserver<E> { e in
            switch e {
            case .Error(let error):
                onError(error)
            default:
                break
            }
        }
        return self.subscribeSafe(observer)
    }

    public func subscribeCompleted(onCompleted: () -> Void)
        -> Disposable {
        let observer = AnonymousObserver<E> { e in
            switch e {
            case .Completed:
                onCompleted()
            default:
                break
            }
        }
        return self.subscribeSafe(observer)
    }
}

public extension ObservableType {
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
    public func subscribeSafe<O: ObserverType where O.E == E>(observer: O) -> Disposable {
        if let source = self as? Producer<O.E> {
            return source.subscribeRaw(observer, enableSafeguard: false)
        }
            
        if let source = self as? ObservableBase<O.E> {
            return source.subscribe(observer)
        }

        return self.subscribe(observer)
    }
}