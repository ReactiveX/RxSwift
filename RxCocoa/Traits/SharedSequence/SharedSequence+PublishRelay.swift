//
//  SharedSequence+PublishRelay.swift
//  RxSwift-iOS
//
//  Created by yuzushioh on 2017/10/09.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

#if !RX_NO_MODULE
    import RxSwift
#endif

extension PublishRelay {
    /// Converts `PublishReplay` to `SharedSequence`.
    ///
    /// `PublishReplay` can't fail, so no special case needs to be handled.
    ///
    /// - returns: Observable sequence.
    public func asSharedSequence<SharingStrategy: SharingStrategyProtocol>(strategy: SharingStrategy.Type = SharingStrategy.self) -> SharedSequence<SharingStrategy, Element> {
        let source = self.asObservable()
            .observeOn(SharingStrategy.scheduler)
        return SharedSequence(source)
    }
}

