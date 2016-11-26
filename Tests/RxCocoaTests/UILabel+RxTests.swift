//
//  UILabel+RxTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 11/26/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxTest
import XCTest

class UILabelTests: RxTest {

}

extension UILabelTests {
    func testLabel_HasWeakReference() {
        let variable = Variable<NSAttributedString?>(nil)
        ensureControlObserverHasWeakReference(UILabel(), { (label: UILabel) -> AnyObserver<NSAttributedString?> in label.rx.attributedText.asObserver() }, { variable.asObservable() })
    }

    func testLabel_NextElementsSetsValue() {
        let subject = UILabel()
        let attributedTextSequence = Variable<NSAttributedString?>(nil)
        let disposable = attributedTextSequence.asObservable().bindTo(subject.rx.attributedText)
        defer { disposable.dispose() }

        attributedTextSequence.value = NSAttributedString(string: "Hello!")
        XCTAssert(subject.attributedText == attributedTextSequence.value, "Expected attributedText to have been set")
    }
}
