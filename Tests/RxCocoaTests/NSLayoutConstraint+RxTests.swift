//
//  NSLayoutConstraint+RxTests.swift
//  RxTests
//
//  Created by Krunoslav Zaher on 12/6/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import XCTest
#if os(OSX)
import Cocoa
typealias View = NSView
#else
import UIKit
typealias View = UIView
#endif

class NSLayoutConstraintTest : RxTest {
}


extension NSLayoutConstraintTest {
    func testConstant_0() {
        let subject = View(frame: CGRect.zero)
        let subject2 = View(frame: CGRect.zero)
        let constraint = NSLayoutConstraint(item: subject, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: subject2, attribute: NSLayoutAttribute.Top, multiplier: 0.5, constant: 0.5)
        Observable.just(0).subscribe(constraint.rx_constant).dispose()

        XCTAssertTrue(constraint.constant == 0.0)
    }

    func testConstant_1() {
        let subject = View(frame: CGRect.zero)
        let subject2 = View(frame: CGRect.zero)
        let constraint = NSLayoutConstraint(item: subject, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: subject2, attribute: NSLayoutAttribute.Top, multiplier: 0.5, constant: 0.5)
        Observable.just(1.0).subscribe(constraint.rx_constant).dispose()

        XCTAssertTrue(constraint.constant == 1.0)
    }
}

@available(iOS 8, OSX 10.10, *)
extension NSLayoutConstraintTest {
    func testActive_True() {
        let parent = View(frame: CGRect.zero)
        let subject = View(frame: CGRect.zero)
        let subject2 = View(frame: CGRect.zero)
        parent.addSubview(subject)
        parent.addSubview(subject2)
        let constraint = NSLayoutConstraint(item: subject, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: subject2, attribute: NSLayoutAttribute.Top, multiplier: 0.5, constant: 0.5)
        Observable.just(true).subscribe(constraint.rx_active).dispose()

        XCTAssertTrue(constraint.active == true)
    }
    
    func testActive_False() {
        let parent = View(frame: CGRect.zero)
        let subject = View(frame: CGRect.zero)
        let subject2 = View(frame: CGRect.zero)
        parent.addSubview(subject)
        parent.addSubview(subject2)
        let constraint = NSLayoutConstraint(item: subject, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: subject2, attribute: NSLayoutAttribute.Top, multiplier: 0.5, constant: 0.5)
        Observable.just(false).subscribe(constraint.rx_active).dispose()

        XCTAssertTrue(constraint.active == false)
    }
}