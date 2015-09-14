//
//  Observable+Extensions.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

extension ObservableType {
    /**
    Subscribes an event handler to an observable sequence.
    
    - parameter on: Action to invoke for each event in the observable sequence.
    - returns: Subscription object used to unsubscribe from the observable sequence.
    */
    public func subscribe(on: (event: Event<E>) -> Void)
        -> Disposable {
        let observer = AnonymousObserver { e in
            on(event: e)
        }
        return self.subscribeSafe(observer)
    }

    /**
    Subscribes an element handler, an error handler, a completion handler and disposed handler to an observable sequence.
    
    - parameter next: Action to invoke for each element in the observable sequence.
    - parameter error: Action to invoke upon errored termination of the observable sequence.
    - parameter completed: Action to invoke upon graceful termination of the observable sequence.
    - parameter disposed: Action to invoke upon any type of termination of sequence (if the sequence has
        gracefully completed, errored, or if the generation is cancelled by disposing subscription)
    - returns: Subscription object used to unsubscribe from the observable sequence.
    */
    public func subscribe(next next: ((E) -> Void)? = nil, error: ((ErrorType) -> Void)? = nil, completed: (() -> Void)? = nil, disposed: (() -> Void)? = nil)
        -> Disposable {
        
        let disposable: Disposable
        
        if let disposed = disposed {
            disposable = AnonymousDisposable(disposed)
        }
        else {
            disposable = NopDisposable.instance
        }
            
        let observer = AnonymousObserver<E> { e in
            switch e {
            case .Next(let value):
                next?(value)
            case .Error(let e):
                error?(e)
                disposable.dispose()
            case .Completed:
                completed?()
                disposable.dispose()
            }
        }
        return BinaryDisposable(
            self.subscribeSafe(observer),
            disposable
        )
    }

    /**
    Subscribes an element handler to an observable sequence.
    
    - parameter onNext: Action to invoke for each element in the observable sequence.
    - returns: Subscription object used to unsubscribe from the observable sequence.
    */
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

    /**
    Subscribes an error handler to an observable sequence.
    
    - parameter onRrror: Action to invoke upon errored termination of the observable sequence.
    - returns: Subscription object used to unsubscribe from the observable sequence.
    */
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

    /**
    Subscribes a completion handler to an observable sequence.
    
    - parameter onCompleted: Action to invoke upon graceful termination of the observable sequence.
    - returns: Subscription object used to unsubscribe from the observable sequence.
    */
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
    /**
    All internal subscribe calls go through this method
    */
    func subscribeSafe<O: ObserverType where O.E == E>(observer: O) -> Disposable {
        return self.subscribe(observer)
    }
}