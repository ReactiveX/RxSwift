//
//  NSControl+RxTests.swift
//  Tests
//
//  Created by mrahmiao on 1/1/16.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxCocoa
import Cocoa
import XCTest

final class NSControlTests : RxTest {
}

extension NSControlTests {
    func testEnabled_False() {
        let subject = NSButton(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        Observable.just(false).subscribe(subject.rx.isEnabled).dispose()

        XCTAssertTrue(subject.isEnabled == false)
    }

    func testEnabled_True() {
        let subject = NSButton(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        Observable.just(true).subscribe(subject.rx.isEnabled).dispose()

        XCTAssertTrue(subject.isEnabled == true)
    }
}
