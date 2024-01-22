//
//  PublishRelay+Driver.swift
//  RxCocoa
//
//  Created by Damon on 2024/01/22.
//  Copyright © 2024 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxRelay

extension PublishRelay {
    /// Converts `PublishRelay` to `Driver`.
    ///
    /// - returns: Observable sequence.
    public func asDriver() -> Driver<Element> {
        let source = self.asObservable()
            .observe(on:DriverSharingStrategy.scheduler)
        return SharedSequence(source)
    }
}
