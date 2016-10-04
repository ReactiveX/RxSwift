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
import RxTests
import UIKit
import XCTest

class UIRefreshControlTests : RxTest {
}

extension UIRefreshControlTests {
    func testRefreshing_Getter() {
        let scheduler = TestScheduler(initialClock: 0)
        let subject = UIRefreshControl()
        let observer = scheduler.createObserver(Bool.self)
        let disposable = subject.rx.refreshing.bindTo(observer)

        scheduler.scheduleAt(10) { subject.beginRefreshing() }
        scheduler.scheduleAt(20) { subject.endRefreshing() }
        scheduler.scheduleAt(30) { disposable.dispose() }
        scheduler.start()

        XCTAssertEqual(observer.events, [
            next(0, false),
            next(10, true),
            next(20, false),
        ])
    }
    
    func testRefreshing_CompletesOnDealloc() {
        ensurePropertyDeallocated({ UIRefreshControl() }, false) { (view: UIRefreshControl) in view.rx.refreshing }
    }
    
    func testRefreshing_True() {
        let subject = UIRefreshControl()
        Observable.just(true).subscribe(subject.rx.refreshing).dispose()

        XCTAssertTrue(subject.isRefreshing == true)
    }

    func testRefreshing_False() {
        let subject = UIRefreshControl()
        Observable.just(false).subscribe(subject.rx.refreshing).dispose()

        XCTAssertTrue(subject.isRefreshing == false)
    }
}

#endif
