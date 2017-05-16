//
//  UILabel+RxTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 11/26/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import RxCocoa
import RxSwift
import RxTest
import XCTest

final class UILabelTests: RxTest {

}

extension UILabelTests {
    func testLabel_attributedTextObserver() {
        let label = UILabel()
        XCTAssertEqual(label.attributedText, nil)
        let text = NSAttributedString(string: "Hello!")
        _ = Observable.just(text).bind(to: label.rx.attributedText)

        XCTAssertEqual(label.attributedText, text)
    }

    func testLabel_textObserver() {
        let label = UILabel()
        XCTAssertEqual(label.text, nil)
        let text = "Hello!"
        _ = Observable.just(text).bind(to: label.rx.text)

        XCTAssertEqual(label.text, text)
    }
}
