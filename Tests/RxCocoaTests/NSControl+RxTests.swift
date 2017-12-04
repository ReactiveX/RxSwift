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
    func testControl_EventCompletesOnDealloc() {
        let createView: () -> NSControl = { NSControl(frame: CGRect(x: 0, y: 0, width: 1, height: 1)) }
        ensureEventDeallocated(createView) { (view: NSControl) in view.rx.controlEvent }
        ensurePropertyDeallocated(createView, "1") { (view: NSControl) in
            var value = "1"
            return view.rx.controlProperty(
                getter: { (_) -> String in value },
                setter: { (_, newValue) in value = newValue }
            )
        }
    }

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

    func test_controlPropertySource() {
        let control = NSControl(frame: CGRect(x: 0, y: 0, width: 1, height: 1))

        var receivedValues = [String]()

        var value = ""

        let property = control.rx.controlProperty(getter: { (_: NSControl) in
            value
        }, setter: { (_: NSControl, newValue) in
            fatalError()
        })

        value = "a"

        XCTAssertEqual(receivedValues, [])

        let d1 = property.asObservable().subscribe(onNext: { receivedValues.append($0) })
        let d2 = property.asObservable().subscribe(onNext: { receivedValues.append($0) })

        XCTAssertEqual(receivedValues, ["a", "a"])

        value = "b"

        if let target = control.target, let action = control.action {
            _ = target.perform(action, with: target)
        }

        XCTAssertEqual(receivedValues, ["a", "a", "b", "b"])

        d1.dispose()
        d2.dispose()

        _ = property.asObservable().subscribe(onNext: { receivedValues.append($0) })
        _ = property.asObservable().subscribe(onNext: { receivedValues.append($0) })

        XCTAssertEqual(receivedValues, ["a", "a", "b", "b", "b", "b"])

        value = "c"

        if let target = control.target, let action = control.action {
            _ = target.perform(action, with: target)
        }

        XCTAssertEqual(receivedValues, ["a", "a", "b", "b", "b", "b", "c", "c"])
    }

    func test_controlPropertyBindsValue() {
        let control = NSControl(frame: CGRect(x: 0, y: 0, width: 1, height: 1))

        var value = ""

        let property = control.rx.controlProperty(getter: { _ in
            fatalError()
        }, setter: { (_: NSControl, newValue: String) in
            value = newValue
        })

        XCTAssertNotEqual(value, "b")
        property.onNext("b")
        XCTAssertEqual(value, "b")
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
