//
//  UITextField+RxTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 5/13/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import XCTest

// UITextField
final class UITextFieldTests : RxTest {
    
    func test_completesOnDealloc() {
        ensurePropertyDeallocated({ UITextField() }, "a", comparer: { $0 == $1 }) { (view: UITextField) in view.rx.text }
        ensurePropertyDeallocated({ UITextField() }, "a", comparer: { $0 == $1 }) { (view: UITextField) in view.rx.value }
        ensurePropertyDeallocated({ UITextField() }, "a".enrichedWithTextFieldAttributes, comparer: { $0 == $1 }) { (view: UITextField) in view.rx.attributedText }
    }
    
    func test_settingTextDoesntClearMarkedText() {
        let textField = UITextFieldSubclass(frame: CGRect.zero)
        textField.text = "Text1"
        textField.didSetText = false
        textField.rx.text.on(.next("Text1"))
        XCTAssertTrue(!textField.didSetText)
        textField.rx.text.on(.next("Text2"))
        XCTAssertTrue(textField.didSetText)
    }
    
    func test_attributedTextObserver() {
        let textField = UITextField()
        XCTAssertEqual(textField.attributedText, "".enrichedWithTextFieldAttributes)
        let attributedText = "Hello!".enrichedWithTextFieldAttributes
        textField.rx.attributedText.onNext(attributedText)
        XCTAssertEqual(textField.attributedText!, attributedText)
    }
}

private extension String {
    var enrichedWithTextFieldAttributes: NSAttributedString {
        let tf = UITextField()
        tf.attributedText = NSAttributedString(string: self)
        return tf.attributedText!
    }
}

final class UITextFieldSubclass : UITextField {
    var didSetText = false
    
    override var text: String? {
        get {
            return super.text
        }
        set {
            didSetText = true
            super.text = newValue
        }
    }
    
}
