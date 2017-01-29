//
//  UIPageControl+RxTest.swift
//  Tests
//
//  Created by Francesco Puntillo on 25/04/2016.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)

import RxSwift
import RxCocoa
import UIKit
import XCTest

final class UIPageControlTest : RxTest {
}

extension UIPageControlTest {
    func testPageControl_CurrentPage() {
        let pageControl = UIPageControl(frame: CGRect.zero)
        pageControl.numberOfPages = 10
        Observable.just(5).bindTo(pageControl.rx.currentPage).dispose()
        XCTAssertTrue(pageControl.currentPage == 5)
    }
    
    func testPageControl_NumberOfPages() {
        let pageControl = UIPageControl(frame: CGRect.zero)
        Observable.just(10).bindTo(pageControl.rx.numberOfPages).dispose()
        XCTAssertTrue(pageControl.numberOfPages == 10)
    }
}

#endif
