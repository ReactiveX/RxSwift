//
//  UIAlertAction+RxTests.swift
//  Rx
//
//  Created by Andrew Breckenridge on 5/6/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)
    
import Foundation
import RxSwift
import RxCocoa
import XCTest
import UIKit
    
class UIAlertAction_RxTests: RxTest {
        
    func testDidEnableAlertAction {
        let subject = UIAlertAction()
        Observable.just(true).subscribe(subject.rx_enabled).dispose()

        XCTAssertTrue(subject.enabled == true)
    }

    func testDidDisableAlertAction() {
        let subject = UIAlertAction()
        Observable.just(false).subscribe(subject.rx_enabled).dispose()

        XCTAssertTrue(subject.enabled == false)
    }
}
    
#endif