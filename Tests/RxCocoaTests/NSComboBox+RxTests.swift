//
//  NSComboBox+RxTests.swift
//  Tests
//
//  Created by Jacob Gorban on 07/17/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxCocoa
import AppKit
import XCTest

final class NSComboBoxTests: RxTest {

}

extension NSComboBoxTests {
    func testComboBox_IndexOfSelectedItemCompletesOnDealloc() {
        let createView: () -> NSComboBox = { NSComboBox(frame: CGRect(x: 0, y: 0, width: 1, height: 1)) }
        ensurePropertyDeallocated(createView, -1) { (view: NSComboBox) in view.rx.indexOfSelectedItem }
    }

    func testComboBox_ComboBoxSelectionDidChange_ForwardsToDelegates() {

        var completed = false

        autoreleasepool {
            let comboBox = NSComboBox()
            let delegate = ComboBoxDelegate()
            comboBox.delegate = delegate
            var rxDidChange = false

            _ = comboBox.rx.indexOfSelectedItem
                .skip(1) // Initial value
                .subscribe(onNext: { _ in
                    rxDidChange = true
                }, onCompleted: {
                    completed = true
                })

            XCTAssertFalse(rxDidChange)
            XCTAssertFalse(delegate.didChange)

            let notification = Notification(
                name: .NSComboBoxSelectionDidChange,
                object: comboBox,
                userInfo: [:])
            comboBox.delegate!.comboBoxSelectionDidChange!(notification)

            XCTAssertTrue(rxDidChange)
            XCTAssertTrue(delegate.didChange)
        }

        XCTAssertTrue(completed)
    }

}

fileprivate final class ComboBoxDelegate: NSObject, NSComboBoxDelegate {

    var didChange = false
    func comboBoxSelectionDidChange(_ notification: Notification) {
        didChange = true
    }
}
