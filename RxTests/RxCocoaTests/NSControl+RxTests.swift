//
//  NSControl+RxTests.swift
//  RxTests
//
//  Created by mrahmiao on 12/28/15.
//
//

import Foundation
import RxSwift
import RxCocoa
import Cocoa
import XCTest

class NSControlTests : RxTest {
}

extension NSControlTests {
    func testEnable_False() {
        let subject = NSButton(frame: CGRectMake(0, 0, 1, 1))
        just(false).subscribe(subject.rx_enabled).dispose()

        XCTAssertTrue(subject.enabled == false)
    }

    func testEnable_True() {
        let subject = NSButton(frame: CGRectMake(0, 0, 1, 1))
        just(true).subscribe(subject.rx_enabled).dispose()

        XCTAssertTrue(subject.enabled == true)
    }
}