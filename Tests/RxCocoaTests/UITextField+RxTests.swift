//
//  UITextField+RxTests.swift
//  Rx
//
//  Created by Krunoslav Zaher on 5/13/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import XCTest

// UITextField
class UITextFieldTests : RxTest {
    func testTextCompletesOnDealloc() {
        ensurePropertyDeallocated({ UITextField() }, "a") { (view: UITextField) in view.rx_text }
    }

    func testSettingTextDoesntClearMarkedText() {
        let textField = UITextFieldSubclass(frame: CGRect.zero)

        textField.text = "Text1"
        textField.set = false
        textField.rx_text.on(.Next("Text1"))
        XCTAssertTrue(!textField.set)
        textField.rx_text.on(.Next("Text2"))
        XCTAssertTrue(textField.set)
    }
}

class UITextFieldSubclass : UITextField {
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
