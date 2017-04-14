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
        textField.set = false
        textField.rx.text.on(.next("Text1"))
        XCTAssertTrue(!textField.set)
        textField.rx.text.on(.next("Text2"))
        XCTAssertTrue(textField.set)
    }

    func testTextFieldShouldClear() {
        var completed = false

        autoreleasepool {
            let textField = UITextField()
            var shouldClear = false

            _ = textField.rx.shouldClear.subscribe(onNext: {
                shouldClear = true
            }, onCompleted: {
                completed = true
            })

            XCTAssertFalse(shouldClear)

            _ = textField.delegate!.textFieldShouldClear!(textField)

            XCTAssertTrue(shouldClear)
        }
        
        XCTAssertTrue(completed)
    }

    func testTextFieldShouldReturn() {
        var completed = false

        autoreleasepool {
            let textField = UITextField()
            var shouldReturn = false

            _ = textField.rx.shouldReturn.subscribe(onNext: {
                shouldReturn = true
            }, onCompleted: {
                completed = true
            })

            XCTAssertFalse(shouldReturn)

            _ = textField.delegate!.textFieldShouldReturn!(textField)

            XCTAssertTrue(shouldReturn)
        }
        
        XCTAssertTrue(completed)
    }
}

final class UITextFieldSubclass : UITextField {
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
