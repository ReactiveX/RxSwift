//
//  UIRefreshControl+RxTests.swift
//  Tests
//
//  Created by Yosuke Ishikawa on 1/31/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)

import RxSwift
import RxCocoa
import UIKit
import XCTest

final class UIRefreshControlTests : RxTest {
}

extension UIRefreshControlTests {
    func testRefreshing_True() {
        let subject = UIRefreshControl()
        Observable.just(true).subscribe(subject.rx.isRefreshing).dispose()

        XCTAssertTrue(subject.isRefreshing == true)
    }

    func testRefreshing_False() {
        let subject = UIRefreshControl()
        Observable.just(false).subscribe(subject.rx.isRefreshing).dispose()

        XCTAssertTrue(subject.isRefreshing == false)
    }
}

#endif
