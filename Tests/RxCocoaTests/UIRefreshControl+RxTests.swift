//
//  UIRefreshControl+RxTests.swift
//  RxTests
//
//  Created by Yosuke Ishikawa on 1/31/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)
import Foundation

import RxSwift
import RxCocoa
import UIKit
import XCTest

class UIRefreshControlTests : RxTest {
}

extension UIRefreshControlTests {
    func testRefreshing_True() {
        let subject = UIRefreshControl()
        Observable.just(true).subscribe(subject.rx_refreshing).dispose()

        XCTAssertTrue(subject.refreshing == true)
    }

    func testRefreshing_False() {
        let subject = UIRefreshControl()
        Observable.just(false).subscribe(subject.rx_refreshing).dispose()

        XCTAssertTrue(subject.refreshing == false)
    }
}

#endif
