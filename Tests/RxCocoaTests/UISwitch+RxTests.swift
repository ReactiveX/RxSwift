//
//  UISwitch+RxTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 11/26/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxTest
import XCTest

#if os(iOS)

    class UISwitchTests: RxTest {
        
    }

    extension UISwitchTests {

        #if swift(>=2.2)
        #else
        // TODO: UISwitch doesn't dealloc on Swift 2.3 compiler
        func testSwitch_DelegateEventCompletesOnDealloc() {
            let createView: () -> UISwitch = { UISwitch(frame: CGRect(x: 0, y: 0, width: 1, height: 1)) }
            ensurePropertyDeallocated(createView, true) { (view: UISwitch) in view.rx.value }
        }
        #endif

    }

#endif
