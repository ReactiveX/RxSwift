//
//  Control+RxTests+UIKit.swift
//  Tests
//
//  Created by Ash Furrow on 4/7/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import XCTest

extension ControlTests {
    func testSubscribeEnabledToTrue() {
        let subject = UIControl()
        let disposable = Observable.just(true).subscribe(subject.rx.isEnabled)
        defer { disposable.dispose() }

        XCTAssert(subject.isEnabled == true, "Expected enabled set to true")
    }

    func testSubscribeEnabledToFalse() {
        let subject = UIControl()
        let disposable = Observable.just(false).subscribe(subject.rx.isEnabled)
        defer { disposable.dispose() }

        XCTAssert(subject.isEnabled == false, "Expected enabled set to false")
    }

    func testSubscribedSelectedToTrue() {
        let subject = UIControl()
        let disposable = Observable.just(true).subscribe(subject.rx.isSelected)
        defer { disposable.dispose() }

        XCTAssert(subject.isSelected == true, "Expected selected set to true")
    }

    func testSubscribeSelectedToFalse() {
        let subject = UIControl()
        let disposable = Observable.just(false).subscribe(subject.rx.isSelected)
        defer { disposable.dispose() }

        XCTAssert(subject.isSelected == false, "Expected selected set to false")
    }
}

// Attempting to load the view of a view controller while it is deallocating is not allowed and may result in undefined behavior (<UIAlertController: 0x7fc6820309c0>)
// Don't know why can't use ActionSheet and AlertView inside unit tests


// UIControl
extension ControlTests {
    func testControl_DelegateEventCompletesOnDealloc() {
        let createView: () -> UIControl = { UIControl(frame: CGRect(x: 0, y: 0, width: 1, height: 1)) }
        ensureEventDeallocated(createView) { (view: UIControl) in view.rx.controlEvent(.allEditingEvents) }
    }
}

