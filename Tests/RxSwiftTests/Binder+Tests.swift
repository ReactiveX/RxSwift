//
//  Binder+Tests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 12/17/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import XCTest

class BinderTests: RxTest {}

extension BinderTests {
    func testBindingOnNonMainQueueDispatchesToMainQueue() {
        let waitForElement = expectation(description: "wait until element arrives")
        let target = NSObject()
        let bindingObserver = Binder(target) { (_, _: Int) in
            MainScheduler.ensureRunningOnMainThread()
            waitForElement.fulfill()
        }

        DispatchQueue.global(qos: .default).async {
            bindingObserver.on(.next(1))
        }

        waitForExpectations(timeout: 1.0) { e in
            XCTAssertNil(e)
        }
    }

    func testBindingOnMainQueueDispatchesToNonMainQueue() {
        let waitForElement = expectation(description: "wait until element arrives")
        let target = NSObject()
        let bindingObserver = Binder(target, scheduler: ConcurrentDispatchQueueScheduler(qos: .default)) { (_, _: Int) in
            XCTAssert(!DispatchQueue.isMain)
            waitForElement.fulfill()
        }

        bindingObserver.on(.next(1))

        waitForExpectations(timeout: 1.0) { e in
            XCTAssertNil(e)
        }
    }
}
