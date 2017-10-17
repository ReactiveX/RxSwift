//
//  NSTextField+RxTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 11/26/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxCocoa
import AppKit
import XCTest

final class NSTextFieldTests: RxTest {

}

extension NSTextFieldTests {
    func testTextField_TextCompletesOnDealloc() {
        let createView: () -> NSTextField = { NSTextField(frame: CGRect(x: 0, y: 0, width: 1, height: 1)) }
        ensurePropertyDeallocated(createView, "a") { (view: NSTextField) in view.rx.text.orEmpty }
    }

    func testTextField_ControlTextDidChange_ForwardsToDelegates() {

        var completed = false

        autoreleasepool {
            let textField = NSTextField()
            let delegate = TextFieldDelegate()
            textField.delegate = delegate
            var rxDidChange = false

            _ = textField.rx.text
                .skip(1) // Initial value
                .subscribe(onNext: { _ in
                    rxDidChange = true
                }, onCompleted: {
                    completed = true
                })

            XCTAssertFalse(rxDidChange)
            XCTAssertFalse(delegate.didChange)

            let notification = Notification(
                name: NSControl.textDidChangeNotification,
                object: textField,
                userInfo: ["NSFieldEditor" : NSText()])
            (textField.delegate as! NSObject).controlTextDidChange(notification)

            XCTAssertTrue(rxDidChange)
            XCTAssertTrue(delegate.didChange)
        }

        XCTAssertTrue(completed)
    }

}

fileprivate final class TextFieldDelegate: NSObject, NSTextFieldDelegate {

    var didChange = false
    override func controlTextDidChange(_ notification: Notification) {
        didChange = true
    }
}
