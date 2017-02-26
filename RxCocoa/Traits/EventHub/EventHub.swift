//
//  EventHub.swift
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
 
 `EventHub<Element>` can be considered a builder pattern for observable sequences that model imperative events part of the application.
 
 To find out more about units and how to use them, please visit `Documentation/Units.md`.
 */
public typealias EventHub<E> = SharedSequence<PublishSharingStrategy, E>

public struct PublishSharingStrategy : SharingStrategyProtocol {
    public static var scheduler: SchedulerType { return publisherObserveOnScheduler }
    
    public static func share<E>(_ source: Observable<E>) -> Observable<E> {
        return source.share()
    }
}

extension SharedSequenceConvertibleType where SharingStrategy == PublishSharingStrategy {
    /// Adds `asEventHub` to `SharingSequence` with `PublishSharingStrategy`.
    public func asEventHub() -> EventHub<E> {
        return asSharedSequence()
    }
}

fileprivate var publisherObserveOnScheduler: SchedulerType = MainScheduler.instance
