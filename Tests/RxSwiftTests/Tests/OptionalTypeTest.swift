//
//  OptionalTypeTest.swift
//  Rx
//
//  Created by Tomasz Pikć on 17/04/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation
@testable import RxSwift
import XCTest
import RxTests

class OptionalTypeTest: RxTest {
    func test_CompareOptionals_forTheSameValues_ShouldReturnTrue() {
        let val1: Int? = 5
        let val2: Int? = 5
        let result = val1.intoOptional() == val2.intoOptional()
        XCTAssertTrue(result)
    }
    
    func test_CompareOptionals_forDifferentValues_ShouldReturnFalse() {
        let val1: Int? = 5
        let val2: Int? = 10
        let result = val1.intoOptional() == val2.intoOptional()
        XCTAssertFalse(result)
    }
    
    func test_CompareOptionals_forDifferentValues_WithNil_ShouldReturnFalse() {
        let val1: Int? = 5
        let val2: Int? = nil
        let result = val1.intoOptional() == val2.intoOptional()
        XCTAssertFalse(result)
    }
    
    func test_CompareOptionals_forNils_ShouldReturnTrue() {
        let val1: Int? = nil
        let val2: Int? = nil
        let result = val1.intoOptional() == val2.intoOptional()
        XCTAssertTrue(result)
    }
}


