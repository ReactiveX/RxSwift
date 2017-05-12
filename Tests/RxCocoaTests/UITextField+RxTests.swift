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
    
    func test_TextCompletesOnDealloc() {
        ensurePropertyDeallocated({ UITextField() }, "a", comparer: { $0 == $1 }) { (view: UITextField) in view.rx.text }
    }
    func test_ValueCompletesOnDealloc() {
        ensurePropertyDeallocated({ UITextField() }, "a", comparer: { $0 == $1 }) { (view: UITextField) in view.rx.value }
    }
    
    func testSettingTextDoesntClearMarkedText() {
        let textField = UITextFieldSubclass(frame: CGRect.zero)
        
        textField.text = "Text1"
        textField.settedText = false
        textField.rx.text.on(.next("Text1"))
        XCTAssertTrue(!textField.settedText)
        textField.rx.text.on(.next("Text2"))
        XCTAssertTrue(textField.settedText)
    }
    
    func testLabel_attributedTextObserver() {
        let label = UILabel()
        XCTAssertEqual(label.attributedText, nil)
        let text = NSAttributedString(string: "Hello!")
        _ = Observable.just(text).bind(to: label.rx.attributedText)
        
        XCTAssertEqual(label.attributedText, text)
    }
}

final class UITextFieldSubclass : UITextField {
    var settedText = false
    
    override var text: String? {
        get {
            return super.text
        }
        set {
            settedText = true
            super.text = newValue
        }
    }
    
}
