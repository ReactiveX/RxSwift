//
//  UIGestureRecognizer+RxTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 11/26/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import RxCocoa
import RxSwift
import RxTest
import XCTest

final class UIGestureRecognizerTests: RxTest {

}

extension UIGestureRecognizerTests {
    func testGestureRecognizer_DelegateEventCompletesOnDealloc() {
        let createView: () -> UIGestureRecognizer = { UIGestureRecognizer(target: nil, action: NSSelectorFromString("s")) }
        ensureEventDeallocated(createView) { (view: UIGestureRecognizer) in view.rx.event }
    }
}
