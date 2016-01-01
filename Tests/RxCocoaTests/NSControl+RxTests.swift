//
//  NSControl+RxTests.swift
//  Tests
//
//  Created by mrahmiao on 1/1/16.
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
    func testEnabled_False() {
        let subject = NSButton(frame: CGRectMake(0, 0, 1, 1))
        just(false).subscribe(subject.rx_enabled).dispose()

        XCTAssertTrue(subject.enabled == false)
    }

    func testEnabled_True() {
        let subject = NSButton(frame: CGRectMake(0, 0, 1, 1))
        just(true).subscribe(subject.rx_enabled).dispose()

        XCTAssertFalse(subject.enabled == true)
    }
}