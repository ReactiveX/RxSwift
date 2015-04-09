//
//  Observable+Subscription.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

extension Observable {
    func subscribeSafe(observer: ObserverOf<Element>) -> Result<Disposable> {
        if let observableBase = self as? ObservableBase<Element> {
            return observableBase.subscribe(observer)
        }
        
        var mutableObserver = observer
        
        return self.subscribe(observer) >>! { error in
            return mutableObserver.on(Event<Element>.Error(error)) >>> { DefaultDisposable() }
        }
    }
    
}

public func subscribe<E>
    (on: (event: Event<E>) -> Void)
    (source: Observable<E>) -> Result<Disposable> {
    let observer: ObserverOf<E> = ObserverOf(AnonymousObserver { e in
        on(event: e)
        return SuccessResult
    })
    return source.subscribe(observer)
}

public func subscribeNext<E>
    (onNext: (element: E) -> Void)
    (source: Observable<E>) -> Result<Disposable> {
    let observer: ObserverOf<E> = ObserverOf(AnonymousObserver { e in
        switch e {
        case .Next(let e):
            onNext(element: e.value)
        default:
            break
        }
        return SuccessResult
    })
    return source.subscribe(observer)
}