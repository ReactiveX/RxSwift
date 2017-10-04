//
//  NSSegmentedControl+RxTests.swift
//  Tests
//
//  Created by Mykola Voronin on 10/3/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxCocoa
import AppKit
import XCTest

final class NSSegmentedControlTests: RxTest {
    
}

extension NSSegmentedControlTests {
    func testSegmentedControl_SelectedSegmentCompletesOnDealloc() {
        let createView: () -> NSSegmentedControl = { NSSegmentedControl() }
        ensurePropertyDeallocated(createView, -1) { (view: NSSegmentedControl) in view.rx.selectedSegment }
    }
}
