//
//  BehaviorRelay+Driver.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 10/7/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import RxRelay
import RxSwift

public extension BehaviorRelay {
    /// Converts `BehaviorRelay` to `Driver`.
    ///
    /// - returns: Observable sequence.
    func asDriver() -> Driver<Element> {
        let source = asObservable()
            .observe(on: DriverSharingStrategy.scheduler)
        return SharedSequence(source)
    }
}
