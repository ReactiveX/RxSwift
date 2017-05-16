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

    final class UIStepperTests: RxTest {

    }

    extension UIStepperTests {
        func testStepper_DelegateEventCompletesOnDealloc() {
            let createView: () -> UIStepper = { UIStepper(frame: CGRect(x: 0, y: 0, width: 1, height: 1)) }
            ensurePropertyDeallocated(createView, 1) { (view: UIStepper) in view.rx.value }
        }
    }

#endif
