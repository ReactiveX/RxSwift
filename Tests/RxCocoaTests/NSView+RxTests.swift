//
//  NSView+RxTests.swift
//  RxTests
//
//  Created by Krunoslav Zaher on 12/6/15.
//
//

import Foundation
import RxSwift
import RxCocoa
import Cocoa
import XCTest

class NSViewTests : RxTest {
}

extension NSViewTests {
    func testHidden_True() {
        let subject = NSView(frame: CGRect.zero)
        just(true).subscribe(subject.rx_hidden).dispose()

        XCTAssertTrue(subject.hidden == true)
    }

    func testHidden_False() {
        let subject = NSView(frame: CGRect.zero)
        just(false).subscribe(subject.rx_hidden).dispose()

        XCTAssertTrue(subject.hidden == false)
    }
}

extension NSViewTests {
    func testAlpha_0() {
        let subject = NSView(frame: CGRect.zero)
        just(0).subscribe(subject.rx_alpha).dispose()

        XCTAssertTrue(subject.alphaValue == 0.0)
    }

    func testAlpha_1() {
        let subject = NSView(frame: CGRect.zero)
        just(1).subscribe(subject.rx_alpha).dispose()

        XCTAssertTrue(subject.alphaValue == 1.0)
    }
}