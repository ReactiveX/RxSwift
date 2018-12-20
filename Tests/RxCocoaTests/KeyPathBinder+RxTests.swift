//
//  KeyPathBinder+RxTests.swift
//  Tests
//
//  Created by Ryo Aoyama on 2/7/18.
//  Copyright © 2018 Krunoslav Zaher. All rights reserved.
//

import RxCocoa
import RxSwift
import XCTest

final class KeyPathBinderTests: RxTest {}

private final class Object: ReactiveCompatible {
    var value: Int = 0 {
        didSet { valueDidSet() }
    }
    
    private let valueDidSet: () -> Void
    
    init(valueDidSet: @escaping () -> Void) {
        self.valueDidSet = valueDidSet
    }
}

extension KeyPathBinderTests {
    
    func testBindingOnNonMainQueueDispatchesToMainQueue() {
        let waitForElement = self.expectation(description: "wait until element arrives")
        
        let object = Object {
            MainScheduler.ensureExecutingOnScheduler()
            waitForElement.fulfill()
        }
        
        let bindingObserver = object.rx[\.value]
        
        DispatchQueue.global(qos: .default).async {
            bindingObserver.on(.next(1))
        }
        
        self.waitForExpectations(timeout: 1.0) { (e) in
            XCTAssertNil(e)
        }
    }
    
    func testBindingOnMainQueueDispatchesToNonMainQueue() {
        let waitForElement = self.expectation(description: "wait until element arrives")
        
        let object = Object {
            XCTAssert(!DispatchQueue.isMain)
            waitForElement.fulfill()
        }
        
        let scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
        let bindingObserver = object.rx[\.value, on: scheduler]
        
        bindingObserver.on(.next(1))
        
        self.waitForExpectations(timeout: 1.0) { (e) in
            XCTAssertNil(e)
        }
    }
    
}
