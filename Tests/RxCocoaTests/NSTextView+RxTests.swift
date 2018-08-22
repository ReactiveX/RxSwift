//
//  NSTextView+RxTests.swift
//  Tests
//
//  Created by Cee on 8/5/18.
//  Copyright © 2018 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxCocoa
import AppKit
import XCTest

final class NSTextViewTests: RxTest {
    /// NSTextView is much more complicated than other NS-prefix views or controls,
    /// which takes a longer time to go through the `onCompleted` block. Here, we are
    /// using `wait(for:timeout:)` to check dealloc/complete operations.
    static let timeout: TimeInterval = 0.5

    static let notificationForwardTestStrings: [String] = ["T", "Te", "Tes", "Test"]
    static let notificationForwardTestAssertStrings: [String] = [""] + NSTextViewTests.notificationForwardTestStrings
}

extension NSTextViewTests {
    func testTextView_StringCompletesOnDealloc() {
        let createView: () -> NSTextView = { NSTextView(frame: CGRect(x: 0, y: 0, width: 1, height: 1)) }
        ensurePropertyDeallocated(createView, "a", timeout: NSTextViewTests.timeout) { (view: NSTextView) in view.rx.string }
    }

    func testTextView_TextDidChange_ForwardsToDelegates() {

        let completeExpectation = XCTestExpectation(description: "NSTextView completion")

        autoreleasepool {
            let textView = NSTextView()
            let delegate = TextViewDelegate()
            textView.delegate = delegate
            var rxDidChange = false

            var index = 0

            _ = textView.rx.string
                .subscribe(onNext: { value in
                    XCTAssertEqual(NSTextViewTests.notificationForwardTestAssertStrings[index], value)
                    index += 1
                    rxDidChange = true
                }, onCompleted: {
                    completeExpectation.fulfill()
                })

            for testString in NSTextViewTests.notificationForwardTestStrings {
                textView.string = testString
                let notification = Notification(
                    name: NSText.didChangeNotification,
                    object: textView,
                    userInfo: nil)
                (textView.delegate as NSTextDelegate?)?.textDidChange?(notification)
            }

            XCTAssertTrue(rxDidChange)
            XCTAssertTrue(delegate.didChange)
        }

        wait(for: [completeExpectation], timeout: NSTextViewTests.timeout)
    }

}

fileprivate final class TextViewDelegate: NSObject, NSTextViewDelegate {

    var didChange = false

    func textDidChange(_ notification: Notification) {
        didChange = true
    }

}
