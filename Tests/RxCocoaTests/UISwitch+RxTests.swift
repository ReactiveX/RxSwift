//
//  UISwitch+RxTests.swift
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

    final class UISwitchTests: RxTest {
        
    }

    // there was a leak on versions prior to 10.2
    extension UISwitchTests {
        func testSwitch_ValueCompletesOnDealloc() {
            if #available(iOS 10.2, *) {
                let createView: () -> UISwitch = { UISwitch(frame: CGRect(x: 0, y: 0, width: 1, height: 1)) }
                ensurePropertyDeallocated(createView, true) { (view: UISwitch) in view.rx.value }
            }
        }

        func testSwitch_isOnCompletesOnDealloc() {
            if #available(iOS 10.2, *) {
                let createView: () -> UISwitch = { UISwitch(frame: CGRect(x: 0, y: 0, width: 1, height: 1)) }
                ensurePropertyDeallocated(createView, true) { (view: UISwitch) in view.rx.isOn }
            }
        }
    }

#endif
