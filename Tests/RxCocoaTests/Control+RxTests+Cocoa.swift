//
//  Control+RxTests+Cocoa.swift
//  Tests
//
//  Created by Krunoslav Zaher on 10/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Cocoa
import RxSwift
import RxCocoa
import XCTest

// NSControl
extension ControlTests {
    func testControl_DelegateEventCompletesOnDealloc() {
        let createView: () -> NSControl = { NSControl(frame: CGRect(x: 0, y: 0, width: 1, height: 1)) }
        ensureEventDeallocated(createView) { (view: NSControl) in view.rx.controlEvent }
    }

    func testControl_enabled_true() {
        let control = NSControl(frame: CGRect(x: 0, y: 0, width: 1, height: 1))

        _ = Observable.just(true).bindTo(control.rx.isEnabled)

        XCTAssertEqual(true, control.isEnabled)
    }

    func testControl_enabled_false() {
        let control = NSControl(frame: CGRect(x: 0, y: 0, width: 1, height: 1))

        _ = Observable.just(false).bindTo(control.rx.isEnabled)

        XCTAssertEqual(false, control.isEnabled)
    }
}

