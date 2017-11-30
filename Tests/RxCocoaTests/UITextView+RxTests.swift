//
//  UITextView+RxTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 5/13/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import XCTest

// UITextView
final class UITextViewTests : RxTest {
    func test_completesOnDealloc() {
        let createView: () -> UITextView = { UITextView(frame: CGRect(x: 0, y: 0, width: 1, height: 1)) }

        ensurePropertyDeallocated(createView, "text", comparer: { $0 == $1 }) { (view: UITextView) in view.rx.text }
        ensurePropertyDeallocated(createView, "text", comparer: { $0 == $1 }) { (view: UITextView) in view.rx.value }
        ensurePropertyDeallocated(createView, "text".enrichedWithTextFieldAttributes, comparer: { $0 == $1 }) { (view: UITextView) in view.rx.attributedText }
    }
    
    func testSettingTextDoesntClearMarkedText() {
        let textView = UITextViewSubclass2(frame: CGRect.zero)
        
        textView.text = "Text1"
        textView.didSetText = false
        textView.rx.text.on(.next("Text1"))
        XCTAssertTrue(!textView.didSetText)
        textView.rx.text.on(.next("Text2"))
        XCTAssertTrue(textView.didSetText)
    }
    
    func testSettingTextDoesntClearMarkedAttributtedText() {
        let textView = UITextViewSubclass2(frame: CGRect.zero)
        
        let testAttributedString = "Test1".enrichedWithTextFieldAttributes
        let test2AttributedString = "Test2".enrichedWithTextFieldAttributes
        
        textView.attributedText = testAttributedString
        textView.didSetAttributedText = false
        textView.rx.attributedText.on(.next(testAttributedString))
        XCTAssertTrue(!textView.didSetAttributedText)
        textView.rx.attributedText.on(.next(test2AttributedString))
        XCTAssertTrue(textView.didSetAttributedText)
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

private extension String {
    var enrichedWithTextFieldAttributes: NSAttributedString? {
        let tf = UITextView()
        tf.attributedText = NSAttributedString(string: self)
        return tf.attributedText!
    }
}

final class UITextViewSubclass2 : UITextView {
    var didSetText = false
    var didSetAttributedText = false
    
    override var text: String? {
        get {
            return super.text
        }
        set {
            didSetText = true
            super.text = newValue
        }
    }
    
    override var attributedText: NSAttributedString? {
        get {
            return super.attributedText
        }
        set {
            didSetAttributedText = true
            super.attributedText = newValue
        }
    }
}
