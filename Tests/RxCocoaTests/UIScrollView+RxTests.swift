//
//  UIScrollView+RxTests.swift
//  Tests
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
        scrollView.isScrollEnabled = true
        Observable.just(false).bindTo(scrollView.rx.isScrollEnabled).dispose()
        XCTAssertTrue(scrollView.isScrollEnabled == false)
    }

    func testScrollEnabled_True() {
        let scrollView = UIScrollView(frame: CGRect.zero)
        scrollView.isScrollEnabled = false
        Observable.just(true).bindTo(scrollView.rx.isScrollEnabled).dispose()
        XCTAssertTrue(scrollView.isScrollEnabled == true)
    }

}

@objc class MockScrollViewDelegate
    : NSObject
    , UIScrollViewDelegate {

}

extension UIScrollViewTests {
    func testSetDelegateUsesWeakReference() {

        var delegateDeallocated = false

        let scrollView = UIScrollView(frame: CGRect.zero)
        autoreleasepool {
            let delegate = MockScrollViewDelegate()
            _ = scrollView.rx.setDelegate(delegate)

            _ = delegate.rx.deallocated.subscribe(onNext: { _ in
                delegateDeallocated = true
            })

            XCTAssert(delegateDeallocated == false)
        }
        XCTAssert(delegateDeallocated == true)
    }
}

#endif
