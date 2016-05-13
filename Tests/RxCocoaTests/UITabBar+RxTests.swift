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
        XCTAssertTrue(subject.barStyle == .Default)

        Observable.just(UIBarStyle.Black).subscribe(subject.rx_barStyle).dispose()

        XCTAssertTrue(subject.barStyle == .Black)
    }

    func testTranslucent() {
        let subject = createSubject()
        XCTAssertTrue(subject.translucent == true)

        Observable.just(false).subscribe(subject.rx_translucent).dispose()

        XCTAssertTrue(subject.translucent == false)
    }

    func testBarTintColor() {
        let subject = createSubject()
        XCTAssertTrue(subject.barTintColor == nil)

        Observable.just(UIColor.purpleColor()).subscribe(subject.rx_barTintColor).dispose()

        XCTAssertTrue(subject.barTintColor == UIColor.purpleColor())
    }

    func testItemPositioning() {
        let subject = createSubject()
        XCTAssertTrue(subject.itemPositioning == .Automatic)

        Observable.just(.Fill).subscribe(subject.rx_itemPositioning).dispose()

        XCTAssertTrue(subject.itemPositioning == .Fill)
    }

}
