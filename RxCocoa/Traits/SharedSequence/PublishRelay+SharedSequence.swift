//
//  PublishRelay+SharedSequence.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 12/28/15.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

#if !RX_NO_MODULE
    import RxSwift
#endif

extension PublishRelay : SharedSequenceConvertibleType {

    /// Converts `PublishRelay` to `SharedSequence`.
    ///
    /// - returns: Observable sequence.
    public func asSharedSequence() -> SharedSequence<PublishSharingStrategy, Element> {
        let source = self.asObservable()
            .observeOn(SharingStrategy.scheduler)
        return SharedSequence(source)
    }
}
