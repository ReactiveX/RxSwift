//
//  NSScrollView+RxTests.swift
//  Rx
//
//  Created by Christian Tietze on 26/05/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxCocoa
import AppKit
import XCTest

final class NSScrollViewTests: RxTest {

}

extension NSScrollViewTests {
    func testScrollView_BackgroundColorCompletesOnDealloc() {
        let createView: () -> NSScrollView = { NSScrollView(frame: CGRect(x: 0, y: 0, width: 1, height: 1)) }
        ensurePropertyDeallocated(createView, NSColor.blue) { (view: NSScrollView) in view.rx.backgroundColor }
    }
}
