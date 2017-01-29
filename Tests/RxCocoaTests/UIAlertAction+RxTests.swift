//
//  UIAlertAction+RxTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 11/26/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import RxCocoa
import RxSwift
import RxTest
import XCTest

final class UIAlertActionTests: RxTest {

}

extension UIAlertActionTests {
    func testAlertAction_Enable() {
        let subject = UIAlertAction()
        Observable.just(false).subscribe(subject.rx.isEnabled).dispose()
        
        XCTAssertTrue(subject.isEnabled == false)
    }

    func testAlertAction_Disable() {
        let subject = UIAlertAction()
        Observable.just(true).subscribe(subject.rx.isEnabled).dispose()
        
        XCTAssertTrue(subject.isEnabled == true)
    }
}
