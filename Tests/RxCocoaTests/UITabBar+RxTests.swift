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
}

extension UITabBar_RxTests {

    func testBarStyle() {
        let subject = UITabBar(frame: CGRectMake(0, 0, 1, 1))
        XCTAssertTrue(subject.barStyle == .Default)

        Observable.just(UIBarStyle.Black).subscribe(subject.rx_barStyle).dispose()

        XCTAssertTrue(subject.barStyle == .Black)
    }

    func testTranslucent() {
        let subject = UITabBar(frame: CGRectMake(0, 0, 1, 1))
        XCTAssertTrue(subject.translucent == true)

        Observable.just(false).subscribe(subject.rx_translucent).dispose()

        XCTAssertTrue(subject.translucent == false)
    }

    func testBarTintColor() {
        let subject = UITabBar(frame: CGRectMake(0, 0, 1, 1))
        XCTAssertTrue(subject.barTintColor == nil)

        Observable.just(UIColor.purpleColor()).subscribe(subject.rx_barTintColor).dispose()

        XCTAssertTrue(subject.barTintColor == UIColor.purpleColor())
    }

}
