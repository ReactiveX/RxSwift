//
//  TestErrors.swift
//  Tests
//
//  Created by Krunoslav Zaher on 12/25/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

enum TestError: Error {
    case dummyError
    case dummyError1
    case dummyError2
}
let testError = TestError.dummyError
let testError1 = TestError.dummyError1
let testError2 = TestError.dummyError2
