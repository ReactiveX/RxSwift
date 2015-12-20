//
//  Control+RxTests+Cocoa.swift
//  RxTests
//
//  Created by Krunoslav Zaher on 10/19/15.
//
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
        ensureEventDeallocated(createView) { (view: NSControl) in view.rx_controlEvents }
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
}