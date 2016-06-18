//
//  UIScrollView+RxTests.swift
//  Rx
//
//  Created by Suyeol Jeon on 6/8/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)

import Foundation

import RxSwift
import RxCocoa
import UIKit
import XCTest

class UIScrollViewTests : RxTest {
}

extension UIScrollViewTests {

    func testScrollEnabled_False() {
        let scrollView = UIScrollView(frame: CGRect.zero)
        scrollView.scrollEnabled = true
        Observable.just(false).bindTo(scrollView.rx_scrollEnabled).dispose()
        XCTAssertTrue(scrollView.scrollEnabled == false)
    }

    func testScrollEnabled_True() {
        let scrollView = UIScrollView(frame: CGRect.zero)
        scrollView.scrollEnabled = false
        Observable.just(true).bindTo(scrollView.rx_scrollEnabled).dispose()
        XCTAssertTrue(scrollView.scrollEnabled == true)
    }

}

#endif
