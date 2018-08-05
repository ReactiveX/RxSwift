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
    static let timeout: TimeInterval = 0.5
}

extension NSTextViewTests {
    func testTextView_StringCompletesOnDealloc() {
        let createView: () -> NSTextView = { NSTextView(frame: CGRect(x: 0, y: 0, width: 1, height: 1)) }
        ensurePropertyDeallocated(createView, "a") { (view: NSTextView) in view.rx.string }
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

            XCTAssertEqual(delegate.numberOfChanges, 0)
            var numberOfChanges = 0
            for string in strings {
                textView.string = string
                let notification = Notification(
                    name: NSText.didChangeNotification,
                    object: textView,
                    userInfo: nil)
                XCTAssertEqual(delegate.numberOfChanges, numberOfChanges)
                (textView.delegate as NSTextDelegate?)?.textDidChange?(notification)
                numberOfChanges += 1
                XCTAssertEqual(delegate.numberOfChanges, numberOfChanges)
            }
        }

        wait(for: [completeExpectation], timeout: NSTextViewTests.timeout)
        XCTAssertEqual(assert, recorded)
    }
}

fileprivate final class TextViewDelegate: NSObject, NSTextViewDelegate {
    var numberOfChanges = 0

    func textDidChange(_ notification: Notification) {
        numberOfChanges = numberOfChanges + 1
    }
}
