//
//  PublishRelay.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import Dispatch
#if !RX_NO_MODULE
    import RxSwift
#endif

/// PublishRelay is a wrapper for `PublishSubject`.
///
/// Unlike `PublishSubject` it can't terminate with error, and when publisher is deallocated
/// it will complete it's observable sequence (`asObservable`).
public final class PublishRelay<Element> {
    
    public typealias E = Element
    public typealias SharingStrategy = PublishSharingStrategy
    
    private let _subject: PublishSubject<Element>
    
    // Accepts `event` and emits it to subscribers
    public func accept(_ event: E) {
        _subject.onNext(event)
    }
    
    /// Initializes variable with initial value.
    public init() {
        _subject = PublishSubject()
    }
    
    /// - returns: Canonical interface for push style sequence
    public func asObservable() -> Observable<E> {
        return _subject.observeOn(SharingStrategy.scheduler)
    }
}
