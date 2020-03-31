//
//  PublishRelay+Driver.swift
//  RxCocoa
//
//  Created by yhkaplan on 2020/03/31.
//  Copyright © 2020 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxRelay

extension PublishRelay {
    /// Converts `PublishRelay` to `Driver`.
    ///
    /// - returns: Observable sequence.
    public func asDriver() -> Driver<Element> {
        let source = self.asObservable()
            .observeOn(DriverSharingStrategy.scheduler)
        return SharedSequence(source)
    }
}
