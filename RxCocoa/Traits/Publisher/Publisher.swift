//
//  Publisher.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 9/26/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if !RX_NO_MODULE
    import RxSwift
#endif

/**
 Unit that represents observable sequence with following properties:
 
 - it never fails
 - it delivers events on `MainScheduler.instance`
 - all observers share sequence computation resources
 - computation of elements is reference counted with respect to the number of observers
 - if there are no subscribers, it will release sequence computation resources
 
 `Publisher<Element>` can be considered a builder pattern for observable sequences that model imperative events part of the application.
 
 To find out more about units and how to use them, please visit `Documentation/Units.md`.
 */
public typealias Publisher<E> = SharedSequence<PublishSharingStrategy, E>

public struct PublishSharingStrategy : SharingStrategyProtocol {
    public static var scheduler: SchedulerType { return publisherObserveOnScheduler }
    
    public static func share<E>(_ source: Observable<E>) -> Observable<E> {
        return source.share()
    }
}

extension SharedSequenceConvertibleType where SharingStrategy == PublishSharingStrategy {
    /// Adds `asPublisher` to `SharingSequence` with `PublishSharingStrategy`.
    public func asPublisher() -> Publisher<E> {
        return asSharedSequence()
    }
}

/**
 This method can be used in unit tests to ensure that publisher is using mock schedulers instead of
 main schedulers.
 
 **This shouldn't be used in normal release builds.**
 */
public func publishOnScheduler(_ scheduler: SchedulerType, action: () -> ()) {
    let originalObserveOnScheduler = publisherObserveOnScheduler
    publisherObserveOnScheduler = scheduler
    
    action()
    
    // If you remove this line , compiler buggy optimizations will change behavior of this code
    _forceCompilerToStopDoingInsaneOptimizationsThatBreakCode(publisherObserveOnScheduler)
    // Scary, I know
    
    publisherObserveOnScheduler = originalObserveOnScheduler
}

fileprivate var publisherObserveOnScheduler: SchedulerType = MainScheduler.instance
