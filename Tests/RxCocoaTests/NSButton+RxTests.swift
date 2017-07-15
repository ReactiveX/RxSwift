//
//  NSButton+RxTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 11/26/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxCocoa
import AppKit
import XCTest

final class NSButtonTests: RxTest {

}

extension NSButtonTests {
    func testButton_DelegateEventCompletesOnDealloc() {
        let createView: () -> NSButton = { NSButton(frame: CGRect(x: 0, y: 0, width: 1, height: 1)) }
        ensureEventDeallocated(createView) { (view: NSButton) in view.rx.tap }
    }

    func testButton_StateCompletesOnDealloc() {
        let createView: () -> NSButton = { NSButton(frame: CGRect(x: 0, y: 0, width: 1, height: 1)) }
        ensurePropertyDeallocated(createView, 0) { (view: NSButton) in view.rx.state }
    }

    func testButton_state_observer_on() {
        let button = NSButton(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        _ = Observable.just(NSControl.StateValue.onState.rawValue).bind(to: button.rx.state)

        XCTAssertEqual(button.state, NSControl.StateValue.onState)
    }

    func testButton_state_observer_off() {
        let button = NSButton(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        _ = Observable.just(NSControl.StateValue.onState.rawValue).bind(to: button.rx.state)

        XCTAssertEqual(button.state, NSControl.StateValue.onState)
    }
}
