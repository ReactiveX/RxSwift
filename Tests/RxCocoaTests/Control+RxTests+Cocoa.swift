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

// NSTextField
extension ControlTests {
    func testTextField_TextCompletesOnDealloc() {
        let createView: () -> NSTextField = { NSTextField(frame: CGRect(x: 0, y: 0, width: 1, height: 1)) }
        ensurePropertyDeallocated(createView, "a") { (view: NSTextField) in view.rx.text.orEmpty }
    }
}

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

// NSSlider
extension ControlTests {
    func testCollectionView_DelegateEventCompletesOnDealloc() {
        let createView: () -> NSSlider = { NSSlider(frame: CGRect(x: 0, y: 0, width: 1, height: 1)) }
        ensurePropertyDeallocated(createView, 0.3) { (view: NSSlider) in view.rx.value }
    }
}

// NSButton
extension ControlTests {
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
        _ = Observable.just(NSOnState).bindTo(button.rx.state)

        XCTAssertEqual(button.state, NSOnState)
    }

    func testButton_state_observer_off() {
        let button = NSButton(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        _ = Observable.just(NSOffState).bindTo(button.rx.state)

        XCTAssertEqual(button.state, NSOffState)
    }
}
