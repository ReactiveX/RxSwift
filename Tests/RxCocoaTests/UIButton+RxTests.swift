//
//  UIButton+RxTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 6/24/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxTest
import RxCocoa
import UIKit
import RxSwift
import XCTest

class RxButtonTests: RxTest {
    func testTitleNormal() {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 1, height: 1))

        XCTAssertFalse(button.title(for: []) == "normal")
        _ = Observable.just("normal").subscribe(button.rx.title(for: []))
        XCTAssertTrue(button.title(for: []) == "normal")
    }

    func testTitleSelected() {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 1, height: 1))

        XCTAssertFalse(button.title(for: .selected) == "normal")
        _ = Observable.just("normal").subscribe(button.rx.title(for: .selected))
        XCTAssertTrue(button.title(for: .selected) == "normal")
    }

    func testTitleDefault() {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 1, height: 1))

        XCTAssertFalse(button.title(for: []) == "normal")
        _ = Observable.just("normal").subscribe(button.rx.title())
        XCTAssertTrue(button.title(for: []) == "normal")
    }
}
