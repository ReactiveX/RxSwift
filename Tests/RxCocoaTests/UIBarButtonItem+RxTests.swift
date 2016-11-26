//
//  UIBarButtonItem+RxTests.swift
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

class UIBarButtonItemTests: RxTest {

}

// UIBarButtonItem
extension UIBarButtonItemTests {
    func testBarButtonItem_DelegateEventCompletesOnDealloc() {
        ensureEventDeallocated({ UIBarButtonItem() }) { (view: UIBarButtonItem) in view.rx.tap }
    }
}
