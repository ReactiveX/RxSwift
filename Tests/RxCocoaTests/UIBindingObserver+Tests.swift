//
//  UIBindingObserver+Tests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 12/17/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import RxCocoa
import XCTest
import RxSwift

final class UIBindingObserverTests: RxTest {
}

extension UIBindingObserverTests {
    func testBindingOnNonMainQueueDispatchesToMainQueue() {
        let waitForElement = self.expectation(description: "wait until element arrives")
        let target = NSObject()
        let bindingObserver = UIBindingObserver<NSObject, Int>(UIElement: target) { (_, element: Int) in
            MainScheduler.ensureExecutingOnScheduler()
            waitForElement.fulfill()
        }

        DispatchQueue.global(qos: .default).async {
            bindingObserver.on(.next(1))
        }

        self.waitForExpectations(timeout: 1.0) { (e) in
            XCTAssertNil(e)
        }
    }
}
