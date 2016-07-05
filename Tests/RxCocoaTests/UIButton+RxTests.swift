//
//  UIButton+RxTests.swift
//  Rx
//
//  Created by Krunoslav Zaher on 6/24/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxTests
import RxCocoa
import UIKit
import RxSwift
import XCTest

class RxButtonTests: RxTest {
    func testTitleNormal() {
        let button = UIButton(frame: CGRectMake(0, 0, 10, 10))

        XCTAssertFalse(button.titleForState(.Normal) == "normal")
        Observable.just("normal").subscribe(button.rx_title(.Normal))
        XCTAssertTrue(button.titleForState(.Normal) == "normal")
    }

    func testTitleSelected() {
        let button = UIButton(frame: CGRectMake(0, 0, 10, 10))

        XCTAssertFalse(button.titleForState(.Selected) == "normal")
        Observable.just("normal").subscribe(button.rx_title(.Selected))
        XCTAssertTrue(button.titleForState(.Selected) == "normal")
    }

    func testTitleDefault() {
        let button = UIButton(frame: CGRectMake(0, 0, 10, 10))

        XCTAssertFalse(button.titleForState(.Normal) == "normal")
        Observable.just("normal").subscribe(button.rx_title())
        XCTAssertTrue(button.titleForState(.Normal) == "normal")
    }
}