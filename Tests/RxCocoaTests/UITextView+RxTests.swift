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
        let createView: () -> UITextView = { UITextView(frame: CGRectMake(0, 0, 1, 1)) }
        ensurePropertyDeallocated(createView, "text") { (view: UITextView) in view.rx_text }
    }

    func testSettingTextDoesntClearMarkedText() {
        let textView = UITextViewSubclass2(frame: CGRect.zero)

        textView.text = "Text1"
        textView.set = false
        textView.rx_text.on(.Next("Text1"))
        XCTAssertTrue(!textView.set)
        textView.rx_text.on(.Next("Text2"))
        XCTAssertTrue(textView.set)
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