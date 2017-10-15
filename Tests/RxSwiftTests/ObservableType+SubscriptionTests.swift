//
//  ObservableType+SubscriptionTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 10/15/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableSubscriptionTest : RxTest {

}

extension ObservableSubscriptionTest {
    func testDefaultErrorHandler() {
        var loggedErrors = [TestError]()

        _ = Observable<Int>.error(testError).subscribe()
        XCTAssertEqual(loggedErrors, [])

        let originalErrorHandler = Hooks.defaultErrorHandler

        Hooks.defaultErrorHandler = { _, error in
            loggedErrors.append(error as! TestError)
        }

        _ = Observable<Int>.error(testError).subscribe()
        XCTAssertEqual(loggedErrors, [testError])

        Hooks.defaultErrorHandler = originalErrorHandler

        _ = Observable<Int>.error(testError).subscribe()
        XCTAssertEqual(loggedErrors, [testError])
    }
}

