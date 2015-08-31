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
    // All internal subscribe calls go through this method
    public func subscribeSafe<O: ObserverType where O.E == E>(observer: O) -> Disposable {
        return self.subscribe(observer)
    }
}