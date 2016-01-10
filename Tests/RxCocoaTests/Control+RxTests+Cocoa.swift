//
//  Control+RxTests+Cocoa.swift
//  RxTests
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
        let createView: () -> NSTextField = { NSTextField(frame: CGRectMake(0, 0, 1, 1)) }
        ensurePropertyDeallocated(createView, "a") { (view: NSTextField) in view.rx_text }
    }
}

// NSControl
extension ControlTests {
    func testControl_DelegateEventCompletesOnDealloc() {
        let createView: () -> NSControl = { NSControl(frame: CGRectMake(0, 0, 1, 1)) }
        ensureEventDeallocated(createView) { (view: NSControl) in view.rx_controlEvent }
    }

    func testControl_enabled_true() {
        let control = NSControl(frame: CGRectMake(0, 0, 1, 1))

        _ = Observable.just(true).bindTo(control.rx_enabled)

        XCTAssertEqual(true, control.enabled)
    }

    func testControl_enabled_false() {
        let control = NSControl(frame: CGRectMake(0, 0, 1, 1))

        _ = Observable.just(false).bindTo(control.rx_enabled)

        XCTAssertEqual(false, control.enabled)
    }
}

// NSSlider
extension ControlTests {
    func testCollectionView_DelegateEventCompletesOnDealloc() {
        let createView: () -> NSSlider = { NSSlider(frame: CGRectMake(0, 0, 1, 1)) }
        ensurePropertyDeallocated(createView, 0.3) { (view: NSSlider) in view.rx_value }
    }
}

// NSButton
extension ControlTests {
    func testButton_DelegateEventCompletesOnDealloc() {
        let createView: () -> NSButton = { NSButton(frame: CGRectMake(0, 0, 1, 1)) }
        ensureEventDeallocated(createView) { (view: NSButton) in view.rx_tap }
    }

    func testButton_StateCompletesOnDealloc() {
        let createView: () -> NSButton = { NSButton(frame: CGRectMake(0, 0, 1, 1)) }
        ensurePropertyDeallocated(createView, 0) { (view: NSButton) in view.rx_state }
    }

    func testButton_state_observer_on() {
        let button = NSButton(frame: CGRectMake(0, 0, 1, 1))
        _ = Observable.just(NSOnState).bindTo(button.rx_state)

        XCTAssertEqual(button.state, NSOnState)
    }

    func testButton_state_observer_off() {
        let button = NSButton(frame: CGRectMake(0, 0, 1, 1))
        _ = Observable.just(NSOffState).bindTo(button.rx_state)

        XCTAssertEqual(button.state, NSOffState)
    }
}