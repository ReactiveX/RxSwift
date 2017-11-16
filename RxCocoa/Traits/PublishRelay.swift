//
//  PublishRelay.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import RxSwift

/// PublishRelay is a wrapper for `PublishSubject`.
///
/// Unlike `PublishSubject` it can't terminate with error or completed.
public final class PublishRelay<Element>: ObservableType {
    public typealias E = Element

    private let _subject: PublishSubject<Element>
    
    // Accepts `event` and emits it to subscribers
    public func accept(_ event: Element) {
        _subject.onNext(event)
    }
    
    /// Initializes variable with initial value.
    public init() {
        _subject = PublishSubject()
    }

    /// Subscribes observer
    public func subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.E == E {
        return _subject.subscribe(observer)
    }
    
    /// - returns: Canonical interface for push style sequence
    public func asObservable() -> Observable<Element> {
        return _subject.asObservable()
    }

    /// Warning: It is assumed this is called on the main thread; since Drivers require that.
    public func asDriver() -> Driver<Element> {
        return _subject.asDriver(onErrorRecover: { error in
            rxFatalError("A PublishRelay shouldn't be able to emit an error: \(error)")
        })
    }
}
