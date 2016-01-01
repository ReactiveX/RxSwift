//
//  NSControl+RxTests.swift
//  Tests
//
//  Created by mrahmiao on 1/1/16.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
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
        Observable.just(false).subscribe(subject.rx_enabled).dispose()

        XCTAssertTrue(subject.enabled == false)
    }

    func testEnabled_True() {
        let subject = NSButton(frame: CGRectMake(0, 0, 1, 1))
        Observable.just(true).subscribe(subject.rx_enabled).dispose()

        XCTAssertTrue(subject.enabled == true)
    }
}