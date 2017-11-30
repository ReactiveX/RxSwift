//
//  SharedSequence+Extensions.swift
//  Tests
//
//  Created by Krunoslav Zaher on 12/25/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxCocoa

extension SharedSequence : Equatable {

}

public func == <S, T>(lhs: SharedSequence<S, T>, rhs: SharedSequence<S, T>) -> Bool {
    return lhs.asObservable() === rhs.asObservable()
}
