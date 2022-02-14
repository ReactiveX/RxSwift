//
//  Infallible+Driver.swift
//  RxCocoa
//
//  Created by Anton Siliuk on 14/02/2022.
//  Copyright © 2022 Krunoslav Zaher. All rights reserved.
//

import RxSwift

extension InfallibleType {
    /// Converts `InfallibleType` to `Driver`.
    ///
    /// - returns: Observable sequence.
    public func asDriver() -> Driver<Element> {
        let source = self.asObservable()
            .observe(on:DriverSharingStrategy.scheduler)
        return SharedSequence(source)
    }
}
