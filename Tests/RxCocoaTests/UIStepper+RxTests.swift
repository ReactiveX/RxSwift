//
//  UIStepper+RxTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 11/26/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import RxCocoa
import RxSwift
import RxTest
import XCTest

#if os(iOS)

final class UIStepperTests: RxTest {}

extension UIStepperTests {
    func testStepper_stepValueObserver() {
        let stepper = UIStepper()
        let stepValue = 0.42

        stepper.stepValue = 1.0
        XCTAssertEqual(stepper.stepValue, 1.0, accuracy: 0.0001)

        Observable.just(stepValue).bind(to: stepper.rx.stepValue).dispose()
        XCTAssertEqual(stepper.stepValue, stepValue, accuracy: 0.0001)
    }
}

#endif
