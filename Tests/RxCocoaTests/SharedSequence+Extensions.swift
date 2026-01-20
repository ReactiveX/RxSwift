//
//  SharedSequence+Extensions.swift
//  Tests
//
//  Created by Krunoslav Zaher on 12/25/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxCocoa

extension SharedSequence: @retroactive Equatable {}

public func == <S, T>(lhs: SharedSequence<S, T>, rhs: SharedSequence<S, T>) -> Bool {
    lhs.asObservable() === rhs.asObservable()
}
