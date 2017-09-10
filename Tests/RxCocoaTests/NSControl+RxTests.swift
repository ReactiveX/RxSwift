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

    func test_controlEvent() {
        let control = NSControl(frame: CGRect(x: 0, y: 0, width: 1, height: 1))

        var numberOfTimesReceivedValue = 0

        let d1 = control.rx.controlEvent.subscribe(onNext: { numberOfTimesReceivedValue += 1 })
        let d2 = control.rx.controlEvent.subscribe(onNext: { numberOfTimesReceivedValue += 1 })

        XCTAssertEqual(numberOfTimesReceivedValue, 0)

        if let target = control.target, let action = control.action {
            _ = target.perform(action, with: target)
        }

        XCTAssertEqual(numberOfTimesReceivedValue, 2)

        d1.dispose()
        d2.dispose()

        _ = control.rx.controlEvent.subscribe(onNext: { numberOfTimesReceivedValue += 1 })
        _ = control.rx.controlEvent.subscribe(onNext: { numberOfTimesReceivedValue += 1 })

        XCTAssertEqual(numberOfTimesReceivedValue, 2)

        if let target = control.target, let action = control.action {
            _ = target.perform(action, with: target)
        }

        XCTAssertEqual(numberOfTimesReceivedValue, 4)
    }

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
