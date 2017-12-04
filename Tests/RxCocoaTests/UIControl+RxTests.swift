//
//  UIControl+RxTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 10/10/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit
import XCTest

final class UIControlTests : RxTest {
}

extension UIControlTests {
    func testControl_EventCompletesOnDealloc() {
        let createView: () -> UIControl = { UIControl(frame: CGRect(x: 0, y: 0, width: 1, height: 1)) }
        ensureEventDeallocated(createView) { (view: UIControl) in view.rx.controlEvent(.allEditingEvents) }
        ensurePropertyDeallocated(createView, "1") { (view: UIControl) in
            var value = "1"
            return view.rx.controlProperty(
                editingEvents: [.allEditingEvents],
                getter: { _ -> String in value },
                setter: { (_, newValue) in value = newValue }
            )
        }
    }

    func test_controlEvent() {
        let control = UIControl(frame: CGRect(x: 0, y: 0, width: 1, height: 1))

        var numberOfTimesReceivedEditingChanged = 0
        var numberOfTimesReceivedEditingDidBegin = 0

        let d1 = control.rx.controlEvent([.editingChanged]).subscribe(onNext: { numberOfTimesReceivedEditingChanged += 1 })
        let d2 = control.rx.controlEvent([.editingChanged]).subscribe(onNext: { numberOfTimesReceivedEditingChanged += 1 })

        XCTAssertEqual(numberOfTimesReceivedEditingChanged, 0)

        control.forceSendActions(for: .editingDidBegin)
        XCTAssertEqual(numberOfTimesReceivedEditingChanged, 0)

        control.forceSendActions(for: .editingChanged)
        XCTAssertEqual(numberOfTimesReceivedEditingChanged, 2)

        d1.dispose()
        d2.dispose()

        let d3 = control.rx.controlEvent([.editingChanged]).subscribe(onNext: { numberOfTimesReceivedEditingChanged += 1 })
        let d4 = control.rx.controlEvent([.editingChanged]).subscribe(onNext: { numberOfTimesReceivedEditingChanged += 1 })

        XCTAssertEqual(numberOfTimesReceivedEditingChanged, 2)

        control.forceSendActions(for: .editingDidBegin)
        XCTAssertEqual(numberOfTimesReceivedEditingChanged, 2)

        control.forceSendActions(for: .editingChanged)
        XCTAssertEqual(numberOfTimesReceivedEditingChanged, 4)

        XCTAssertEqual(numberOfTimesReceivedEditingDidBegin, 0)

        _ = control.rx.controlEvent([.editingDidBegin]).subscribe(onNext: { numberOfTimesReceivedEditingDidBegin += 1 })
        _ = control.rx.controlEvent([.editingDidBegin]).subscribe(onNext: { numberOfTimesReceivedEditingDidBegin += 1 })

        XCTAssertEqual(numberOfTimesReceivedEditingChanged, 4)
        XCTAssertEqual(numberOfTimesReceivedEditingDidBegin, 0)

        control.forceSendActions(for: .editingDidBegin)
        XCTAssertEqual(numberOfTimesReceivedEditingChanged, 4)
        XCTAssertEqual(numberOfTimesReceivedEditingDidBegin, 2)

        control.forceSendActions(for: .editingChanged)
        XCTAssertEqual(numberOfTimesReceivedEditingChanged, 6)
        XCTAssertEqual(numberOfTimesReceivedEditingDidBegin, 2)

        d3.dispose()
        d4.dispose()
    }

    func test_controlPropertySource() {
        let control = UIControl(frame: CGRect(x: 0, y: 0, width: 1, height: 1))

        var receivedValues = [String]()

        var value = ""

        let property = control.rx.controlProperty(
            editingEvents: [.valueChanged],
            getter: { (_: UIControl) in
                value
            }, setter: { (_: UIControl, newValue) in
                fatalError()
            })

        value = "a"

        XCTAssertEqual(receivedValues, [])

        let d1 = property.asObservable().subscribe(onNext: { receivedValues.append($0) })
        let d2 = property.asObservable().subscribe(onNext: { receivedValues.append($0) })

        XCTAssertEqual(receivedValues, ["a", "a"])

        value = "b"

        control.forceSendActions(for: .editingChanged)
        XCTAssertEqual(receivedValues, ["a", "a"])

        control.forceSendActions(for: .valueChanged)

        XCTAssertEqual(receivedValues, ["a", "a", "b", "b"])

        d1.dispose()
        d2.dispose()

        _ = property.asObservable().subscribe(onNext: { receivedValues.append($0) })
        _ = property.asObservable().subscribe(onNext: { receivedValues.append($0) })

        XCTAssertEqual(receivedValues, ["a", "a", "b", "b", "b", "b"])

        value = "c"

        control.forceSendActions(for: .editingChanged)
        XCTAssertEqual(receivedValues, ["a", "a", "b", "b", "b", "b"])

        control.forceSendActions(for: .valueChanged)
        XCTAssertEqual(receivedValues, ["a", "a", "b", "b", "b", "b", "c", "c"])
    }

    func testSubscribeEnabledToTrue() {
        let subject = UIControl()
        let disposable = Observable.just(true).subscribe(subject.rx.isEnabled)
        defer { disposable.dispose() }

        XCTAssert(subject.isEnabled == true, "Expected enabled set to true")
    }

    func testSubscribeEnabledToFalse() {
        let subject = UIControl()
        let disposable = Observable<Bool>.just(false).subscribe(subject.rx.isEnabled)
        defer { disposable.dispose() }

        XCTAssert(subject.isEnabled == false, "Expected enabled set to false")
    }

    func testSubscribedSelectedToTrue() {
        let subject = UIControl()
        let disposable = Observable<Bool>.just(true).subscribe(subject.rx.isSelected)
        defer { disposable.dispose() }

        XCTAssert(subject.isSelected == true, "Expected selected set to true")
    }

    func testSubscribeSelectedToFalse() {
        let subject = UIControl()
        let disposable = Observable.just(false).subscribe(subject.rx.isSelected)
        defer { disposable.dispose() }

        XCTAssert(subject.isSelected == false, "Expected selected set to false")
    }
}

fileprivate extension UIControl {
    func forceSendActions(for: UIControlEvents) {
        for target in self.allTargets {
            for selector in self.actions(forTarget: target, forControlEvent: `for`) ?? [] {
                (target.base as! NSObject).perform(NSSelectorFromString(selector), with: self)
            }
        }
    }
}
