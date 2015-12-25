//
//  Driver+Extensions.swift
//  Tests
//
//  Created by Krunoslav Zaher on 12/25/15.
//
//

import Foundation

extension Driver : Equatable {

}

public func == <T>(lhs: Driver<T>, rhs: Driver<T>) -> Bool {
    return lhs.asObservable() === rhs.asObservable()
}