//
//  Publisher+SharedSequence.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 12/28/15.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

#if !RX_NO_MODULE
    import RxSwift
#endif

extension Publisher : SharedSequenceConvertibleType {

    /// Converts `Publisher` to `SharedSequence`.
    ///
    /// - returns: Observable sequence.
    public func asSharedSequence() -> SharedSequence<PublishSharingStrategy, Element> {
        let source = self.asObservable()
            .observeOn(SharingStrategy.scheduler)
        return SharedSequence(source)
    }
}
