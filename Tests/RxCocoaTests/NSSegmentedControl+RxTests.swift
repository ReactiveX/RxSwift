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

    func testSegmentedControl_selectedSegment_setter() {
        let segmentedControl = NSSegmentedControl()

        XCTAssertEqual(segmentedControl.selectedSegment, -1)
        Observable.just(2).bind(to: segmentedControl.rx.selectedSegment).dispose()
        XCTAssertEqual(segmentedControl.selectedSegment, 2)
    }

    func testSegmentedControl_selectedSegment_getter() {
        let segmentedControl = NSSegmentedControl()
        segmentedControl.selectedSegment = 1

        var targetSelectedSegment = 0
        _ = segmentedControl.rx.selectedSegment.subscribe(onNext: { selectedSegment in
            targetSelectedSegment = selectedSegment
        })

        XCTAssertEqual(targetSelectedSegment, 1)
    }
}
