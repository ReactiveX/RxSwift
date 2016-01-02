//
//  Driver+Extensions.swift
//  Tests
//
//  Created by Krunoslav Zaher on 12/25/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxCocoa

extension Driver : Equatable {

}

public func == <T>(lhs: Driver<T>, rhs: Driver<T>) -> Bool {
    return lhs.asObservable() === rhs.asObservable()
}