//
//  UITabBar+RxTests.swift
//  Rx
//
//  Created by Jesse Farless on 5/13/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import UIKit
import XCTest

class UITabBar_RxTests: RxTest {
    let createSubject: () -> UITabBar = { UITabBar(frame: CGRectMake(0, 0, 1, 1)) }
}

extension UITabBar_RxTests {
    func testBarStyle() {
        let subject = createSubject()
        XCTAssertEqual(subject.barStyle, UIBarStyle.Default)

        Observable.just(UIBarStyle.Black).subscribe(subject.rx_barStyle).dispose()

        XCTAssertEqual(subject.barStyle, UIBarStyle.Black)
    }

    func testTranslucent() {
        let subject = createSubject()
        XCTAssertTrue(subject.translucent)

        Observable.just(false).subscribe(subject.rx_translucent).dispose()

        XCTAssertFalse(subject.translucent)
    }

    func testBarTintColor() {
        let subject = createSubject()
        XCTAssertEqual(subject.barTintColor, nil)

        Observable.just(UIColor.purpleColor()).subscribe(subject.rx_barTintColor).dispose()

        XCTAssertEqual(subject.barTintColor, UIColor.purpleColor())
    }

    func testItemPositioning() {
        let subject = createSubject()
        XCTAssertEqual(subject.itemPositioning, UITabBarItemPositioning.Automatic)

        Observable.just(.Fill).subscribe(subject.rx_itemPositioning).dispose()

        XCTAssertEqual(subject.itemPositioning, UITabBarItemPositioning.Fill)
    }

    func testItemSpacing() {
        let subject = createSubject()
        XCTAssertEqualWithAccuracy(subject.itemSpacing, 0, accuracy: 0.00001)

        Observable.just(77).subscribe(subject.rx_itemSpacing).dispose()

        XCTAssertEqualWithAccuracy(subject.itemSpacing, 77, accuracy: 0.00001)
    }

}
