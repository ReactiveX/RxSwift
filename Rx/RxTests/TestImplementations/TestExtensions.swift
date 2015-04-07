//
//  TestExtensions.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/15/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import XCTest

func assertEquals<T: Equatable>(lhs: T, rhs: T) {
    XCTAssertTrue(lhs == rhs)
}