//
//  UIView+RxTests.swift
//  RxTests
//
//  Created by Krunoslav Zaher on 12/6/15.
//
//

import Foundation

import RxSwift
import RxCocoa
import UIKit
import XCTest

class UIViewTests : RxTest {
}

extension UIViewTests {
    func testHidden_True() {
        let subject = UIView(frame: CGRect.zero)
        just(true).subscribe(subject.rx_hidden).dispose()

        XCTAssertTrue(subject.hidden == true)
    }

    func testEnabled_False() {
        let subject = UIView(frame: CGRect.zero)
        just(false).subscribe(subject.rx_hidden).dispose()

        XCTAssertTrue(subject.hidden == false)
    }
}

extension UIViewTests {
    func testAlpha_0() {
        let subject = UIView(frame: CGRect.zero)
        just(0).subscribe(subject.rx_alpha).dispose()

        XCTAssertTrue(subject.alpha == 0.0)
    }

    func testAlpha_1() {
        let subject = UIView(frame: CGRect.zero)
        just(1).subscribe(subject.rx_alpha).dispose()

        XCTAssertTrue(subject.alpha == 1.0)
    }
}