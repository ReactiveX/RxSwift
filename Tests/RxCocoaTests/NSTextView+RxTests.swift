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
}

extension NSTextViewTests {
    func testTextView_StringCompletesOnDealloc() {
        let createView: () -> NSTextView = { NSTextView(frame: CGRect(x: 0, y: 0, width: 1, height: 1)) }
        ensurePropertyDeallocated(createView, "a", timeout: NSTextViewTests.timeout) { (view: NSTextView) in view.rx.string }
    }

    func testTextView_TextDidChange_ForwardsToDelegates() {
        let completeExpectation = XCTestExpectation(description: "NSTextView completion")
        let strings: [String] = ["T", "Te", "Tes", "Test"]
        let assert: [String] = [""] + strings
        var recorded: [String] = []

        autoreleasepool {
            let textView = NSTextView()
            let delegate = TextViewDelegate()
            textView.delegate = delegate

            _ = textView.rx.string
                .subscribe(onNext: { value in
                    recorded.append(value)
                }, onCompleted: {
                    completeExpectation.fulfill()
                })

            XCTAssertFalse(delegate.didChange)
            for string in strings {
                textView.string = string
                let notification = Notification(
                    name: NSText.didChangeNotification,
                    object: textView,
                    userInfo: nil)
                (textView.delegate as NSTextDelegate?)?.textDidChange?(notification)
                XCTAssertTrue(delegate.didChange)
            }
        }

        wait(for: [completeExpectation], timeout: NSTextViewTests.timeout)
        XCTAssertEqual(assert, recorded)
    }
}

fileprivate final class TextViewDelegate: NSObject, NSTextViewDelegate {

    var didChange = false

    func textDidChange(_ notification: Notification) {
        didChange = true
    }

}
