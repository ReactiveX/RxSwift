//
//  PublishRelay+Driver.swift
//  RxCocoa
//
//  Created by Damian Malarczyk on 15/10/2018.
//  Copyright © 2018 Krunoslav Zaher. All rights reserved.
//

import RxSwift

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
