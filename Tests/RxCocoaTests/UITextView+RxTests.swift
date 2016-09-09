//
//  UITextView+RxTests.swift
//  Rx
//
//  Created by Krunoslav Zaher on 5/13/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import XCTest

// UITextView
class UITextViewTests : RxTest {
    func testText_DelegateEventCompletesOnDealloc() {
        let createView: () -> UITextView = { UITextView(frame: CGRect(x: 0, y: 0, width: 1, height: 1)) }
        ensurePropertyDeallocated(createView, "text") { (view: UITextView) in view.rx.text }
    }

    func testSettingTextDoesntClearMarkedText() {
        let textView = UITextViewSubclass2(frame: CGRect.zero)

        textView.text = "Text1"
        textView.set = false
        textView.rx.text.on(.next("Text1"))
        XCTAssertTrue(!textView.set)
        textView.rx.text.on(.next("Text2"))
        XCTAssertTrue(textView.set)
    }

    func testDidBeginEditing() {
        var completed = false
        var value: ()?

        autoreleasepool {
            let textView = UITextView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))

            _ = textView.rx.didBeginEditing.subscribe(onNext: { n in
                    value = n
                }, onCompleted: {
                    completed = true
                })

            textView.delegate!.textViewDidBeginEditing!(textView)
        }

        XCTAssertNotNil(value)
        XCTAssertTrue(completed)
    }

    func testDidEndEditing() {
        var completed = false
        var value: ()?

        autoreleasepool {
            let textView = UITextView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))

            _ = textView.rx.didEndEditing.subscribe(onNext: { n in
                    value = n
                }, onCompleted: {
                    completed = true
                })

            textView.delegate!.textViewDidEndEditing!(textView)
        }

        XCTAssertNotNil(value)
        XCTAssertTrue(completed)
    }

    func testDidChange() {
        var completed = false
        var value: ()?

        autoreleasepool {
            let textView = UITextView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))

            _ = textView.rx.didChange.subscribe(onNext: { n in
                    value = n
                }, onCompleted: {
                    completed = true
                })

            textView.delegate!.textViewDidChange!(textView)
        }

        XCTAssertNotNil(value)
        XCTAssertTrue(completed)
    }

    func testDidChangeSelection() {
        var completed = false
        var value: ()?

        autoreleasepool {
            let textView = UITextView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))

            _ = textView.rx.didChangeSelection.subscribe(onNext: { n in
                    value = n
                }, onCompleted: {
                    completed = true
                })

            textView.delegate!.textViewDidChangeSelection!(textView)
        }

        XCTAssertNotNil(value)
        XCTAssertTrue(completed)
    }
}

class UITextViewSubclass2 : UITextView {
    var set: Bool = false

    override var text: String? {
        get {
            return super.text
        }
        set {
            set = true
            super.text = newValue
        }
    }
}
