//
//  Any+Equatable.swift
//  RxTest
//
//  Created by Krunoslav Zaher on 12/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// A way to use built in XCTest methods with objects that are partially equatable.
///
/// If this can be done simpler, PRs are welcome :)
struct AnyEquatable<Target>: Equatable {
    typealias Comparer = (Target, Target) -> Bool

    let target: Target
    let comparer: Comparer

    init(target: Target, comparer: @escaping Comparer) {
        self.target = target
        self.comparer = comparer
    }
}

func == <T>(lhs: AnyEquatable<T>, rhs: AnyEquatable<T>) -> Bool {
    return lhs.comparer(lhs.target, rhs.target)
}

extension AnyEquatable
    : CustomDebugStringConvertible
    , CustomStringConvertible  {
    var description: String {
        "\(self.target)"
    }

    var debugDescription: String {
        "\(self.target)"
    }
}
