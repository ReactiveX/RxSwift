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

    func testBinderDoesNotRetainTarget() {
        var target: NSObject? = NSObject()
        #if swift(>=6.2)
        weak let weakTarget = target
        #else
        weak var weakTarget = target
        #endif

        _ = Binder(target!) { (_, _: Int) in }

        target = nil

        XCTAssertNil(weakTarget)
    }

    func testBindingDoesNotExecuteAfterTargetDeallocated() {
        var target: NSObject? = NSObject()
        var bindingExecuted = false

        let binder = Binder(target!) { (_, _: Int) in
            bindingExecuted = true
        }

        target = nil
        binder.on(.next(1))

        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))

        XCTAssertFalse(bindingExecuted)
    }

    func testBindingReceivesCorrectValue() {
        let expectation = expectation(description: "binding executed")
        let target = NSObject()
        var receivedValue: Int?

        let binder = Binder(target) { (_, value: Int) in
            receivedValue = value
            expectation.fulfill()
        }

        binder.on(.next(42))

        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(receivedValue, 42)
    }

    func testBindingReceivesCorrectTarget() {
        let expectation = expectation(description: "binding executed")
        let target = NSObject()
        var receivedTarget: NSObject?

        let binder = Binder(target) { (t, _: Int) in
            receivedTarget = t
            expectation.fulfill()
        }

        binder.on(.next(1))

        waitForExpectations(timeout: 1.0)
        XCTAssertTrue(receivedTarget === target)
    }
}
