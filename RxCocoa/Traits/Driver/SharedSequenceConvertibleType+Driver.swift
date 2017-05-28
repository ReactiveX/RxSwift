//
//  SharedSequenceConvertibleType+Driver.swift
//  RxCocoa
//
//  Created by Jeremie Girault on 28/05/2017.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

#if !RX_NO_MODULE
    import RxSwift
#endif

extension SharedSequenceConvertibleType {
    /**
     Converts anything convertible to `SharedSequence` to `Driver` unit.
     Which means switching observation to the DriverSharingStrategy.scheduler
     - returns: Driving observable sequence.
     */
    public func asDriver() -> Driver<E> {
        let source = self
            .asObservable()
            .observeOn(DriverSharingStrategy.scheduler)
            // Don't need to catch error, SharedSequence spec defines that there is no error
        return Driver(source)
    }
}
