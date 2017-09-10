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
        _ = Observable.just(NSOnState).bind(to: button.rx.state)

        XCTAssertEqual(button.state, NSOnState)
    }

    func testButton_state_observer_off() {
        let button = NSButton(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        _ = Observable.just(NSOffState).bind(to: button.rx.state)

        XCTAssertEqual(button.state, NSOffState)
    }

    func testButton_multipleObservers() {
        let button = NSButton(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        var value1: Int? = nil
        var value2: Int? = nil

        var numberOfTimesReceivedValue = 0

        _ = Observable.just(NSOffState).bind(to: button.rx.state)
        let d1 = button.rx.state.subscribe(onNext: { numberOfTimesReceivedValue += 1; value1 = $0 })
        let d2 = button.rx.state.subscribe(onNext: { numberOfTimesReceivedValue += 1; value2 = $0 })
        _ = Observable.just(NSOnState).bind(to: button.rx.state)

        if let target = button.target, let action = button.action {
            _ = target.perform(action, with: button)
        }


        XCTAssertEqual(button.state, NSOnState)
        XCTAssertEqual(value1, NSOnState)
        XCTAssertEqual(value2, NSOnState)

        XCTAssertEqual(numberOfTimesReceivedValue, 4)

        d1.dispose()
        d2.dispose()

        _ = button.rx.state.subscribe(onNext: { numberOfTimesReceivedValue += 1; value1 = $0 })
        _ = button.rx.state.subscribe(onNext: { numberOfTimesReceivedValue += 1; value2 = $0 })

        XCTAssertEqual(numberOfTimesReceivedValue, 6)

        XCTAssertEqual(button.state, NSOnState)
        XCTAssertEqual(value1, NSOnState)
        XCTAssertEqual(value2, NSOnState)
    }
}
