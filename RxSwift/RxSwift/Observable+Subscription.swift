//
//  Observable+Subscription.swift
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
        return source.subscribe(observer)
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
        return source.subscribe(observer)
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
        return source.subscribe(observer)
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
        return source.subscribe(observer)
    }
}