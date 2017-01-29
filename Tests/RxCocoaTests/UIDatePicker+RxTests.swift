//
//  UIDatePicker+RxTests.swift
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

    final class UIDatePickerTests: RxTest {

    }

    extension UIDatePickerTests {
        func testDatePicker_DateCompletesOnDealloc() {
            let createView: () -> UIDatePicker = { UIDatePicker(frame: CGRect(x: 0, y: 0, width: 1, height: 1)) }
            ensurePropertyDeallocated(createView, Date()) { (view: UIDatePicker) in view.rx.date }
        }

        func testDatePicker_ValueCompletesOnDealloc() {
            let createView: () -> UIDatePicker = { UIDatePicker(frame: CGRect(x: 0, y: 0, width: 1, height: 1)) }
            ensurePropertyDeallocated(createView, Date()) { (view: UIDatePicker) in view.rx.value }
        }
    }

#endif
