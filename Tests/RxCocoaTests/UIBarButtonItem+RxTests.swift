//
//  UIBarButtonItem+RxTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 11/26/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import RxCocoa
import RxSwift
import RxTest
import XCTest

final class UIBarButtonItemTests: RxTest {

}

// UIBarButtonItem
extension UIBarButtonItemTests {
    func testBarButtonItem_DelegateEventCompletesOnDealloc() {
        ensureEventDeallocated({ UIBarButtonItem() }) { (view: UIBarButtonItem) in view.rx.tap }
    }
    
    func testButton_titleObserver() {
        let button = UIBarButtonItem()
        XCTAssertEqual(button.title, nil)
        let text = "title"
        _ = Observable.just(text).bind(to: button.rx.title)
        
        XCTAssertEqual(button.title, text)
    }
    
    func testBarButtonItem_actionExecution() {
        let button = UIBarButtonItem()
        weak var tapExpectation = expectation(description: "tap")
        let disposable = button.rx.tap.subscribe(onNext: {
            tapExpectation?.fulfill()
        })
        defer { disposable.dispose() }
        _ = button.target?.perform(button.action, with: nil)
        waitForExpectations(timeout: 1, handler: nil)
    }
}
